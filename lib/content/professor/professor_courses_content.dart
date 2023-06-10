// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackminder/content/professor/courses/CPE1102L/prof_cpe_1102_l.dart';
import 'package:trackminder/content/professor/courses/CPE1202L/prof_cpe_1202_l.dart';

class ProfessorCoursesContent extends StatefulWidget {
  @override
  _ProfessorCoursesContentState createState() =>
      _ProfessorCoursesContentState();
}

class _ProfessorCoursesContentState extends State<ProfessorCoursesContent> {
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
      print('Firebase initialization failed: $error');
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
      final userDoc = await userCollection!.doc(currentUserId).get();
      if (mounted) {
        setState(() {
          if (userDoc.exists) {
            final tabs = userDoc.get('tabs') as List<dynamic>?;
            courseCodes = tabs?.cast<String>() ?? [];
          }
          isLoading = false;
        });
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
          title: const Text('Enter Course Code'),
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
              child: const Text('Cancel'),
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
                        title: const Text('Invalid Input'),
                        content: const Text(
                            'Please enter a valid course code \n(use uppercase letters)'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
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
          title: const Text('Delete Tab'),
          content: const Text('Are you sure you want to delete this tab?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  courseCodes.removeAt(index);
                });
                saveTabsToFirestore();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void navigateToCourseContent(String courseTitle) async {
    try {
      final userDoc = userCollection!.doc(currentUserId);
      final courseCollection = userDoc.collection(courseTitle);

      final courseSnapshot = await courseCollection.get();
      if (courseSnapshot.docs.isEmpty) {
        final courseId = courseTitle.replaceAll(' ', '_');
        await courseCollection.doc(courseId).set({'tabs': []});
      }

      if (courseTitle == 'CPE1202L') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfCPE1202Lcontent()),
        );
      } else if (courseTitle == 'CPE1102L') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfCPE1102Lcontent()),
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onPressed: addTab,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
