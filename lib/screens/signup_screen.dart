// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/color_utils.dart';
import '../utils/reusable_widgets.dart';
import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _idNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isProfessor = false;
  final _formKey = GlobalKey<FormState>();

  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  void _unfocusTextFields() {
    FocusScope.of(context).unfocus();
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email address.';
    } else if (!_isValidEmail(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegExp.hasMatch(email);
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password.';
    } else if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    } else if (!_hasValidPasswordFormat(password)) {
      return 'Password must contain at least one letter, one number, and one special character.';
    }
    return null;
  }

  bool _hasValidPasswordFormat(String password) {
    final passwordRegExp =
        RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+{};:,<.>]).*$');
    return passwordRegExp.hasMatch(password);
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    reusableTextField(
                      'Enter email',
                      Icons.person_outline,
                      false,
                      _emailController,
                      _validateEmail,
                    ),
                    const SizedBox(height: 30),
                    reusableTextField(
                      'Enter ID number',
                      Icons.numbers_outlined,
                      false,
                      _idNumberController,
                      null,
                    ),
                    const SizedBox(height: 30),
                    reusableTextField(
                      'Enter password',
                      Icons.lock_outline,
                      true,
                      _passwordController,
                      _validatePassword,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isProfessor = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isProfessor
                                ? Colors.greenAccent
                                : Colors.white.withOpacity(0.3),
                          ),
                          icon: const Icon(
                            Icons.school,
                            color: Colors.white70,
                          ),
                          label: Text(
                            'Professor',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.9)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isProfessor = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isProfessor
                                ? Colors.greenAccent
                                : Colors.white.withOpacity(0.3),
                          ),
                          icon: const Icon(
                            Icons.school_outlined,
                            color: Colors.white70,
                          ),
                          label: Text(
                            'Student',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.9)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    authButtons(context, 'SIGN UP', () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final UserCredential userCredential =
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          final User? user = userCredential.user;

                          if (user != null) {
                            await usersCollection
                                .doc(_idNumberController.text)
                                .set({
                              'profileName': _idNumberController.text,
                              'email': _emailController.text,
                              'idNumber': _idNumberController.text,
                              'isProfessor': isProfessor,
                              'userId': user.uid,
                            });

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                              'profileName': _idNumberController.text,
                              'tabs': []
                            });

                            await user
                                .updateDisplayName(_idNumberController.text);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
                            );
                          }
                        } on FirebaseAuthException catch (error) {
                          if (error.code == 'email-already-in-use') {
                            _showErrorMessage(
                                'The email address is already in use. Please try again with a different email.');
                          } else {
                            _showErrorMessage(
                                'An error occurred while signing up. Please try again.');
                          }
                        } catch (error) {
                          _showErrorMessage(
                              'An error occurred while signing up. Please try again.');
                        }
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
