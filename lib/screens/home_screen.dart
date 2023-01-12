import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms2email/utils/toast.dart';

import '../main.dart';
import '../utils/sms_handler.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title = 'Sms2Email', required this.user});

  final User user;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isSmsListenerEnabled = true;
  final SmsFirebaseController smsFirebaseController = SmsFirebaseController();
  final StreamController<bool> _controllerChangeSmsState =
      StreamController<bool>();

  @override
  void initState() {
    super.initState();
    smsFirebaseController.initPlatformState();
    _controllerChangeSmsState.stream.listen(onSmsListenerStateChange);
    _loadSmsListenerState();
  }

  @override
  void dispose() {
    _controllerChangeSmsState.close();
    super.dispose();
  }

  void onSmsListenerStateChange(bool smsState) async {
    showToast("sms listener state changed to $smsState");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('_isSmsListenerEnabled', smsState);
    if (smsState) {
      smsFirebaseController.registerStartSMSListener();
    } else {
      smsFirebaseController.unregisterSmsListener();
    }
  }

  _loadSmsListenerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool smsState = prefs.getBool('_isSmsListenerEnabled') ?? false;
    setState(() {
      _isSmsListenerEnabled = smsState;
      _controllerChangeSmsState.add(smsState);
    });
  }

  void _handleSignOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    showToast("signed out");
    smsFirebaseController.unregisterSmsListener();

    // navigate to login page, without stack
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyApp()),
        (Route<dynamic> route) => false);
  }

  void handleOnChangeSmsListenerState(bool smsState) {
    setState(() {
      _isSmsListenerEnabled = smsState;
      _controllerChangeSmsState.add(smsState);
    });
  }

  void _handleSendSms() {
    smsFirebaseController.sendSMSToMe('test');
  }

  void _requestSMSPermission() {
    smsFirebaseController.initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text('Hello ${widget.user.displayName}'),
            Text('${widget.user.email}'),
            ElevatedButton(
              onPressed: _handleSignOut,
              child: const Text('Sign Out'),
            ),
            Switch(
              value: _isSmsListenerEnabled,
              onChanged: handleOnChangeSmsListenerState,
            ),
            ElevatedButton(
              onPressed: _handleSendSms,
              child: const Text('Send SMS'),
            ),
            ElevatedButton(
              onPressed: _requestSMSPermission,
              child: const Text('Request SMS Permission'),
            ),
          ],
        ),
      ),
    );
  }
}
