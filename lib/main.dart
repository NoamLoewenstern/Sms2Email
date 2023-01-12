import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sms2email/screens/home_screen.dart';
import 'package:sms2email/screens/sign_in_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
  }

  void _checkUserLogin() async {
    if (_user == null) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sms2Email',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _user == null ? LoginPage() : MyHomePage(user: _user!),
    );
  }
}
