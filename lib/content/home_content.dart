import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String welcomeMessage = 'Welcome User';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    setState(() {
      isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    print(user);

    if (user != null) {
      String uid = user.uid;
      String idNumber = user.displayName ?? 'No id number';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);
      await prefs.setString('idNumber', idNumber);

      setState(() {
        welcomeMessage = 'Welcome $idNumber';
        isLoading = false;
      });
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');
      String? idNumber = prefs.getString('idNumber');

      if (uid != null && idNumber != null) {
        setState(() {
          welcomeMessage = 'Welcome $idNumber';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                welcomeMessage,
                style: const TextStyle(fontSize: 24),
              ),
      ),
    );
  }
}
