import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intellispot/home.dart';
import 'package:intellispot/model/user.dart';
import 'package:intellispot/page/user/login.dart';
import 'package:intellispot/page/user/register.dart';
import 'package:intellispot/page/user/edit_profile.dart';
import 'package:intellispot/page/map/map.dart';
import 'package:intellispot/page/translation/audio.dart';


void main() async {
  runApp(new InitPage());
}

class InitPage extends StatelessWidget{

  UserModel userModel = UserModel();

  @override
  Widget build(BuildContext context){

    userModel.initDio();

    return ScopedModel<UserModel>(
      model: userModel,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        //initialRoute: '/login',
        initialRoute: '/',
        routes: {
          //'/': (context) => HomePage(),
          '/': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/profile': (context) => ProfilePage(),
          '/map': (context) => MapPage(),
          '/audio': (context) => AudioTranslationPage(),
        },
      ),
    );
  }
}