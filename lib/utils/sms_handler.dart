import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telephony/telephony.dart';

import 'toast.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final Telephony _telephony = Telephony.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

backgrounMessageHandler(SmsMessage message) async {
  // add message body to messages collection in firestore
  if (message.body == null) {
    showToast("message body is null");
    return;
  }
  showToast("received message in background: ${message.body}");

  _updateFirebaseCollection(message.body!);
}

void _updateFirebaseCollection(String message) {
  User? user = _auth.currentUser;
  if (user == null) {
    showToast("user is null");
    return;
  }
  DocumentReference userRef = _firestore.collection("users").doc(user.uid);
  _firestore.collection("messages").add({
    "user": userRef,
    "message": message,
  }).then((value) {
    showToast("message added to firestore");
  });
}

class SmsFirebaseController {
// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await _telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      registerStartSMSListener();
    }

    // if (!mounted) return;
  }

  void registerStartSMSListener() {
    showToast('Started Listening for SMS');
    _telephony.listenIncomingSms(
      onNewMessage: onMessageReceived,
      listenInBackground: true,
      onBackgroundMessage: backgrounMessageHandler,
    );
  }

  void unregisterSmsListener() {
    showToast('STOPED Listening for SMS');
    _telephony.listenIncomingSms(
      onNewMessage: onMessageReceived,
      listenInBackground: false,
      onBackgroundMessage: null,
    );
  }

  onMessageReceived(SmsMessage message) {
    String messageBody = message.body ?? 'error reading message body';
    showToast(messageBody);
    _updateFirebaseCollection(messageBody);
  }

  void sendSMSToMe(String message) {
    var myPhoneNumber = '+972547470080';
    _telephony.sendSms(
      to: myPhoneNumber,
      message: message,
      statusListener: (status) => showToast(status.toString()),
    );
  }
}
