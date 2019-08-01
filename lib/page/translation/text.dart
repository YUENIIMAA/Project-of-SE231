import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intellispot/model/translation.dart';
import 'package:intellispot/model/user.dart';
import 'package:intellispot/page/translation/result.dart';
import 'package:flutter_luban/flutter_luban.dart';
import 'package:firebase_admob/firebase_admob.dart';

const String testDevice = '21C6A633B0E4E1F4593791B535F2554D';

class TranslationPage extends StatefulWidget {
  @override
  State createState() => new TranslationPageState();
}

class TranslationPageState extends State<TranslationPage> {

  final _languages=<String>["英语","中文（简体）","日语","法语","德语"];
  final _code={"英语":"en","中文（简体）":"zh","日语":"jp","法语":"fra","德语":"de"};

  String _sourceLan = "英文";
  String _destLan="中文（简体）";


  final List<Trans> _list = [];

  final TextEditingController _textController = new TextEditingController();
  TransMessage _message = new TransMessage();
  TransRecord _transRecord = new TransRecord();


  bool _showResult = false;

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
    return new Container(
      child: new Material(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            _buildInput(),
            Container(height: 10.0),
            _showResult ? _message : _transRecord
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 55.0,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
                width: 0.5,
                color: Colors.grey[500],
              ))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  _chooseLan("source");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(this._sourceLan,
                        style:
                        TextStyle(color: Colors.lightBlue, fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: Colors.white,
            child: Icon(
              Icons.swap_horiz,
              color: Colors.lightBlue,
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  _chooseLan("dest");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      this._destLan,
                      style: TextStyle(color: Colors.lightBlue, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _chooseLan(String type) {
    Navigator.of(context)
        .push(new MaterialPageRoute<void>(builder: (BuildContext context) {
      return new Scaffold(
          appBar: new AppBar(title: Text("选择语言")),
          body: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _languages.length * 2 - 1,
              itemBuilder: (context, i) {
                if (i.isOdd) return Divider();
                final index = i ~/ 2;
                return _buildRow(_languages[index], type);
              }));
    }));
  }

  Widget _buildRow(String lan,String type){
    bool chosen;
    if(type=="source") chosen=!(_sourceLan==lan);
    else chosen=!(_destLan==lan);
    return new Material(child:ListTile(
      title:Text(
          lan,
          style:TextStyle(fontSize:18.0)
      ),
      leading:new Icon(
        chosen? null:Icons.check,
      ),
      onTap:(){
        setState((){
          if(type=="source") _sourceLan=lan;
          else _destLan=lan;
        });
        Navigator.of(context).pop();
      },
    ));
  }



  Widget _buildInput() {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(0.0),
      child: Container(
        height: 240.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildText(),
            _buildIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildText() {
    return Flexible(
        child: Container(
          // height:_textHeight,// MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(left: 18.0, top: 2.0, right: 18.0, bottom: 20.0),

          child: Row(children: [
            Expanded(
              child: TextField(
                  controller: _textController,
                  decoration:
                  InputDecoration(border: InputBorder.none, hintText: '输入文字'),
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                  maxLines: 999,
                  cursorColor: Colors.grey[500],
                  cursorWidth: 2.0,
                  onTap: () {
                    /*setState(() {
                 _textHeight=25;
                  print("here");
                });*/
                  }),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0), //new
              child: _showResult
                  ? new Column(children: [
                new IconButton(
                  icon: new Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _showResult = false;
                    });
                  },
                )
              ])
                  : new IconButton(
                //new
                icon: new Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ]),
        ));
  }

  /*
  从别的地方移植过来的上传函数
   */
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
  /*
  从别的地方移植过来的上传函数
   */

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

      //upload(imagePath);
      Future<String> result =upload(imagePath);
      Navigator.push(context,
          new MaterialPageRoute(builder: (BuildContext context) {
            return new TranslationResult(imagePath: imagePath, result:result);
          }));
      final userModel = UserModel().of(context);
      if (!userModel.isVip) {
        _interstitialAd..show();
      }
    }
  }

  /*
  选择使用相机还是相册获取图片
   */
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
  /*
  选择使用相机还是相册获取图片
   */

  Widget _buildIcon() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Column(children: [
            IconButton(
                icon: new Icon(Icons.camera_enhance, size: 30.0),
                onPressed: () {
                  _showSeletPage(context);
                  /*
                  cameras = await availableCameras();
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (BuildContext context) {
                        return new CameraApp();
                      }));
                  */
                }),
            new Text("拍照"),
          ]),
          new Column(children: [
            IconButton(
                icon: new Icon(Icons.mic, size: 30.0),
                onPressed: () {
                  /*Navigator.push(context,
                      new MaterialPageRoute(builder: (BuildContext context) {
                        return new AudioTranslationPage();
                      }));*/
                  Navigator.of(context).pushNamed('/audio');
                }),
            new Text("录音"),
          ]),
          new Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            IconButton(
                icon: new Icon(Icons.person_outline, size: 30.0),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        //提示框组
                        title: Text("请先充值会员"),
                      );
                    },
                  );
                }),
            new Text("人工"),
          ])
        ]);
  }

  void _handleSubmitted(String text) {
    FocusScope.of(context).requestFocus(FocusNode());
    _textController.clear();
    Future<String> result = getTranslation(text);
    //print(getRecord());
    Trans t = new Trans(text, result, false);
    _message = new TransMessage(message: t);
    //_list.add(Trans(text, result, false));

    //_transRecord = new TransRecord(list: _list);
    setState(() {
      _showResult = true;
    });
  }

  Future<String> getTranslation(String text) async {
    try {
      Response response;

      final userModel = UserModel().of(context);
      userModel.initDio();

      response = await userModel.dio.post("/translation/translate-text", data: {
        "text": text.trim(),
        "sourceLanguage": _code[_sourceLan].toString(),
        "destinationLanguage": _code[_destLan].toString(),
      });

      if (response.statusCode == 200) {
        print(response.data);
        String result = response.data.toString();
        if (!userModel.isVip) {
          _interstitialAd..show();
        }
        return result.substring(29, result.length - 1);
      }
      return "fail";
    } catch (e) {
      print(e);
      return "fail";
    }
  }

  Future<Response> getRecord() async {
    try {
      Response response;

      final userModel = UserModel().of(context);
      userModel.initDio();

      response = await userModel.dio.get("/translation/history");
      print(response.data);
      return json.decode(response.data["data"]);
    } catch (e) {
      print(e);
      return null;
    }
  }
}

