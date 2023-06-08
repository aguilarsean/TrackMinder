import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  void getUserData() {
    setState(() {
      isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    print(user);

    if (user != null) {
      // String email = user.email ?? 'No email available';
      String idNumber = user.displayName ?? 'No id number';

      setState(() {
        welcomeMessage = 'Welcome $idNumber';
        isLoading = false;
      });
    } else {
      setState(() {
        welcomeMessage = 'Welcome User';
        isLoading = false;
      });
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
