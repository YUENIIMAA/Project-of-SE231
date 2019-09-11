import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intellispot/model/user.dart';
import 'package:intellispot/component/dialog.dart';
import 'package:tobias/tobias.dart' as tobias;

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    fetchDataThenShow(context);
                  },
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      _buildUserTile(context),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Card(
            child: Column(
              children: <Widget>[
                _buildSettingsTile(context),
                _buildVipTile(context),
                //_buildHelpTile(context),
                //_buildFeedTile(context),
                _buildAboutTile(context),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserTile(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
        rebuildOnChange: true,
        builder: (context, child, model) {
          return ListTile(
            //leading: Icon(Icons.chrome_reader_mode),
            leading: Image.asset('assets/diamond.png'),
            title: Text(model.username, style: new TextStyle(fontSize: 30)),
            subtitle: Text('查看或编辑资料'),
            trailing: Icon(Icons.chevron_right),
          );
        });
  }

  Widget _buildSettingsTile(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.settings),
        title: Text('设置'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (BuildContext context) {
                return new SettingPage();
              }));
        });
  }

  Widget _buildVipTile(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.vpn_key),
        title: Text('会员'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (BuildContext context) {
                return new VipPage();
              }));
        });
  }

  Widget _buildHelpTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.help_outline),
      title: Text('帮助'),
      trailing: Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildFeedTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.bug_report),
      title: Text('反馈'),
      trailing: Icon(Icons.chevron_right),
      //onTap: () => _handleSettingsAction(context),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.info_outline),
      title: Text('关于'),
      trailing: Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context)
              .push(new MaterialPageRoute<void>(builder: (BuildContext context) {
            return new Scaffold(
                appBar: new AppBar(title: Text("关于智景"),backgroundColor: Colors.cyan),
                body: ListView(
                  children: <Widget>[
                    ListTile(
                      title: Text('版本号'),
                      subtitle: Text('1.1'),
                    ),
                    ListTile(
                      title: Text('发布日期'),
                      subtitle: Text('2019.09.08'),
                    ),
                    ListTile(
                      title: Text('开发者'),
                      subtitle: Text('SE231 Team 25'),
                    ),
                  ],
                    ));
          }));
        }
      //onTap: () => _handleSettingsAction(context),
    );
  }

  Align buildLogoutButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45.0,
        width: 270.0,
        child: RaisedButton(
          child: Text(
            '退出登录',
            style: Theme.of(context).primaryTextTheme.title,
          ),
          color: Colors.redAccent,
          onPressed: () {
            final userModel = UserModel().of(context);
            userModel.clearUser();
            Navigator.pushReplacementNamed(context, '/login');
            print('登出');
          },
          //shape: StadiumBorder(side: BorderSide()),
        ),
      ),
    );
  }

  void fetchDataThenShow(BuildContext context) async {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new LoadingDialog(
          text: '正在加载信息...',
        );
      },
    );
    try {
      final userModel = UserModel().of(context);
      userModel.dio.options.connectTimeout = 5000;
      userModel.dio.options.receiveTimeout = 3000;
      Response<String> response =
      await userModel.dio.get("/user/view-nickname");
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.data);
        print("${responseData["data"]}");
        Navigator.of(context).pop();
        userModel.nickname = responseData["data"];
        Navigator.of(context).pushNamed('/profile');
      }
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("信息加载失败"),
            content: new Text("错误原因：" + e.toString()),
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

class VipPage extends StatefulWidget {
  @override
  State<VipPage> createState() => VipPageState();
}

class VipPageState extends State<VipPage> {
  List _names = ["年度会员", "季度会员", "月度会员", "周度会员"];
  List _prices = [148, 68, 25, 15];
  int currentType = 0;

  String _payInfo = "";

  @override
  void initState() {
    super.initState();
    _loadData(_prices[currentType].toString());
    _getVip();
    _getVipTime();
  }

