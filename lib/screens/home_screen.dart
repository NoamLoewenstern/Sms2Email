import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/auth.dart';
import '../utils/settings.dart';
import '../utils/sms_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.title = 'Sms2Email', required this.user});

  final User user;
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _isSmsListenerEnabled = prefs.shouldListen2SMSInBG;
  bool _hasSMSPermissions = hasSMSPermissions();
  String recentSMS = prefs.recentSMS ?? 'No recent SMS';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSmsListenerState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _loadSmsListenerState() async {
    await toggleSmsListenerState(_isSmsListenerEnabled);
  }

  Future<void> handleOnChangeSmsListenerState(bool smsState) async {
    setState(() {
      _isSmsListenerEnabled = smsState;
    });
    await toggleSmsListenerState(smsState);
  }

  void _handleSignOut() async {
    await Authentication.signOut(context: context);
    // navigate to login page, without stack
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyApp()),
          (Route<dynamic> route) => false);
    });
  }

  onRequestSMSPermission() async {
    await assureHasSMSPermissions();
    setState(() {
      _hasSMSPermissions = hasSMSPermissions();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      return;
    }
    if (prefs.recentSMS != null && prefs.recentSMS != recentSMS) {
      setState(() {
        recentSMS = prefs.recentSMS ?? 'No recent SMS';
      });
    }
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
            _hasSMSPermissions
                ? const Text('SMS Permission Granted')
                : ElevatedButton(
                    onPressed: onRequestSMSPermission,
                    child: const Text('Request SMS Permission'),
                  ),
            Text('Recent SMS: $recentSMS'),
          ],
        ),
      ),
    );
  }
}
