// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Group2Content extends StatefulWidget {
  @override
  _Group2ContentState createState() => _Group2ContentState();
}

class _Group2ContentState extends State<Group2Content> {
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
          .doc('/users/$uid/CPE1202L/CPE1202L/Group 2/data/')
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
            title: const Text('Error'),
            content: Text('An error occurred while loading tabs: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('OK'),
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
          firestore.doc('/users/$uid/CPE1202L/CPE1202L/Group 2/data');

      await documentRef.update({
        'logs': FieldValue.arrayRemove([tabName]),
      });

      final collectionRef =
          firestore.collection('/courses/cpe1202L/groups/2/$tabName');
      await collectionRef.doc('data').delete();

      setState(() {
        tabs.remove(tabName);
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Attendance Deleted'),
            content:
                const Text('The attendance and its data have been deleted.'),
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
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred while deleting the tab: $error'),
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
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text(
          "Group 2",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  onPressed: () {
                    openAttendance(context);
                  },
                  child: const Text('Open'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    closeAttendance(context);
                  },
                  child: const Text('Close'),
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
                      ),
                    ),
                  ),
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
                                          title: const Text('Delete Tab'),
                                          content: const Text(
                                              'Are you sure you want to delete this tab?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                deleteTab(tabName);
                                              },
                                              child: const Text('Delete'),
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
                                      title: Text(tabName),
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
    // Use the Navigator to navigate to a new screen
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

      print(collectionName);
      print('stored: $storedCollectionName');

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final newCollectionRef =
          firestore.collection('/courses/cpe1202L/groups/2/$collectionName');

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
          firestore.doc('/users/$uid/CPE1202L/CPE1202L/Group 2/data');
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
            title: const Text('Code Generated'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Share the code with your students:\n$code'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Code copied to clipboard'),
                  //   ),
                  // );
                },
                child: const Text('Share'),
              ),
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

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Open'),
            content: const Text('Attendance is now close and available.'),
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
}

void closeAttendance(BuildContext context) async {
  try {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('MM-dd-yy').format(currentDate);
    final collectionName = 'attendance_$formattedDate';

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final newCollectionRef =
        firestore.collection('/courses/cpe1202L/groups/2/$collectionName');
    final documentSnapshot = await newCollectionRef.doc('data').get();
    final currentAvailable = documentSnapshot.data()?['available'] ?? false;
    final currentData = documentSnapshot.data();

    final confirmationContext = context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to close the attendance?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
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
                        title: const Text('Closed'),
                        content: const Text(
                            'Attendance is now closed and unavailable.'),
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
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Failed to retrieve current data.'),
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
              child: const Text('Yes'),
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

class TabScreen extends StatelessWidget {
  final String tabName;

  const TabScreen({required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tabName),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .doc('/courses/cpe1202L/groups/2/$tabName/data')
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
                  title: Text(idNumber),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
