import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms2email/utils/settings.dart';
import 'package:telephony/telephony.dart';

import 'toast.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final Telephony telephony = Telephony.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

// Platform messages are asynchronous, so we initialize in an async method.
Future<bool> initSMSPlatformState() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  if (hasSMSPermissions()) {
    return true;
  }
  try {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      // registerStartSMSListener();
      prefs.allowedSMSPermission = true;
      return true;
    } else {
      return false;
    }
  } catch (e) {
    showToast("error requesting permissions: $e");
    rethrow;
  }
}

var assureHasSMSPermissions = initSMSPlatformState;
var hasSMSPermissions = () => prefs.allowedSMSPermission;

backgrounOnSMSMessageHandler(SmsMessage message) async {
  // add message body to messages collection in firestore
  if (message.body == null) {
    showToast("message body is null");
    return;
  }
  showToast("received message in background: ${message.body}");

  _addMessageToCollection(message);
}

void onMessageReceived(SmsMessage message) {
  String messageBody = message.body ?? 'error reading message body';
  showToast(messageBody);
  _addMessageToCollection(message);
}

void _addMessageToCollection(SmsMessage message) {
  User? user = auth.currentUser;
  if (user == null) {
    showToast("user is null");
    return;
  }
  String createdAt = message.date != null
      ? DateTime(message.date!).toIso8601String()
      : DateTime.now().toIso8601String();

  firestore.collection("users").doc(user.uid).collection('messages').add({
    'sender': message.address ?? '',
    'text': message.body ?? '',
    'createdAt': createdAt,
  }).then((value) {
    showToast("$message added to firestore");
  });
}

Future<void> registerStartSMSListener() async {
  await assureHasSMSPermissions();
  showToast('Started Listening for SMS');
  telephony.listenIncomingSms(
    onNewMessage: onMessageReceived,
    listenInBackground: true,
    onBackgroundMessage: backgrounOnSMSMessageHandler,
  );
}

Future<void> unregisterSmsListener() async {
  await assureHasSMSPermissions();
  showToast('STOPED Listening for SMS');
  prefs.shouldListen2SMSInBG = false;
  telephony.listenIncomingSms(
    onNewMessage: (SmsMessage message) => print(message),
    listenInBackground: false,
    onBackgroundMessage: null,
  );
}

Future<void> toggleSmsListenerState(bool? smsState) async {
  smsState ??= !prefs.shouldListen2SMSInBG;
  prefs.shouldListen2SMSInBG = smsState;
  if (smsState) {
    await registerStartSMSListener();
  } else {
    await unregisterSmsListener();
  }
}
