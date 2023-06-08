import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trackminder/screens/main_screen.dart';

import '../utils/color_utils.dart';
import '../utils/reusable_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _idNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isProfessor = false;

  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  void _unfocusTextFields() {
    FocusScope.of(context).unfocus();
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
              child: Column(children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter email", Icons.person_outline, false,
                    _emailController),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter ID number", Icons.numbers_outlined,
                    false, _idNumberController),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter password", Icons.lock_outline, true,
                    _passwordController),
                const SizedBox(
                  height: 30,
                ),
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
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
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
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                authButtons(context, "SIGN UP", () {
                  usersCollection.add({
                    'email': _emailController.text,
                    'idNumber': _idNumberController.text,
                    'isProfessor': isProfessor,
                  }).then((docRef) {
                    print("data added with ID: ${docRef.id}");

                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text)
                        .then((value) {
                      value.user!.updateDisplayName(_idNumberController.text);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    }).onError((error, stackTrace) {
                      print("Error ${error.toString()}");
                    });
                  });
                }),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
