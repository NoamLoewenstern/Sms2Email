import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sms2email/utils/auth.dart';

import 'home_screen.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['openid']);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<User?> _handleSignIn({required BuildContext context}) async {
    User? user = await Authentication.signInWithGoogle(context: context);
    if (user != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              user: user,
            ),
          ),
        );
      });
    }
    return user;
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
              onPressed: () => _handleSignIn(context: context),
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
