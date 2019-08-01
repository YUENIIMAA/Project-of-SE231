import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intellispot/model/user.dart';
import 'package:intellispot/page/translation/result.dart';


class AudioTranslationPage extends StatefulWidget {
  @override
  _AudioTranslationPageState createState() => new _AudioTranslationPageState();
}

class _AudioTranslationPageState extends State<AudioTranslationPage> {



  AudioTransResult _message;

  bool _showResult=false;

  bool _isRecording = false;

  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;

  FlutterSound flutterSound;

  String _recorderTxt = '00:00:00';

  double _dbLevel;

  double slider_current_position = 0.0;
  double max_duration = 1.0;

  String path;


  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }


  void startRecorder() async{
    try {
      path = await flutterSound.startRecorder(null);

      //while(path=="");
      print('startRecording $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

        this.setState(() {
          //this._recorderTxt = '00:00:00';
          this._recorderTxt = txt.substring(0, 8);
          this._showResult=false;
        });
        if(_recorderTxt=="00:15:00") {
          _dbPeakSubscription =
              flutterSound.onRecorderDbPeakChanged.listen((value) {
                print("got update -> $value");
                setState(() {
                  this._dbLevel = value;
                });
              });

          this.setState(() {
            this._isRecording = true;
          });
          stopRecorder();
        }
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
            print("got update -> $value");
            setState(() {
              this._dbLevel = value;
            });
          });

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  void stopRecorder() async{
    try {
      String result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }

      this.setState(() {
        this._recorderTxt = '00:00:00';
        this._isRecording = false;
        this._showResult=true;
        this._message=new AudioTransResult(result:upload(path));
      });


    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  Future<String> upload(String filepath) async {
    try {
      Response response;

      final userModel = UserModel().of(context);

      FormData formData = new FormData.from({
        "files": new UploadFileInfo(new File(filepath), "upload.m4a"),
      });

      response = await userModel.dio.post("/translation/translate-audio", data: formData);
      print(response.statusCode);
      print(response.data);
      if(response.data["message"]=="失败")
        return "fail";
      return response.data["data"].toString();
    } catch (e) {
      print(e);
      return "fail";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语音翻译'),
        backgroundColor: Colors.cyan,
      ),
      body:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _showResult?_message:Text("请录音……", style:TextStyle(fontSize:40)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 24.0, bottom:16.0),
                child: Text(
                  this._recorderTxt,
                  style: TextStyle(
                    fontSize: 48.0,
                    color: Colors.black,
                  ),
                ),
              ),
              _isRecording ? LinearProgressIndicator(
                value: 100.0 / 160.0 * (this._dbLevel ?? 1) / 100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                backgroundColor: Colors.red,
              ) : Container()
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 56.0,
                height: 56.0,
                child: ClipOval(
                  child: FlatButton(
                    onPressed: () {
                      if (!this._isRecording) {
                        return this.startRecorder();
                      }
                      this.stopRecorder();
                    },
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                        this._isRecording ? Icons.stop:Icons.mic,
                        size:50
                    ),
                  ),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ],
      ),
    );
  }
}