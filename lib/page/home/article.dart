import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intellispot/model/article.dart';
import 'package:intellispot/model/user.dart';
import 'package:intellispot/page/home/slide.dart';
import 'dart:async';

class ArticlePage extends StatefulWidget {
  @override
  ArticlePageState createState() => new ArticlePageState();
}

class ArticlePageState extends State<ArticlePage> {
  List<Article> _list = [];
  Image image;

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return FutureBuilder(
        future: getArticle(),
        builder: (context, snapshot) {
          return ListView.builder(
            //reverse: true,
            itemCount: _list == null ? 1 : _list.length ,
            itemBuilder: (context, index) => /*index == 0
                ? new Column(children: [
              new SizedBox(
                child: new SlidePage(),
                height: deviceSize.height * 0.24,
              ),
              Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        new Column(children: [
                          new Icon(Icons.filter_drama),
                          new Text("天气"),
                        ]),
                        new Column(children: [
                          new Icon(Icons.local_dining),
                          new Text("饮食"),
                        ]),
                        new Column(children: [
                          new Icon(Icons.landscape),
                          new Text("景点"),
                        ]),
                        new Column(children: [
                          new Icon(Icons.directions_bus),
                          new Text("交通"),
                        ]),
                        new Column(children: [
                          new Icon(Icons.search),
                          new Text("搜索"),
                        ]),
                      ])),
            ])
                :*/ InkWell(
                onTap: () {
                  _showDetails(_list[index].title,
                      _list[index].text, _list[index].image);
                },
                child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                            padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  new Icon(Icons.arrow_right,
                                      color: Colors.blueGrey),
                                  new Text("猜你喜欢",
                                      style: TextStyle(fontSize: 16))
                                ])),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.network(
                              'http://47.100.191.229/article/get_picture?file_name=' +
                                  _list[index].image,
                            )),
                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 16.0),
                          child: Container(
                            //padding: EdgeInsets.only(bottom: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new SizedBox(
                                    width: 10.0,
                                  ),
                                  new Flexible(
                                      child: new Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                          children: [
                                            new Text(
                                              _list[index].title,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            new Text(
                                              _list[index].text,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w100),
                                            ),
                                          ]))
                                ],
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  color: Colors.blueGrey,
                                  indent: 300,
                                ),
                                Text("文 / zlf",
                                    style: TextStyle(color: Colors.grey)),
                              ]),
                        )
                      ],
                    ))),
          );
        });
  }

  void _showDetails(String title, String text, String image) {
    Navigator.of(context)
        .push(new MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("文章详情"),backgroundColor: Colors.cyan,),
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
                  padding: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Image.network(
                              'http://47.100.191.229/article/get_picture?file_name=' +
                                  image,
                            ),
                            Text(
                              title,
                              style: new TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                            Divider(),
                            Text(
                              text,
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

  getArticle() async {
    try {
      Response response;

      final userModel = UserModel().of(context);
      userModel.initDio();
      response = await userModel.dio.get("/article/view-articles");

      List<Article> list = [];

      for (int i = 0; i < response.data["data"].length; i++) {
        Article s = new Article.fromJson(response.data["data"][i]);
        list.add(s);
      }
      _list = list;
    } catch (e) {
      print(e);
      return null;
    }
  }
}