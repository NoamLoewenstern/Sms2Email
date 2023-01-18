import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sms2email/utils/auth.dart';
import 'package:sms2email/utils/toast.dart';

import '../main.dart';
import 'home_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _handleSignIn(BuildContext context) async {
    User? user = await Authentication.signInWithGoogle(context: context);
    if (user == null) {
      showToast('Sign in failed');
      return;
    }
    await Authentication.signInWithGoogle(context: context);
    // navigate to login page, without stack
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushAndRemoveUntil(
          // MaterialPageRoute(builder: (context) => HomePage(user: user)),
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Please sign in'),
            ElevatedButton(
              onPressed: () => _handleSignIn(context),
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
