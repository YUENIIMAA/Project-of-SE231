import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dio/dio.dart';
import 'package:intellispot/model/user.dart';
import 'package:intellispot/component/dialog.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  String _usernickname;

  @override
  void initState() {
    final userModel = UserModel().of(context);
    _usernickname = userModel.nickname;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("编辑个人信息"),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        children: <Widget>[
          _buildNicknameTile(context),
          _buildPasswordTile(context),
        ],
      ),
    );
  }

  Widget _buildNicknameTile(BuildContext context)  {
    TextEditingController _newnickname = TextEditingController();
    return ScopedModelDescendant<UserModel>(
        rebuildOnChange: true,
        builder: (context, child, model) {
          return ListTile(
            title: Text('昵称'),
            subtitle: Text(_usernickname),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: new Text("修改昵称"),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          TextField(
                            controller: _newnickname,
                            decoration: InputDecoration(hintText: "在此输入新的昵称"),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("取消"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      new FlatButton(
                        child: new Text("确定"),
                        onPressed: () {
                          print(_newnickname.text);
                          Navigator.of(context).pop();
                          setNickname(_newnickname.text);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        }
    );
  }

  void setNickname(String newNickname) async{
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new LoadingDialog(
          text: '正在保存更改...',
        );
      },
    );
    try {
      final userModel = UserModel().of(context);
      //userModel.dio.options.baseUrl = "http://192.168.1.110:8080";// SE 3107
      //userModel.dio.options.baseUrl = "http://192.168.31.251";// D19 110
      //userModel.dio.options.connectTimeout = 5000; //5s
      //userModel.dio.options.receiveTimeout = 3000;
      Response<String> response = await userModel.dio.post("/user/modify-nickname", data: {
        "nickname": newNickname
      });
      if(response.statusCode==200) {
        print("modify success!");
        print(response.data);
        setState(() {
          userModel.nickname = newNickname;
          _usernickname = newNickname;
        });
        Navigator.of(context).pop();
      }
    } catch(e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("修改失败"),
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

  Widget _buildPasswordTile(BuildContext context)  {
    TextEditingController _oldpassword = new TextEditingController();
    TextEditingController _newpassword = new TextEditingController();
    TextEditingController _2ndnewpassword = new TextEditingController();
    return ScopedModelDescendant<UserModel>(
        rebuildOnChange: true,
        builder: (context, child, model) {
          return ListTile(
            title: Text('密码'),
            subtitle: Text("******"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: new Text("修改密码"),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          TextField(
                            controller: _oldpassword,
                            decoration: InputDecoration(hintText: "旧密码"),
                            obscureText: true,
                          ),
                          TextField(
                            controller: _newpassword,
                            decoration: InputDecoration(hintText: "新密码"),
                            obscureText: true,
                          ),
                          TextField(
                            controller: _2ndnewpassword,
                            decoration: InputDecoration(hintText: "确认新密码"),
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("取消"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      new FlatButton(
                        child: new Text("确定"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          setPassword(_oldpassword.text, _newpassword.text, _2ndnewpassword.text);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        }
    );
  }

  void setPassword(String oldpwd, String newpwd, String newpwd2nd) async{
    if (newpwd != newpwd2nd) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("修改失败"),
            content: new Text("两次密码输入不一致"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("知道了"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    else if (oldpwd == newpwd) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("修改失败"),
            content: new Text("旧密码与新密码重复"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("知道了"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    else {
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: '正在保存更改...',
          );
        },
      );
      try {
        final userModel = UserModel().of(context);
        //userModel.dio.options.baseUrl = "http://192.168.1.110:8080";// SE 3107
        //userModel.dio.options.baseUrl = "http://192.168.31.251";// D19 110
        //userModel.dio.options.connectTimeout = 5000; //5s
        //userModel.dio.options.receiveTimeout = 3000;
        Response<String> response = await userModel.dio.post("/user/modify-password", data: {
          "oldPassword": oldpwd,
          "newPassword": newpwd
        });
        if(response.statusCode==200) {
          print("modify success!");
          userModel.password = newpwd;
          Navigator.of(context).pop();
        }
      } catch(e) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("修改失败"),
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
  }
}