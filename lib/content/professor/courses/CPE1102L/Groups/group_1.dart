// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../../../../utils/colors_typography.dart';

class Group1Content extends StatefulWidget {
  @override
  _Group1ContentState createState() => _Group1ContentState();
}

class _Group1ContentState extends State<Group1Content> {
  List<String> tabs = [];
  bool isLoading = true;
  String? storedCollectionName;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTabs();
    });
  }

  Future<void> refreshTabs() async {
    if (!isRefreshing) {
      setState(() {
        isRefreshing = true;
      });
      loadTabs();
      setState(() {
        isRefreshing = false;
      });
    }
  }

  void loadTabs() async {
    try {
      setState(() {
        isLoading = true;
      });

      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final String uid = user?.uid ?? '';

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final documentSnapshot = await firestore
          .doc('/users/$uid/CPE1102L/CPE1102L/Group 1/data/')
          .get();

      final data = documentSnapshot.data();
      if (data != null) {
        final dynamic tabsData = data['logs'];

        if (tabsData is List<dynamic>) {
          setState(() {
            tabs = tabsData.cast<String>().toList();
            isLoading = false;
          });
        } else if (tabsData is String) {
          setState(() {
            tabs = [tabsData];
            isLoading = false;
          });
        }
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.secondaryColor,
            title: const Text(
              'Error',
              style: TextStyle(color: AppColors.textColor),
            ),
            content: Text(
              'An error occurred while loading tabs: $error',
              style: const TextStyle(color: AppColors.textColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
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

  void deleteTab(String tabName) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final String uid = user?.uid ?? '';

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final documentRef =
          firestore.doc('/users/$uid/CPE1102L/CPE1102L/Group 1/data');

      await documentRef.update({
        'logs': FieldValue.arrayRemove([tabName]),
      });

      final collectionRef =
          firestore.collection('/courses/cpe1102L/groups/1/$tabName');
      await collectionRef.doc('data').delete();

      setState(() {
        tabs.remove(tabName);
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.secondaryColor,
            title: const Text(
              'Attendance Deleted',
              style: TextStyle(color: AppColors.textColor),
            ),
            content: const Text(
              'The attendance and its data have been deleted.',
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
              'An error occurred while deleting the tab: $error',
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
          "Group 1",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(
            color: Colors.black12,
            thickness: 0.7,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: AppColors.textColor),
                  onPressed: () {
                    openAttendance(context);
                  },
                  child: const Text(
                    'Open',
                    style: TextStyle(color: AppColors.textColor),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: AppColors.textColor),
                  onPressed: () {
                    closeAttendance(context);
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(color: AppColors.textColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: Text(
                      'Logs',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: isRefreshing && isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : RefreshIndicator(
                            onRefresh: refreshTabs,
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemCount: tabs.length,
                              itemBuilder: (context, index) {
                                final tabName = tabs[index];

                                return GestureDetector(
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor:
                                              AppColors.secondaryColor,
                                          title: const Text(
                                            'Delete Tab',
                                            style: TextStyle(
                                                color: AppColors.textColor),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to delete this tab?',
                                            style: TextStyle(
                                                color: AppColors.textColor),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: AppColors.textColor),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                deleteTab(tabName);
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: AppColors.textColor),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Dismissible(
                                    key: Key(tabName),
                                    onDismissed: (direction) {
                                      deleteTab(tabName);
                                    },
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        openTabScreen(tabName);
                                      },
                                      title: Text(
                                        tabName,
                                        style: const TextStyle(
                                            color: AppColors.textColor),
                                      ),
                                      trailing: const Icon(Icons.arrow_forward),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void openTabScreen(String tabName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TabScreen(tabName: tabName),
      ),
    );
  }

  void openAttendance(BuildContext context) async {
    try {
      final currentDate = DateTime.now();
      final formattedDate = DateFormat('MM-dd-yy').format(currentDate);
      final collectionName = 'attendance_$formattedDate';

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final newCollectionRef =
          firestore.collection('/courses/cpe1102L/groups/1/$collectionName');

      final random = Random();
      final String code = List.generate(
          8, (index) => String.fromCharCode(random.nextInt(26) + 65)).join();

      await newCollectionRef
          .doc('data')
          .set({'idNumbers': [], 'available': true, 'code': code});

      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final String uid = user?.uid ?? '';

      final documentRef =
          firestore.doc('/users/$uid/CPE1102L/CPE1102L/Group 1/data');
      await documentRef.update({
        'logs': FieldValue.arrayUnion([collectionName])
      });

      setState(() {
        storedCollectionName = collectionName;
        if (!tabs.contains(collectionName)) {
          tabs.add(collectionName);
        }
      });

      if (collectionName != storedCollectionName) {
        await newCollectionRef.doc('data').update({'idNumbers': []});
      }

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.secondaryColor,
            title: const Text(
              'Code Generated',
              style: TextStyle(color: AppColors.textColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share the code with your students:\n$code',
                  style: const TextStyle(color: AppColors.textColor),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                },
                child: const Text(
                  'Share',
                  style: TextStyle(color: AppColors.textColor),
                ),
              ),
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

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.secondaryColor,
            title: const Text(
              'Open',
              style: TextStyle(color: AppColors.textColor),
            ),
            content: const Text(
              'Attendance is now open and available.',
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
}

void closeAttendance(BuildContext context) async {
  try {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('MM-dd-yy').format(currentDate);
    final collectionName = 'attendance_$formattedDate';

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final newCollectionRef =
        firestore.collection('/courses/cpe1102L/groups/1/$collectionName');
    final documentSnapshot = await newCollectionRef.doc('data').get();
    final currentAvailable = documentSnapshot.data()?['available'] ?? false;
    final currentData = documentSnapshot.data();

    final confirmationContext = context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryColor,
          title: const Text(
            'Confirmation',
            style: TextStyle(color: AppColors.textColor),
          ),
          content: const Text(
            'Are you sure you want to close the attendance?',
            style: TextStyle(color: AppColors.textColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'No',
                style: TextStyle(color: AppColors.textColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                if (currentAvailable == true) {
                  final currentIdNumbers =
                      List<String>.from(currentData?['idNumbers'] ?? []);
                  await newCollectionRef.doc('data').set({
                    'idNumbers': currentIdNumbers,
                    'available': false,
                  });

                  showDialog(
                    context: confirmationContext,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.secondaryColor,
                        title: const Text(
                          'Closed',
                          style: TextStyle(color: AppColors.textColor),
                        ),
                        content: const Text(
                          'Attendance is now closed and unavailable.',
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
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.secondaryColor,
                        title: const Text(
                          'Error',
                          style: TextStyle(color: AppColors.textColor),
                        ),
                        content: const Text(
                          'Failed to retrieve current data.',
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
                'Yes',
                style: TextStyle(color: AppColors.textColor),
              ),
            ),
          ],
        );
      },
    );
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

class TabScreen extends StatelessWidget {
  final String tabName;

  const TabScreen({required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        title:
            Text(tabName, style: const TextStyle(color: AppColors.textColor)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(
            color: Colors.black12,
            thickness: 0.7,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .doc('/courses/cpe1102L/groups/1/$tabName/data')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final data = snapshot.data!.data();
            final idNumbers = data?['idNumbers'] ?? [];

            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: idNumbers.length,
              itemBuilder: (context, index) {
                final idNumber = idNumbers[index];

                return ListTile(
                  title: Text(idNumber,
                      style: const TextStyle(color: AppColors.textColor)),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: AppColors.textColor),
            ));
          } else {
            return const Center(
                child: Text(
              'No data available.',
              style: TextStyle(color: AppColors.textColor),
            ));
          }
        },
      ),
    );
  }
}
