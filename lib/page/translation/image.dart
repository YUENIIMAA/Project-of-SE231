/*
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intellispot/model/user.dart';
import 'package:intellispot/model/translation.dart';
import 'package:intellispot/page/translation/result.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() {
    return _CameraAppState();
  }
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

List<CameraDescription> cameras;

class _CameraAppState extends State<CameraApp> with WidgetsBindingObserver {

  CameraController controller;
  String imagePath;
  int selectedCameraIdx;
  Trans message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (cameras.length > 0) {
          selectedCameraIdx = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        _onCameraSwitched(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              child: _cameraPreviewWidget(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _cameraDirection(),
                _captureControlRowWidget(),
                _gallery()
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.panorama_fish_eye),
          color: Colors.blue,
          iconSize: 60,
          onPressed: controller != null && controller.value.isInitialized
              ? onTakePictureButtonPressed
              : null,
        ),
      ],
    );
  }

  Widget _cameraDirection() {
    return IconButton(
        icon: Icon(Icons.switch_camera),
        iconSize: 40,
        onPressed: () async {
          selectedCameraIdx = selectedCameraIdx < cameras.length - 1
              ? selectedCameraIdx + 1
              : 0;

          CameraDescription selectedCamera = cameras[selectedCameraIdx];

          _onCameraSwitched(selectedCamera);

          setState(() {
            selectedCameraIdx = selectedCameraIdx;
          });
        });
  }

  void _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _gallery() {
    return IconButton(
        icon: Icon(Icons.photo),
        iconSize: 40,
        onPressed: () {
          picker();
        });
  }

  picker() async {
    print('Picker is called');

    File img = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        imagePath = img.path;
      });

      //upload(imagePath);
      Future<String> result =upload(imagePath);
      Navigator.push(context,
          new MaterialPageRoute(builder: (BuildContext context) {
            return new TransResult(imagePath: imagePath, result:result);
          }));
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        //if (filePath != null) showInSnackBar('Picture saved to $filePath');

        //upload(filePath);

        Navigator.push(context,
            new MaterialPageRoute(builder: (BuildContext context) {
              return new TransResult(imagePath: imagePath, result:upload(imagePath));
            }));

      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Future<String> upload(String filepath) async {
    try {
      Response response;

      final userModel = UserModel().of(context);
      userModel.initDio();

      FormData formData = new FormData.from({
        "files": new UploadFileInfo(new File(filepath), "upload.jpg"),
      });

      response = await userModel.dio.post("/translation/translate-picture", data: formData);

      print(response.statusCode);
      print(response.data);
      String result = response.data.toString();
      if (result.substring(29, result.length - 1) == "null") {
        return "识别失败";
      }
      return result.substring(29, result.length - 1);
    } catch (e) {
      print(e);
    }
  }
}
*/
