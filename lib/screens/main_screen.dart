// ignore_for_file: prefer_final_fields

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../content/student/student_courses_content.dart';
import '../content/professor/professor_courses_content.dart';
import '../content/home_content.dart';
import 'profile_screen.dart';
import '../utils/colors_typography.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool isProfessor = false;

  List<Widget> _screens = [
    HomeContent(),
    StudentCoursesContent(),
    ProfileContent(),
  ];

  final List<String> _screenTitles = [
    'Home',
    'Courses',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.displayName)
        .get();

    if (userDoc.exists) {
      setState(() {
        isProfessor = userDoc.data()?['isProfessor'] ?? false;
        updateCoursesContentWidget();
      });
    }
  }

  void updateCoursesContentWidget() {
    _screens[1] =
        isProfessor ? ProfessorCoursesContent() : StudentCoursesContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        title: Text(
          _screenTitles[_currentIndex],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(
            color: Colors.black12,
            thickness: 0.7,
          ),
        ),
      ),
      body: Container(
        color: AppColors.accentColor,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textColor,
        backgroundColor: AppColors.accentColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
