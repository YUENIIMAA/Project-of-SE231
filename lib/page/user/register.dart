import 'package:flutter/material.dart';
import 'package:intellispot/model/user.dart';
import 'package:intellispot/component/dialog.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();
  String _username, _password, _2ndpassword,_userphone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("注册"),
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
            SizedBox(height: 16.0),
            buildUsernameTextField(),
            SizedBox(height: 16.0),
            buildUserphoneTextField(),
            SizedBox(height: 16.0),
            buildPasswordTextField(context),
            SizedBox(height: 16.0),
            build2ndPasswordTextField(context),
            SizedBox(height: 32.0),
            buildRegisterButton(context),
            SizedBox(height: 32.0),
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

  TextFormField buildUserphoneTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '手机号',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return '手机号不能为空';
        }
      },
      onSaved: (String value) => _userphone = value,
    );
  }

  TextFormField buildPasswordTextField(BuildContext context) {
    return TextFormField(
      onSaved: (String value) => _password = value,
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty) {
          return '密码不能为空';
        }
      },
      decoration: InputDecoration(
        labelText: '密码',
      ),
    );
  }

  TextFormField build2ndPasswordTextField(BuildContext context) {
    return TextFormField(
      onSaved: (String value) => _2ndpassword = value,
      obscureText: true,
      validator: (String value) {
        /*if (value.compareTo(_password) == 1) {
          return '两次密码不匹配';
        }*/
      },
      decoration: InputDecoration(
        labelText: '确认密码',
      ),
    );
  }

  Align buildRegisterButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45.0,
        width: 270.0,
        child: RaisedButton(
          child: Text(
            '注册',
            style: Theme.of(context).primaryTextTheme.headline,
          ),
          color: Colors.cyan,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              registerUser();
            }
          },
          shape: StadiumBorder(side: BorderSide()),
        ),
      ),
    );
  }

  void registerUser() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: '正在注册...',
          );
        },
      );
      print('try register');
      final userModel = UserModel().of(context);
      userModel.initDio();
      Response<String> response = await userModel.dio.post("/user/register", data: {
        "username": _username,
        "password": _password,
        "telephone": _userphone,
        "nickname": _username});
      if(response.statusCode==200) {
        Navigator.of(context).pop();
        Map<String, dynamic> responseData = jsonDecode(response.data);
        print ("${responseData["code"]}");
        if (responseData["code"] == 1) {
          print("register success!");
          try {
            print('now try sign in');
            FormData formData = new FormData.from({
              "username": _username,
              "password": _password,
              "grant_type": "password",
            });
            Response<String> response = await userModel.dio.post("/auth/oauth/token", data: formData);
            if(response.statusCode==200) {
              print("login success!");
              Map<String, dynamic> responseData = jsonDecode(response.data);
              print(responseData["access_token"]);
              userModel.setAuthKey(responseData["access_token"]);
              userModel.setUser(_username, _password, _userphone, _username);
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
              Navigator.pushReplacementNamed(context, '/home');
            }
          } catch (e) {
            print(e);
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: new Text("注册成功但登录失败"),
                  content: new Text("请回到登录界面重新尝试登录"),
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
        else {
          print(responseData["message"]);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("注册失败"),
                content: new Text(responseData["message"]),
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
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("注册失败"),
            content: new Text("错误：" + e.toString()),
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
            Text('已有账号？'),
            GestureDetector(
              child: Text(
                '点此登录',
                style: TextStyle(color: Colors.cyan),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
                print('去注册');
              },
            ),
          ],
        ),
      ),
    );
  }
}