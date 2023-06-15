// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trackminder/utils/colors_typography.dart';

class FeedbackAndReport extends StatefulWidget {
  const FeedbackAndReport({Key? key}) : super(key: key);

  @override
  State<FeedbackAndReport> createState() => _FeedbackAndReportState();
}

class _FeedbackAndReportState extends State<FeedbackAndReport> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _unfocusTextFields() {
    FocusScope.of(context).unfocus();
  }

  Future<void> sendEmail({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    const serviceId = 'service_3dn5uhp';
    const templateId = 'template_wgq0qdi';
    const userId = 'TndHLa0F_0Dr8W6kD';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'user_name': name,
          'user_email': email,
          'user_subject': subject,
          'user_message': message,
        },
      }),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text(
              'Feedback/Report has been sent.',
              style: TextStyle(color: AppColors.textColor),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: AppColors.textColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
            title: const Text(
              'Error',
              style: TextStyle(color: AppColors.textColor),
            ),
            content: const Text(
              'Failed to send feedback/report.',
              style: TextStyle(color: AppColors.textColor),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: AppColors.textColor),
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        title: const Text(
          'Feedback and Report',
          style: TextStyle(color: AppColors.textColor),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(
            color: Colors.black12,
            thickness: 0.7,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _unfocusTextFields,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: AppColors.textColor),
                  onPressed: () {
                    sendEmail(
                      name: _nameController.text,
                      email: _nameController.text,
                      subject: _subjectController.text,
                      message: _messageController.text,
                    ).catchError((error, stackTrace) {
                      // print('Error: $error');
                      // print('Stack trace: $stackTrace');
                    });

                    _nameController.clear();
                    _emailController.clear();
                    _subjectController.clear();
                    _messageController.clear();

                    _unfocusTextFields();
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
