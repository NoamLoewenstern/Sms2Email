import 'dart:async';

import 'package:flutter_broadcasts/flutter_broadcasts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sms2email/utils/settings.dart';
import 'package:telephony/telephony.dart';
import 'package:sms_receiver/sms_receiver.dart';

import '../firebase_options.dart';
import 'toast.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final Telephony telephony = Telephony.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

Future<void> printCurrentMessages(String msgId) async {
  // List<SmsMessage> messages = await telephony.getInboxSms(
  //     columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
  //     filter: SmsFilter.where(SmsColumn.ADDRESS)
  //         .equals("1234567890")
  //         .and(SmsColumn.BODY)
  //         .like("starwars"),
  //     sortOrder: [
  //       OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
  //       OrderBy(SmsColumn.BODY)
  //     ]);
  List<SmsMessage> messages = await telephony.getInboxSms(columns: [
    SmsColumn.ADDRESS,
    SmsColumn.BODY,
    SmsColumn.ID,
    SmsColumn.DATE
  ],
      // filter: SmsFilter.where(SmsColumn.ADDRESS)
      //     .equals("1234567890")
      //     .and(SmsColumn.BODY)
      //     .like("starwars"),
      sortOrder: [
        OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
        OrderBy(SmsColumn.DATE),
        OrderBy(SmsColumn.BODY)
      ]);
  for (var element in messages) {
    print("id: ${element.id}, date: ${element.date}");
    // "address: ${element.address}, body: ${element.body}, id: ${element.id}, date: ${element.date}");
    if (msgId == element.id) {
      print("===== FOUND message with id: $msgId");
    }
  }
}

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

void onMessageReceivedHandler(SmsMessage message) async {
  // add message body to messages collection in firestore
  if (message.body == null) {
    // showToast("message body is null");
    return;
  }
  // showToast("received message in background: ${message.body}");
  prefs.recentSMS = message.body;
  _addMessageToCollection(message);
}

void _addMessageToCollection(SmsMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

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

BroadcastReceiver receiver = BroadcastReceiver(
  names: <String>[
    "android.provider.Telephony.SMS_RECEIVED",
  ],
);

final _smsReceiver = SmsReceiver(onSmsReceived, onTimeout: onTimeout);

void onTimeout() {
  // showToast("onTimeout");
  print("!!onTimeout");
}

bool isListening = false;
void _startListening() async {
  if (isListening) return;
  await _smsReceiver.startListening();
  isListening = true;
}

void _stopListening() async {
  if (!isListening) return;
  await _smsReceiver.stopListening();
  isListening = false;
}

void onSmsReceived(String? message) {
  print(message);
  print(message);
}

void onMessageEventReceivedHandler(BroadcastMessage event) async {
  // add message body to messages collection in firestore
  if (event.data == null) {
    showToast("message body is null");
    return;
  }
  // SmsMessage.fromMap(rawMessage, columns)
  // event.data?.entries.expand((element) => print(element))
  var data = event.toMap()['data'];
  var pdus = data['pdus'];
  event.data?.entries.toList().forEach((element) {
    // if (element.key == "messageId") {
    //   print('messageId: ${element.value}');
    // }
    print("${element.key} = ${element.value}");
  });

  var messageId = event.toMap()['data']['messageId'];
  // printCurrentMessages(messageId.toString());
  // event.toMap()['data'].toString()
  // event.data.values;
  // event.data?.entries.forEach((key, value) => {
  //       showToast("key: $key, value: $value"),
  // })
  // event.data.VALUES.toString();
  // event.data.entries.messageId
  // event.data.source
  // event.data._source
  showToast("received message in background: ${event.data}");

  // _addMessageToCollection(event.data);
}

Future<void> registerStartSMSListener() async {
  await assureHasSMSPermissions();
  showToast('Started Listening for SMS');
  prefs.shouldListen2SMSInBG = true;

  telephony.listenIncomingSms(
    onNewMessage: onMessageReceivedHandler,
    listenInBackground: true,
    onBackgroundMessage: onMessageReceivedHandler,
  );

  // if (!receiver.isListening) {
  //   receiver.start();
  //   // receiver.toMap();
  //   receiver.messages.listen(onMessageEventReceivedHandler);
  // }
  // _startListening();
}

Future<void> unregisterSmsListener() async {
  // if (!receiver.isListening) {
  //   receiver.stop();
  // }
  // _stopListening();
  await assureHasSMSPermissions();
  showToast('STOPED Listening for SMS');
  prefs.shouldListen2SMSInBG = false;

  telephony.listenIncomingSms(
    onNewMessage: (SmsMessage message) => {},
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
