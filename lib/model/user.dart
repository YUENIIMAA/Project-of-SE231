import 'package:scoped_model/scoped_model.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class UserModel extends Model {
  bool _isSignedIn = false;
  bool _isInit = false;
  String _username = "";
  String _password = "";
  String _phonenumber = "";
  String _nickname = "";
  String _authorizationKey = "";
  bool _isVip=false;
  String _vipTime="";
  var dio = new Dio();

  notifyListeners();

  void initDio() {
    if (!_isInit) {
      dio.interceptors.add(CookieManager(CookieJar()));
      dio.options.baseUrl ="http://47.100.191.229";
      //ALIYUN ZLF:http://47.100.191.229"
      //SE 3107 ZLF:http://192.168.1.64
      //SE 3107 ZYQ:http://192.168.1.243
      //SE 3107 FWT:http://192.168.1.10:8080
      //D19 110 ZYQ:http://192.168.31.251
      dio.options.connectTimeout = -1;
      dio.options.receiveTimeout = -1;
      dio.options.headers = {
        "Authorization": "Basic YW5kcm9pZDphbmRyb2lk",
      };
      _isInit = true;
    }
  }

  void setUser(String username, String password, String phonenumber, String nickname) {
    _username = username;
    _password = password;
    _phonenumber = phonenumber;
    _nickname = nickname;
    _isSignedIn = true;
  }

  void clearUser() {
    _username = "";
    _password = "";
    _phonenumber = "";
    _nickname = "";
    _isInit = false;
    _isVip = false;
    _isSignedIn = false;
    dio.clear();
  }

  void setVip(String time){
    _isVip=true;
    _vipTime=time;
  }

  UserModel of(context) =>
      ScopedModel.of<UserModel>(context);

  void setAuthKey(String authKey) {
    _authorizationKey = "Bearer " + authKey;
    dio.options.headers = {
      "Authorization": _authorizationKey,
    };
  }

  void clearAuthKey() {
    _authorizationKey = "";
    dio.options.headers = {
      "Authorization": "Basic YW5kcm9pZDphbmRyb2lk",
    };
  }

  String get nickname => _nickname;

  set nickname(String value) {
    _nickname = value;
  }

  String get phonenumber => _phonenumber;

  set phonenumber(String value) {
    _phonenumber = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get username => _username;

  set username(String value) {
    _username = value;
  }


  bool get isVip => _isVip;

  set isVip(bool value) {
    _isVip = value;
  }

  bool get isSignedIn => _isSignedIn;

  String get vipTime => _vipTime;


  String get authorizationKey => _authorizationKey;

  set authorizationKey(String value) {
    _authorizationKey = value;
  }

  set vipTime(String value) {
    _vipTime = value;
  }
}