// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/color_utils.dart';
import '../../../../utils/reusable_widgets.dart';
import '../../../utils/colors_typography.dart';

class CPE1202Lcontent extends StatefulWidget {
  @override
  State<CPE1202Lcontent> createState() => _CPE1202LcontentState();
}

class _CPE1202LcontentState extends State<CPE1202Lcontent> {
  TextEditingController _groupNumberController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
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
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor),
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
                    Icons.code_outlined,
                    false,
                    _codeController,
                    null,
                  ),
                  const SizedBox(height: 30),
                  authButtons(context, "Mark Attendance", () async {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;

                    String groupNumber = _groupNumberController.text;
                    String enteredCode = _codeController.text;

                    if (groupNumber.isEmpty || enteredCode.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: AppColors.secondaryColor,
                            title: const Text('Error',
                                style: TextStyle(color: AppColors.textColor)),
                            content: const Text(
                                'Enter both group number and code.',
                                style: TextStyle(color: AppColors.textColor)),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK',
                                    style:
                                        TextStyle(color: AppColors.textColor)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    } else {
                      final currentDate = DateTime.now();
                      final formattedDate =
                          DateFormat('MM-dd-yy').format(currentDate);
                      final collectionName = 'attendance_$formattedDate';

                      final attendanceCollectionRef = firestore
                          .collection(
                              '/courses/cpe1202L/groups/$groupNumber/$collectionName')
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
                              backgroundColor: AppColors.secondaryColor,
                              title: const Text('Error',
                                  style: TextStyle(color: AppColors.textColor)),
                              content: const Text(
                                  'Attendance is not yet available.',
                                  style: TextStyle(color: AppColors.textColor)),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK',
                                      style: TextStyle(
                                          color: AppColors.textColor)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      } else {
                        firestore.runTransaction((transaction) async {
                          DocumentSnapshot groupSnapshot =
                              await transaction.get(attendanceCollectionRef);

                          if (groupSnapshot.exists) {
                            Map<String, dynamic>? data =
                                groupSnapshot.data() as Map<String, dynamic>?;

                            List<String> idNumbers =
                                List<String>.from(data?['idNumbers']!);
                            bool available = data?['available'] ?? false;
                            String generatedCode = data?['code'] ?? '';

                            if (!available) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: AppColors.secondaryColor,
                                    title: const Text('Closed',
                                        style: TextStyle(
                                            color: AppColors.textColor)),
                                    content: const Text(
                                        'Attendance is now closed.',
                                        style: TextStyle(
                                            color: AppColors.textColor)),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK',
                                            style: TextStyle(
                                                color: AppColors.textColor)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            } else if (enteredCode != generatedCode) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: AppColors.secondaryColor,
                                    title: const Text('Error',
                                        style: TextStyle(
                                            color: AppColors.textColor)),
                                    content: const Text(
                                        'The code is incorrect!',
                                        style: TextStyle(
                                            color: AppColors.textColor)),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK',
                                            style: TextStyle(
                                                color: AppColors.textColor)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              if (data != null &&
                                  data.containsKey('idNumbers')) {
                                if (idNumbers.contains(idNumber)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor:
                                            AppColors.secondaryColor,
                                        title: const Text('Attendance Marked',
                                            style: TextStyle(
                                                color: AppColors.textColor)),
                                        content: const Text(
                                            'You have already been marked present.',
                                            style: TextStyle(
                                                color: AppColors.textColor)),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK',
                                                style: TextStyle(
                                                    color:
                                                        AppColors.textColor)),
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
                                        backgroundColor:
                                            AppColors.secondaryColor,
                                        title: const Text('Success',
                                            style: TextStyle(
                                                color: AppColors.textColor)),
                                        content: const Text(
                                            'Attendance is marked!',
                                            style: TextStyle(
                                                color: AppColors.textColor)),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK',
                                                style: TextStyle(
                                                    color:
                                                        AppColors.textColor)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            }
                          }
                        }).then((_) async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('idNumber', idNumber);
                        }).catchError((error, stackTrace) {
                          // print('Error: $error');
                          // print('Stack trace: $stackTrace');
                        });
                      }
                    }
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
