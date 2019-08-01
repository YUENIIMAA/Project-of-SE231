import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TranslationResult extends StatelessWidget {
  TranslationResult({this.imagePath, this.result});
  final String imagePath;
  final Future<String> result;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.cyan,
        ),
        body: new Column(children: <Widget>[
          Flexible(
            child: ListView.builder(
              //设置滑动方向 Axis.horizontal 水平  默认 Axis.vertical 垂直

              scrollDirection: Axis.vertical,

              primary: true,

              shrinkWrap: true,

              physics: new ClampingScrollPhysics(),

              cacheExtent: 30.0,

              itemCount: 2,

              itemBuilder: (context, index) {
                if (index == 0) return new Image.asset(imagePath);
                return Container(
                  padding: EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0.0),
                  child: Card(
                    color: Colors.cyan,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0.0))),
                    margin: EdgeInsets.only(left: 0.0, right: 0.0),
                    child: Container(
                      padding:
                      EdgeInsets.only(left: 18.0, top: 15.0, bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                new FutureBuilder(
                                    future: result,
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ]));
  }
}

class AudioTransResult extends StatelessWidget {
  AudioTransResult({this.result});

  final Future<String> result;

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Card(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AspectRatio(
                    aspectRatio: 18.0 / 9.0,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new FutureBuilder(
                              future: result,
                              builder: (context, snapshot) {
                                var data = snapshot.data;

                                if (data == null) {
                                  return CircularProgressIndicator();
                                }

                                return new Text(
                                  data.toString(),
                                  style: new TextStyle(
                                    fontSize: 20.0,
                                  ),
                                  softWrap: true,
                                );
                              }),
                        ])),
              ])),
    );
  }
}