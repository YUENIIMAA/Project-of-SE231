import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:intellispot/page/home/article.dart';

class InstaBody extends StatefulWidget {
  @override
  InstaBodyState createState() => new InstaBodyState();
}

class InstaBodyState extends State<InstaBody> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(child: ArticlePage())
        ],
      ),
    );
  }


}