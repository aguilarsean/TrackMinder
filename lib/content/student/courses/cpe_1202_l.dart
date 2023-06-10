// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/color_utils.dart';
import '../../../../utils/reusable_widgets.dart';

class CPE1202Lcontent extends StatefulWidget {
  @override
  State<CPE1202Lcontent> createState() => _CPE1202LcontentState();
}

class _CPE1202LcontentState extends State<CPE1202Lcontent> {
  TextEditingController _groupNumberController = TextEditingController();
  TextEditingController _numCodeController = TextEditingController();
  String idNumber = '';
  bool dataAdded = false;

  @override
  void initState() {
    super.initState();
    _getIdNumber();
  }

  Future<void> _getIdNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedIdNumber = prefs.getString('idNumber') ?? '';
    setState(() {
      idNumber = storedIdNumber;
    });
  }

  void _unfocusTextFields() {
    FocusScope.of(context).unfocus();
  }

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
      body: GestureDetector(
        onTap: _unfocusTextFields,
        child: Container(
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
                    null,
                  ),
                  const SizedBox(height: 30),
                  reusableTextField(
                    "Enter code",
                    Icons.numbers_outlined,
                    false,
                    _numCodeController,
                    null,
                  ),
                  const SizedBox(height: 30),
                  authButtons(context, "Mark Attendance", () async {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;

                    String groupNumber = _groupNumberController.text;

                    final currentDate = DateTime.now();
                    final formattedDate =
                        DateFormat('MM-dd-yy').format(currentDate);
                    final collectionName = 'attendance_$formattedDate';

                    final attendanceCollectionRef = firestore
                        .collection(
                            '/courses/cpe1202L/groups/1/$collectionName')
                        .doc('data');

                    bool attendanceCollectionExists =
                        await attendanceCollectionRef
                            .get()
                            .then((snapshot) => snapshot.exists);

                    if (!attendanceCollectionExists) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content:
                                const Text('Attendance is not yet available.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    firestore.runTransaction((transaction) async {
                      DocumentSnapshot groupSnapshot =
                          await transaction.get(attendanceCollectionRef);

                      if (groupSnapshot.exists) {
                        Map<String, dynamic>? data =
                            groupSnapshot.data() as Map<String, dynamic>?;
                        if (data != null && data.containsKey('idNumbers')) {
                          List<String> idNumbers =
                              List<String>.from(data['idNumbers']!);
                          if (idNumbers.contains(idNumber)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Please try again!'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            idNumbers.add(idNumber);
                            transaction.update(attendanceCollectionRef,
                                {'idNumbers': idNumbers});
                            setState(() {
                              dataAdded = true;
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Success'),
                                  content: const Text('Attendance is Marked!'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          print('Field "idNumbers" not found!');
                        }
                      } else {
                        print('Group number $groupNumber does not exist!');
                      }
                    }).then((_) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('idNumber', idNumber);
                    }).catchError((error) {
                      print('Failed to update data in Firestore: $error');
                    });
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
