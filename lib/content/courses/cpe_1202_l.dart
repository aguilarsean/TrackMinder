import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/color_utils.dart';
import '../../utils/reusable_widgets.dart';

class CPE1202Lcontent extends StatefulWidget {
  @override
  State<CPE1202Lcontent> createState() => _CPE1202LcontentState();
}

class _CPE1202LcontentState extends State<CPE1202Lcontent> {
  TextEditingController _groupNumberController = TextEditingController();
  TextEditingController _numCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "CPE1202L",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [hexStringToColor("20BF55"), hexStringToColor("01BAEF")],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                reusableTextField(
                  "Enter group number",
                  Icons.group_outlined,
                  false,
                  _groupNumberController,
                ),
                const SizedBox(height: 30),
                reusableTextField(
                  "Enter code",
                  Icons.numbers_outlined,
                  false,
                  _numCodeController,
                ),
                const SizedBox(height: 30),
                authButtons(context, "Mark Attendance", () {
                  FirebaseFirestore firestore = FirebaseFirestore.instance;

                  String groupNumber = _groupNumberController.text;
                  String numCode = _numCodeController.text;

                  Map<String, dynamic> data = {
                    'groupNumber': groupNumber,
                    'numCode': numCode,
                    'selectedDate': FieldValue.serverTimestamp(),
                  };

                  firestore.collection('CPE1202L').add(data).then((value) {
                    print('Data added successfully!');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CPE1202Lcontent()),
                    );
                  }).catchError((error) {
                    print('Failed to add data to Firestore: $error');
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
