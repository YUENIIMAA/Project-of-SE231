import 'package:flutter/material.dart';
import 'package:intellispot/model/user.dart';
import 'package:dio/dio.dart';
import 'package:intellispot/component/dialog.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  String _username, _password;
  bool _hidePwd = true;
  Color _eyeColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("登录"),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 22.0),
          children: <Widget>[
            SizedBox(height: 16.0),
            buildTitle(),
            SizedBox(height: 32.0),
            buildUsernameTextField(),
            SizedBox(height: 16.0),
            buildPasswordTextField(context),
            SizedBox(height: 48.0),
            buildLoginButton(context),
            SizedBox(height: 48.0),
            buildRegisterText(context),
          ],
        ),
      ),
    );
  }

  Padding buildTitle() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        '欢迎使用智景',
        style: TextStyle(fontSize: 32.0),
      ),
    );
  }

  TextFormField buildUsernameTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '用户名',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return '用户名不能为空';
        }
      },
      onSaved: (String value) => _username = value,
    );
  }

  TextFormField buildPasswordTextField(BuildContext context) {
    return TextFormField(
      onSaved: (String value) => _password = value,
      obscureText: _hidePwd,
      validator: (String value) {
        if (value.isEmpty) {
          return '密码不能为空';
        }
      },
      decoration: InputDecoration(
          labelText: '密码',
          suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                setState(() {
                  _hidePwd = !_hidePwd;
                  _eyeColor = _hidePwd
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color;
                });
              })),
    );
  }

  Align buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45.0,
        width: 270.0,
        child: RaisedButton(
          child: Text(
            '登录',
            style: Theme.of(context).primaryTextTheme.headline,
          ),
          color: Colors.cyan,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              verifyUser();
            }
          },
          shape: StadiumBorder(side: BorderSide()),
        ),
      ),
    );
  }

  void verifyUser() async {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new LoadingDialog(
          text: '正在登录...',
        );
      },
    );
    try {
      print('try sign in');
      final userModel = UserModel().of(context);
      FormData formData = new FormData.from({
        "username": _username,
        "password": _password,
        "grant_type": "password",
      });
      userModel.initDio();
      Response<String> response = await userModel.dio.post("/auth/oauth/token", data: formData);
      if(response.statusCode==200) {
        print("login success!");

        Map<String, dynamic> responseData = jsonDecode(response.data);
        Navigator.of(context).pop();
        print(responseData["access_token"]);
        userModel.setAuthKey(responseData["access_token"]);
        userModel.setUser(_username, _password, "", "");
        //检查是否是vip
        try {
          Response checkVip;
          checkVip = await userModel.dio.get("/user/view-is-vip");
          if (checkVip.statusCode == 200) {
            print(checkVip.data);
            if (checkVip.data['data'] == true) {
              print("here");
              userModel.isVip = true;
            }
          }
        } catch (e) {
          print(e);
        }
        //检查是否是vip
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("登录失败"),
            content: new Text("请检查您的用户名和密码"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("好的"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Align buildRegisterText(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('没有账号？'),
            GestureDetector(
              child: Text(
                '点此注册',
                style: TextStyle(color: Colors.cyan),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}