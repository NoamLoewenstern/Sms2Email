import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sms2email/screens/home_screen.dart';
import 'package:sms2email/screens/sign_in_screen.dart';
import 'package:sms2email/utils/settings.dart';
import 'firebase_options.dart';
import 'utils/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prefs.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode && await isAndroidEmulator()) {
    try {
      // print('USING EMULATORS');
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8123);
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Navigator(
          // Provide the navigator with a Key
          key: GlobalKey<NavigatorState>(),
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const WelcomeScreen(),
            );
          },
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        this.user = user;
      });
      futureRerender();
    });
    doesFirebaseUserExistRemotely().then((bool exists) async {
      if (FirebaseAuth.instance.currentUser != null && !exists) {
        await Authentication.signOut(context: context);
      }
      // futureRerender();
    });
  }

  void futureRerender() {
    Timer(
      const Duration(milliseconds: 500),
      () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              user != null ? HomePage(user: user!) : const LoginPage(),
        ),
        (Route<dynamic> route) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sms2Email',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // home: const Scaffold(
        //   body: Center(
        //     child: CircularProgressIndicator(),
        //   ),
        // ),
        home: user != null ? HomePage(user: user!) : const LoginPage());
  }
}