  Widget _buildUserTile(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
        rebuildOnChange: true,
        builder: (context, child, model) {
          // var deviceSize = MediaQuery.of(context).size;
          return Card(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(30, 20, 20, 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Container(
                                  height: 40.0,
                                  width: 40.0,
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image:
                                        ExactAssetImage('assets/diamond.png'),
                                      ))),
                              new SizedBox(width: 50.0),
                              new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    new Text(model.username,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                    model.isVip
                                        ? new Text("VIP会员状态：已开通",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.grey))
                                        : new Text("VIP会员状态：尚未开通",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.grey)),
                                    model.isVip
                                        ? new Text(
                                        "过期时间：" + model.vipTime.toString(),
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.grey))
                                        : new Text("")
                                  ])
                            ]))
                  ]));
        });
  }

  Widget _buildGrid(BuildContext context) {
    return Expanded(
        flex: 1,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.0 //显示区域宽高相等
            ),
            itemCount: _names.length,
            itemBuilder: (context, index) {
              return InkWell(
                  child: Card(
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_names[index],
                                    style: TextStyle(
                                        fontSize: 30, fontWeight: FontWeight.bold)),
                                Text(_prices[index].toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyan))
                              ]))),
                  onTap: () {
                    setState(() {
                      currentType = index;
                      _loadData(_prices[currentType].toString());
                    });
                    print(currentType);
                  });
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("会员"),
          backgroundColor: Colors.cyan,
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildUserTile(context),
          _buildGrid(context),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: SizedBox(
                  height: 45.0,
                  width: 270.0,
                  child: RaisedButton(
                      child: Text(
                        "支付" + _prices[currentType].toString() + "元开通",
                        style: Theme.of(context).primaryTextTheme.headline,
                      ),
                      color: Colors.cyan,
                      onPressed: () {
                        print("");
                        //_loadData(_prices[currentType].toString()).then(callAlipay());
                        callAlipay();
                      })))
        ]));
  }

  Future _loadData(String fee) async {
    _payInfo = "";

    Response response;
    final userModel = UserModel().of(context);
    userModel.initDio();

    response = await userModel.dio.post("/user/buy", data: {"money": fee});
    setState(() {
      _payInfo = response.data.toString();
      print("???");
      print(_payInfo);
    });
    return;
  }

  Future _notify(String order) async {
    Response response;
    final userModel = UserModel().of(context);
    userModel.initDio();

    response =
    await userModel.dio.post("/user/notify", data: {"orderId": order});
    String time = await _getVipTime();
    setState(() {
      userModel.setVip(time);
    });
    return;
  }

  _getVip() async {
    try {
      Response response;
      final userModel = UserModel().of(context);
      userModel.initDio();

      response = await userModel.dio.get("/user/view-is-vip");

      if (response.statusCode == 200) {
        print(response.data);
        if (response.data["data"] == true) {
          print("here");
          String time = await _getVipTime();
          setState(() {
            userModel.setVip(time);
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> _getVipTime() async {
    try {
      Response response;

      final userModel = UserModel().of(context);
      userModel.initDio();

      response = await userModel.dio.get("/user/view-vip-due-time");

      if (response.statusCode == 200) {
        print(response.data);
        //String result = response.data.toString();
        return response.data["data"];
      }
    } catch (e) {
      print(e);
      return "";
    }
  }

  callAlipay() async {
    Map payResult;

    try {
      print("The pay info is : " + _payInfo);

      //Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.phone]);

      payResult = await tobias.pay(_payInfo);

      print("--->$payResult");

      var r = json.decode(payResult["result"]);

      String orderId = r["alipay_trade_app_pay_response"]["out_trade_no"];
      print(orderId);
      _notify(orderId);
    } on Exception catch (e) {
      payResult = {};
    }

    if (!mounted) return;

    setState(() {
      print(payResult);
    });
  }
}

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("设置"),backgroundColor: Colors.cyan),
        body: Column(children: [
          ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('删除翻译记录'),
            onTap: () {
              deleteTranslation();
              showDialog<Null>(
                context: context,
                builder: (BuildContext context) {
                  return new Dialog(
                      child: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                          child: (Text("删除成功"))));
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('删除识别记录'),
            onTap: () {
              deleteRecognition();
              showDialog<Null>(
                context: context,
                builder: (BuildContext context) {
                  return new Dialog(
                      child: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                          child: (Text("删除成功"))));
                },
              );
            },
          )
        ]));
  }

  deleteTranslation() async {
    try {
      Response response;

      final userModel = UserModel().of(context);
      userModel.initDio();
      response = await userModel.dio.post("/translation/delete-history");
    } catch (e) {
      print(e);
      return null;
    }
  }

  deleteRecognition() async {
    try {
      Response response;

      final userModel = UserModel().of(context);
      userModel.initDio();
      response = await userModel.dio.post("/recognition/delete-history");
    } catch (e) {
      print(e);
      return null;
    }
  }
}
