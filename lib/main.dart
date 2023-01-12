import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sms2email/screens/sign_in_screen.dart';
import 'package:sms2email/utils/toast.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseUIAuth.configureProviders([
  //   EmailAuthProvider(),
  // ]);

  runApp(const MyApp());
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _smsListenerEnabled = true;
  User? _user;
  // This widget is the root of your application.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkUserLogin();
    // if (_smsListenerEnabled) {
    //   _startSMSListener();
    // }
  }

  void _checkUserLogin() async {
    // _user = await _auth.currentUser;
    if (_user == null) {
      // Redirect to login page
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: _user == null ? LoginPage() : MyHomePage(user: _user!),
    );
  }

  void _startSMSListener() {}
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title = 'Sms2Email', required this.user});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final User user;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _handleSignOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    showToast("signed out");
    // navigate to login page, without stack
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text('Hello ${widget.user.displayName}'),
            Text('${widget.user.email}'),
            ElevatedButton(
              onPressed: _handleSignOut,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
