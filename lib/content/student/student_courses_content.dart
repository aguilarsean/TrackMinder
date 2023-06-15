// ignore_for_file: prefer_final_fields

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/colors_typography.dart';
import 'courses/cpe_1102_l.dart';
import 'courses/cpe_1202_l.dart';

class StudentCoursesContent extends StatefulWidget {
  @override
  _StudentCoursesContentState createState() => _StudentCoursesContentState();
}

class _StudentCoursesContentState extends State<StudentCoursesContent> {
  List<String> courseCodes = [];
  TextEditingController _textEditingController = TextEditingController();
  RegExp _validPattern = RegExp(r'^[A-Z0-9!@#\$%\^\&*\)\(+=._-]+$');
  List<String> availableCourseCodes = [
    'CPE1102L',
    'CPE1202L',
    // Add more available course codes here
  ];

  CollectionReference? userCollection;
  String? currentUserId;
  bool isFirebaseInitialized = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!isFirebaseInitialized) {
      await initializeFirebase();
    }
    loadTabsFromFirestore();
  }

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      userCollection = FirebaseFirestore.instance.collection('users');
      setState(() {
        isFirebaseInitialized = true;
      });
    } catch (error) {
      // print('Firebase initialization failed: $error');
    }
  }

  void getCurrentUserId() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        currentUserId = currentUser.uid;
      });
    }
  }

  void loadTabsFromFirestore() async {
    if (isFirebaseInitialized &&
        userCollection != null &&
        currentUserId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        final userUidDoc =
            FirebaseFirestore.instance.collection('users').doc(currentUserId);
        final tabsDoc = await userUidDoc.get();

        final tabs = tabsDoc.get('tabs') as List<dynamic>?;
        if (mounted) {
          if (tabs != null) {
            setState(() {
              courseCodes = tabs.cast<String>();
              isLoading = false;
            });
          }
        }
      }
    }
  }

  void saveTabsToFirestore() async {
    if (isFirebaseInitialized &&
        userCollection != null &&
        currentUserId != null) {
      final userDoc = userCollection!.doc(currentUserId);
      await userDoc.set({'tabs': courseCodes});
    }
  }

  void addTab() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCode = '';
        _textEditingController.text = '';
        return AlertDialog(
          backgroundColor: AppColors.secondaryColor,
          title: const Text(
            'Enter Course Code',
            style: TextStyle(color: AppColors.textColor),
          ),
          content: TextFormField(
            controller: _textEditingController,
            onChanged: (value) {
              setState(() {
                newCode = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textColor),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_validPattern.hasMatch(newCode) &&
                    availableCourseCodes.contains(newCode)) {
                  setState(() {
                    courseCodes.add(newCode);
                  });
                  saveTabsToFirestore();
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.secondaryColor,
                        title: const Text(
                          'Invalid Input',
                          style: TextStyle(color: AppColors.textColor),
                        ),
                        content: const Text(
                          'Please enter a valid course code \n(use uppercase letters)',
                          style: TextStyle(color: AppColors.textColor),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'OK',
                              style: TextStyle(color: AppColors.textColor),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void deleteTab(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryColor,
          title: const Text(
            'Delete Tab',
            style: TextStyle(color: AppColors.textColor),
          ),
          content: const Text(
            'Are you sure you want to delete this tab?',
            style: TextStyle(color: AppColors.textColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textColor),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  courseCodes.removeAt(index);
                });
                saveTabsToFirestore();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.textColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void navigateToCourseContent(String courseTitle) {
    if (courseTitle == 'CPE1202L') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CPE1202Lcontent()),
      );
    }
    if (courseTitle == 'CPE1102L') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CPE1102Lcontent()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: courseCodes.length,
                    itemBuilder: (context, index) {
                      final courseTitle = courseCodes[index];
                      return ListTile(
                        title: Text(courseTitle),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          navigateToCourseContent(courseTitle);
                        },
                        onLongPress: () {
                          deleteTab(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        onPressed: addTab,
        child: const Icon(Icons.add, color: AppColors.primaryColor),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
