import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_device/safe_device.dart';

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

  String? get fbUserUID {
    return _prefs.getString('fbUserUID');
  }

  set fbUserUID(String? value) {
    if (value == null) {
      _prefs.remove('fbUserUID');
    } else {
      _prefs.setString('fbUserUID', value);
    }
  }

  String? get recentSMS {
    return _prefs.getString('recentSMS');
  }

  set recentSMS(String? value) {
    if (value == null) {
      _prefs.remove('recentSMS');
    } else {
      _prefs.setString('recentSMS', value);
    }
  }
}

// check if running on local avd, or phiysical device

Future<bool> isAndroidEmulator() async {
  return !await SafeDevice.isRealDevice;
  // if (Platform.isAndroid) {
  //   return Platform.environment['ANDROID_EMULATOR'] == 'true';
  // }
  // return false;
}

final prefs = SimplePrefs();
