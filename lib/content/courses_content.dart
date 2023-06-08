import 'package:flutter/material.dart';

import 'courses/cpe_1202_l.dart';

class CoursesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('CPE1202L'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CPE1202Lcontent()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
