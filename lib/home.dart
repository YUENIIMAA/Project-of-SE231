import 'package:flutter/material.dart';
import 'package:intellispot/page/home/first.dart';
import 'package:intellispot/page/recognition/camera.dart';
import 'package:intellispot/page/user/settings.dart';
import 'package:intellispot/page/translation/text.dart';
import 'package:intellispot/model/user.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _cnt = 0;
  String _currentLocation = "";
  final List<Widget> _children = [
    InstaBody(),
    RecognitionPage(),
    TranslationPage(),
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    //initlocation();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("智景"),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.center_focus_strong),
            onPressed: () {
              Navigator.of(context).pushNamed('/map');
            },
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.cyan,
        items: [
          BottomNavigationBarItem(
            title: new Text("首页"),
            icon: new Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            title: new Text("识别"),
            icon: new Icon(Icons.camera),
          ),
          BottomNavigationBarItem(
            title: new Text("翻译"),
            icon: new Icon(Icons.translate),
          ),
          BottomNavigationBarItem(
            title: new Text("我的"),
            icon: new Icon(Icons.person),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}