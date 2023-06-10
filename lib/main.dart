import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackminder/screens/login_screen.dart';
import 'package:trackminder/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
  String appId = dotenv.env['FIREBASE_APP_ID'] ?? '';
  String messagingSenderId = dotenv.env['FIREBASE_MSG_SENDER_ID'] ?? '';
  String projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId));

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;
    if (rememberMe) {
      String? email = prefs.getString('email');
      String? password = prefs.getString('password');
      if (email != null && password != null) {
        // You can perform any additional authentication here if needed,
        // such as validating the email and password against a server.
        setState(() {
          _isLoggedIn = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track Minder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _isLoggedIn ? const MainScreen() : const LogInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
