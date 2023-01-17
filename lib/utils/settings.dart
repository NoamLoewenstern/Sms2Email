import 'package:shared_preferences/shared_preferences.dart';

class SimplePrefs {
  static final SimplePrefs _instance = SimplePrefs._internal();
  static late SharedPreferences _prefs;

  // private constructor
  SimplePrefs._internal() {
    init();
  }

  factory SimplePrefs() {
    return _instance;
  }

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get allowedSMSPermission {
    return _prefs.getBool('allowedSMSPermission') ?? false;
  }

  set allowedSMSPermission(bool value) {
    _prefs.setBool('allowedSMSPermission', value);
  }

  bool get shouldListen2SMSInBG {
    return _prefs.getBool('shouldListen2SMSInBG') ?? false;
  }

  set shouldListen2SMSInBG(bool value) {
    _prefs.setBool('shouldListen2SMSInBG', value);
  }
}

final prefs = SimplePrefs();
