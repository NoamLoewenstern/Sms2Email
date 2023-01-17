import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sms2email/screens/home_screen.dart';
import 'package:sms2email/screens/sign_in_screen.dart';
import 'package:sms2email/utils/settings.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await prefs.init();

  if (kDebugMode) {
    try {
      print('USING EMULATORS');
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sms2Email',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: user != null ? HomePage(user: user!) : const LoginPage(),
    );
  }
}
