import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'courses/cpe_1102_l.dart';
import 'courses/cpe_1202_l.dart';

class CoursesContent extends StatefulWidget {
  @override
  _CoursesContentState createState() => _CoursesContentState();
}

class _CoursesContentState extends State<CoursesContent> {
  List<String> courseCodes = [];
  TextEditingController _textEditingController = TextEditingController();
  RegExp _validPattern = RegExp(r'^[A-Z0-9!@#\$%\^\&*\)\(+=._-]+$');
  List<String> availableCourseCodes = [
    'CPE1102L',
    'CPE1202L',
    // Add more available course codes here
  ];

  @override
  void initState() {
    super.initState();
    loadTabsFromLocalStorage();
  }

  void loadTabsFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courseCodes = prefs.getStringList('courseCodes') ?? [];
    });
  }

  void saveTabsToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('courseCodes', courseCodes);
  }

  void addTab() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCode = '';
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
                  saveTabsToLocalStorage();
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
                saveTabsToLocalStorage();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
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
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Column(
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
    saveTabsToLocalStorage();
    super.dispose();
  }
}