class TransMessage extends StatelessWidget {
  TransMessage({this.message});

  final Trans message;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        //设置滑动方向 Axis.horizontal 水平  默认 Axis.vertical 垂直

        scrollDirection: Axis.vertical,

        reverse: true,

        primary: true,

        shrinkWrap: true,

        physics: new ClampingScrollPhysics(),

        cacheExtent: 30.0,

        itemCount: 1,

        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
            child: Card(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0))),
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
              child: Container(

                padding: EdgeInsets.only(left: 18.0, top: 15.0, bottom: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            message.source,
                            style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                            softWrap: true,
                          ),
                          new FutureBuilder(
                              future: message.dest,
                              builder: (context, snapshot) {
                                var data = snapshot.data;
                                if (data == null) {
                                  return CircularProgressIndicator();
                                }
                                return new Text(
                                  data.toString(),
                                  style: new TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                  ),
                                  softWrap: true,
                                );
                              }),
                        ],
                      ),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.star_border,
                            ),
                          )
                        ])
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TransRecord extends StatefulWidget {
  @override
  TransRecordState createState() => new TransRecordState();
}

class TransRecordState extends State<TransRecord> {
  List<Result> _list = [];

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: new FutureBuilder(
            future: getRecord(),
            builder: (context, snapshot) {
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  primary: true,
                  shrinkWrap: true,
                  physics: new ClampingScrollPhysics(),
                  cacheExtent: 30.0,
                  itemCount: _list == null ? 0 : _list.length,
                  itemBuilder: (context, index) {
                    return _displayList(index);
                  });
            }));
  }

  void _showDetails(String origin, String translated) {
    Navigator.of(context)
        .push(new MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(),
        body: ListView.builder(
          scrollDirection: Axis.vertical,
          primary: true,
          shrinkWrap: true,
          physics: new ClampingScrollPhysics(),
          cacheExtent: 30.0,
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0.0))),
                margin: EdgeInsets.only(left: 8.0, right: 8.0),
                child: Container(
                  padding: EdgeInsets.only(left: 18.0, top: 15.0, bottom: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              origin,
                              style: new TextStyle(
                                fontSize: 20.0,
                              ),
                              softWrap: true,
                            ),
                            Divider(),
                            Text(
                              translated,
                              style: new TextStyle(
                                fontSize: 20.0,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
      //Column(children: [Text(origin), Text(translated)]));
    }));
  }

  Widget _displayList(int index) {
    return InkWell(
        onTap: () {
          _showDetails(_list[index].originalText, _list[index].translatedText);
        },
        child: Container(
          padding: EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            margin: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Container(
              height: 80.0,
              padding: EdgeInsets.only(left: 18.0, top: 15.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          _list[index].originalText.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        new Text(
                          _list[index].translatedText.toString(),
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  /*IconButton(
                onPressed: () {},
                icon: Icon(
                  list[index].isColletion ? Icons.star : Icons.star_border,
                  size: 25.0,
                  color: list[index].isColletion
                      ? Colors.yellow[600]
                      : Colors.grey[600],
                ),
              )*/
                ],
              ),
            ),
          ),
        ));
  }

  getRecord() async {
    try {
      Response response;

      final userModel = UserModel().of(context);
      userModel.initDio();
      response = await userModel.dio.get("/translation/history");

      List<Result> list = [];
      for (int i = 0; i < response.data["data"].length; i++) {
        /*Result r = new Result(
            response.data["data"][i]["originalText"].toString(),
            response.data["data"][i]["translatedText"].toString());*/
        Result s= new Result.fromJson(response.data["data"][i]);
        //list.add(r);
        list.add(s);
      }
      _list = list;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
