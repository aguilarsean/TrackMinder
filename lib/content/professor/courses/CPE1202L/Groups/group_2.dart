// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Group2Content extends StatelessWidget {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                createNewCollection(context);
              },
              child: const Text('Open'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement the close functionality here
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void createNewCollection(BuildContext context) async {
    try {
      final currentDate = DateTime.now();
      final formattedDate = DateFormat('MM-dd-yy').format(currentDate);
      final collectionName = 'attendance_$formattedDate';

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final newCollectionRef =
          firestore.collection('/courses/cpe1202L/groups/2/$collectionName');
      await newCollectionRef.doc('data').set({'idNumbers': []});

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('New collection created successfully.'),
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
