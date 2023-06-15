// ignore_for_file: unused_field, avoid_unnecessary_containers

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'get_started.dart';
import '../utils/colors_typography.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String welcomeMessage = 'Welcome User';
  String greeting = '';

  int _currentImageIndex = 0;
  List<String> images = [
    'assets/images/cpe_logo.png',
    'assets/images/cpec_robomania_wide.jpg',
    'assets/images/usc_gdsc_wide.jpg',
  ];

  @override
  void initState() {
    super.initState();
    getUserData();
    setGreeting();
  }

  void setGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour < 12) {
      setState(() {
        greeting = 'Good morning';
      });
    } else if (hour < 17) {
      setState(() {
        greeting = 'Good afternoon';
      });
    } else {
      setState(() {
        greeting = 'Good evening';
      });
    }
  }

  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await fetchUserDataFromFirestore(user.uid, user.displayName);
    } else {
      await fetchUserDataFromSharedPrefs();
    }
  }

  Future<void> fetchUserDataFromFirestore(String uid, String? idNumber) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(idNumber ?? '')
        .get();

    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

    String profileName = data?['profileName'] ?? '';

    await saveUserDataToSharedPrefs(uid, idNumber, profileName);

    setState(() {
      welcomeMessage = 'Welcome $profileName';
    });
  }

  Future<void> fetchUserDataFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? uid = prefs.getString(SharedPrefsKeys.uid);
    String? idNumber = prefs.getString(SharedPrefsKeys.idNumber);
    String? profileName = prefs.getString(SharedPrefsKeys.profileName);

    if (uid != null && idNumber != null && profileName != null) {
      setState(() {
        welcomeMessage = 'Welcome $profileName';
      });
    } else {
      setState(() {
        welcomeMessage = 'Welcome User';
      });
    }
  }

  Future<void> saveUserDataToSharedPrefs(
      String uid, String? idNumber, String profileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefsKeys.uid, uid);
    await prefs.setString(SharedPrefsKeys.idNumber, idNumber ?? '');
    await prefs.setString(SharedPrefsKeys.profileName, profileName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  welcomeMessage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 1 / 2.35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CarouselSlider(
                    items: images.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Image.asset(
                            image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 7),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      viewportFraction: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.map((image) {
                  int index = images.indexOf(image);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Container(
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GetStarted(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.white.withOpacity(0.95),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket, size: 40, color: Colors.green),
                            SizedBox(height: 10),
                            Text('Get Started',
                                style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  backgroundColor:
                                      Colors.white.withOpacity(0.95),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.dashboard,
                                        size: 40, color: Colors.green),
                                    SizedBox(height: 10),
                                    Text('Dashboard',
                                        style: TextStyle(color: Colors.green)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  'Coming Soon',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SharedPrefsKeys {
  static const String uid = 'uid';
  static const String idNumber = 'idNumber';
  static const String profileName = 'profileName';
}
