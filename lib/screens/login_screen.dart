import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackminder/screens/reset_password.dart';
import 'package:trackminder/screens/signup_screen.dart';
import 'package:trackminder/utils/color_utils.dart';

import '../utils/reusable_widgets.dart';
import 'main_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool isLoggingIn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRememberMeStatus();
  }

  void _loadRememberMeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  void _saveRememberMeStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', value);
    if (!value) {
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  void _unfocusTextFields() {
    FocusScope.of(context).unfocus();
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: _unfocusTextFields,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("20BF55"),
            hexStringToColor("01BAEF")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(children: <Widget>[
                SizedBox(
                  width: 300,
                  height: 100,
                  child: Image.asset("assets/images/logo/logo.png"),
                ),
                const SizedBox(
                  height: 50,
                ),
                reusableTextField("Enter email", Icons.person_outline, false,
                    _emailController, null),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter password", Icons.lock_outline, true,
                    _passwordController, null),
                const SizedBox(
                  height: 5,
                ),
                importantOptions(context),
                const SizedBox(
                  height: 20,
                ),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                authButtons(context, "LOG IN", () {
                  _clearError();

                  setState(() {
                    isLoggingIn = true;
                  });
                  _showLoadingAlert();

                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text)
                      .then((value) {
                    if (_rememberMe) {
                      _saveRememberMeStatus(true);
                      _saveLoginCredentials(
                          _emailController.text, _passwordController.text);
                    }

                    setState(() {
                      isLoggingIn = false;
                    });
                    _hideLoadingAlert();

                    _emailController.clear();
                    _passwordController.clear();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()));
                  }).catchError((error) {
                    setState(() {
                      isLoggingIn = false;
                    });
                    _hideLoadingAlert();

                    _showError('Invalid email or password.');
                    print("Error ${error.toString()}");
                  });
                }),
                signUpOption(),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget importantOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
              _saveRememberMeStatus(_rememberMe);
            });
          },
          child: Row(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white70,
                  checkboxTheme: CheckboxThemeData(
                    fillColor: MaterialStateProperty.all(Colors.white),
                    checkColor: MaterialStateProperty.all(Colors.black87),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                      _saveRememberMeStatus(_rememberMe);
                    });
                  },
                ),
              ),
              const Text(
                'Remember Me',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 35,
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResetPasswordScreen(),
                ),
              ),
              child: const Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveLoginCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
  }

  void _showLoadingAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.0),
                Text(
                  'Logging in...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingAlert() {
    Navigator.of(context).pop();
  }
}
