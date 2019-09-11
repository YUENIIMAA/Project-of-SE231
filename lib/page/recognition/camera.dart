import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intellispot/model/user.dart';
import 'package:intellispot/page/recognition/result.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_luban/flutter_luban.dart';
import 'dart:convert';

const String testDevice = '21C6A633B0E4E1F4593791B535F2554D';

class record {
  String path;
  String name;
  String time;

  record.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        name = json['name'],
        time = json['time'];
}

class RecognitionPage extends StatefulWidget {
  @override
  _RecognitionPageState createState() {
    return _RecognitionPageState();
  }
}

class _RecognitionPageState extends State<RecognitionPage> with WidgetsBindingObserver {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<record> _list = [];

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['travel', 'food'],
    childDirected: true,
    nonPersonalizedAds: true,
  );

  @override
  void initState() {
    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-8241094090007053~9101257028');
    _interstitialAd = createInterstitialAd()..load();
    super.initState();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  InterstitialAd _interstitialAd;

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: 'ca-app-pub-8241094090007053/4694182116',
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = UserModel().of(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Material(
          child: FutureBuilder(
              future: getRecord(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: _list == null ? 0 : _list.length,
                  itemBuilder: (context, index) => InkWell(
                      onTap: () {},
                      child: Card(
                        child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Container(
                                    height: 200.0,
                                    width: 200.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            'http://47.100.191.229/recognition/get_picture?file_name=' +
                                                _list[index].path,
                                            headers: {"Authorization": userModel.authorizationKey}///_authorizationKey
                                        ),
                                      ),
                                    )),
                                new SizedBox(
                                  width: 10.0,
                                ),
                                new Flexible(
                                    child: new Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: [
                                          new Text(
                                            _list[index].name,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          new Text(
                                            _list[index].time,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w100),
                                          ),
                                        ]))
                              ],
                            )),
                      )),
                );
              })),
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.camera_enhance),
          backgroundColor: Colors.cyan,
          label: Text("拍照识别"),
          onPressed:(){
            _showSeletPage(context);
          }
      ),
    );
  }

  getRecord() async {
    try {
      Response response;

      final userModel = UserModel().of(context);
      userModel.initDio();
      response = await userModel.dio.get("/recognition/view-history");

      List<record> list = [];

      print(response.data);
      for (int i = 0; i < response.data["data"].length; i++) {
        record s = new record.fromJson(response.data["data"][i]);
        list.add(s);
      }
      _list = list;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _imagePicker(String via) async{
    File img = null;
    if (via == "Gallery") {
      img = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    else {
      img = await ImagePicker.pickImage(source: ImageSource.camera);
    }
    if (img != null) {
      String imagePath = img.path;
      Future<String> result =upload(imagePath);
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) {
                return new RecognitionResult(imagePath: imagePath,result:result);
              }
          )
      );
      final userModel = UserModel().of(context);
      if (!userModel.isVip) {
        _interstitialAd..show();
      }
    }
  }

  void _showSeletPage(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera),
                    title: new Text('拍摄新的照片'),
                    onTap: () {
                      Navigator.pop(context);
                      _imagePicker("Camera");
                    }
                ),
                new ListTile(
                  leading: new Icon(Icons.photo),
                  title: new Text('从相册选取'),
                  onTap: () {
                    Navigator.pop(context);
                    _imagePicker("Gallery");
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  Future<String> upload(String filepath) async {
    try {
      Response response;
      final userModel = UserModel().of(context);
      userModel.initDio();

      CompressObject compressObject = CompressObject(
        imageFile: File(filepath),
        path: filepath.substring(0, filepath.length - 18), //compress to path
        quality: 85, //first compress quality, default 80
        step:
        9, //compress quality step, The bigger the fast, Smaller is more accurate, default 6
        mode: CompressMode.LARGE2SMALL, //default AUTO
      );
      Luban.compressImage(compressObject);

      FormData formData = new FormData.from({
        "files": new UploadFileInfo(new File(filepath), "upload.jpg"),
      });
      response = await userModel.dio.post("/recognition/recognize-landmark", data: formData);
      print(response.data.toString());
      String result = response.data.toString();
      if (result.substring(29, result.length - 1) == '') {
        return "fail";
      }
      return result.substring(29, result.length - 1);
    } catch (e) {
      print(e);
      return "fail";
    }
  }
}
