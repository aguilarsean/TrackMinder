// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../utils/colors_typography.dart';
import 'Groups/group_1.dart';
import 'Groups/group_2.dart';
import 'Groups/group_3.dart';

class ProfCPE1202Lcontent extends StatefulWidget {
  @override
  _ProfCPE1202LcontentState createState() => _ProfCPE1202LcontentState();
}

class _ProfCPE1202LcontentState extends State<ProfCPE1202Lcontent> {
  List<String> courseGroup = [];
  TextEditingController _textEditingController = TextEditingController();
  List<String> availablecourseGroup = [
    'Group 1',
    'Group 2',
    'Group 3',
    // Add more available group numbers here
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
      final cpe1202lDoc = await userCollection!
          .doc(currentUserId)
          .collection('CPE1202L')
          .doc('CPE1202L')
          .get();
      if (mounted) {
        setState(() {
          if (cpe1202lDoc.exists) {
            final tabs = cpe1202lDoc.get('tabs') as List<dynamic>?;
            courseGroup = tabs?.cast<String>() ?? [];
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
      final cpe1202lDoc = userCollection!
          .doc(currentUserId)
          .collection('CPE1202L')
          .doc('CPE1202L');
      await cpe1202lDoc.set({'tabs': courseGroup});
    }
  }

  void addTab() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newGroup = '';
        _textEditingController.text = '';
        return AlertDialog(
          backgroundColor: AppColors.secondaryColor,
          title: const Text(
            'Enter Group Number',
            style: TextStyle(color: AppColors.textColor),
          ),
          content: TextFormField(
            controller: _textEditingController,
            onChanged: (value) {
              setState(() {
                newGroup = value;
              });
            },
            decoration: const InputDecoration(hintText: "Group 'number'"),
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
              onPressed: () async {
                if (availablecourseGroup.contains(newGroup) &&
                    !courseGroup.contains(newGroup)) {
                  setState(() {
                    courseGroup.add(newGroup);
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
                          'Please enter a valid group number',
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
              child: const Text(
                'Add',
                style: TextStyle(color: AppColors.textColor),
              ),
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
              onPressed: () async {
                final groupNumber = courseGroup[index];
                final userDoc = userCollection!.doc(currentUserId);
                final courseCollection =
                    userDoc.collection('CPE1202L').doc('CPE1202L');
                final groupCollection =
                    courseCollection.collection(groupNumber);

                await groupCollection.doc('data').delete();

                setState(() {
                  courseGroup.removeAt(index);
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

  void navigateToCourseContent(String groupNumber) async {
    try {
      final userDoc = userCollection!.doc(currentUserId);
      final courseCollection = userDoc.collection('CPE1202L').doc('CPE1202L');

      final groupCollection = courseCollection.collection(groupNumber);
      final dataDoc = groupCollection.doc('data');

      dataDoc.get().then((docSnapshot) {
        if (!docSnapshot.exists) {
          dataDoc.set({'logs': []});
        }
      });

      if (groupNumber == 'Group 1') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Group1Content()),
        );
      } else if (groupNumber == 'Group 2') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Group2Content()),
        );
      } else if (groupNumber == 'Group 3') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Group3Content()),
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.secondaryColor,
            title: const Text(
              'Error',
              style: TextStyle(color: AppColors.textColor),
            ),
            content: Text(
              'An error occurred: $error',
              style: const TextStyle(color: AppColors.textColor),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        elevation: 0,
        title: const Text(
          'Groups',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(
            color: Colors.black12,
            thickness: 0.7,
          ),
        ),
      ),
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
                    itemCount: courseGroup.length,
                    itemBuilder: (context, index) {
                      final groupNumber = courseGroup[index];
                      return ListTile(
                        title: Text(
                          groupNumber,
                          style: const TextStyle(color: AppColors.textColor),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          navigateToCourseContent(groupNumber);
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
