// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Group1Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text(
          "Group 1",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                openAttendance(context);
              },
              child: const Text('Open'),
            ),
            ElevatedButton(
              onPressed: () {
                closeAttendance(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
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
          firestore.collection('/courses/cpe1202L/groups/1/$collectionName');

      final random = Random();
      final String code = List.generate(
          8, (index) => String.fromCharCode(random.nextInt(26) + 65)).join();

      await newCollectionRef
          .doc('data')
          .set({'idNumbers': [], 'available': true, 'code': code});

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
        firestore.collection('/courses/cpe1202L/groups/1/$collectionName');
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
