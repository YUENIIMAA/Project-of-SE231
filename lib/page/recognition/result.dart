import 'package:flutter/material.dart';

class RecognitionResult extends StatelessWidget {
  RecognitionResult({this.imagePath,this.result});
  final String imagePath;
  final Future<String> result;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: new Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: ExactAssetImage(imagePath),
                  ),
                ),
              ),
            ),
            new Card(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AspectRatio(
                          aspectRatio: 18.0 / 9.0,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('识别结果', style: new TextStyle(fontSize: 30)),
                                SizedBox(height: 8.0),
                                new FutureBuilder(
                                    future: result,
                                    builder: (context, snapshot) {
                                      var data = snapshot.data;
                                      if (data == null) {
                                        print("加载中");
                                        return CircularProgressIndicator();
                                      }
                                      if (data.toString() == "fail") {
                                        print("加载结束");
                                        return new Text(
                                          "我认不出来",
                                          style: new TextStyle(
                                            fontSize: 40.0,
                                          ),
                                          softWrap: true,
                                        );
                                      }
                                      return new Text(
                                        data.toString(),
                                        style: new TextStyle(
                                          fontSize: 40.0,
                                        ),
                                        softWrap: true,
                                      );
                                    }),

                              ])),
                    ]))
          ]),
    );
  }
}