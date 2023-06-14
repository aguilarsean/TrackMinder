// ignore_for_file: use_build_context_synchronously, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trackminder/screens/login_screen.dart';

class ProfileSettingsContent extends StatefulWidget {
  const ProfileSettingsContent({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsContent> createState() => _ProfileSettingsContentState();
}

class _ProfileSettingsContentState extends State<ProfileSettingsContent> {
  late final TextEditingController _profileNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late BuildContext _context;
  bool _isButtonDisabled = false;
  bool _isSnackbarVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileNameController = TextEditingController();
    _passwordController = TextEditingController();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateProfileName() async {
    if (_isButtonDisabled) return;
    _unfocusTextFields();

    User? user = FirebaseAuth.instance.currentUser;
    String idNumber = user?.displayName ?? 'No id number';

    if (user == null) return;

    setState(() {
      _isButtonDisabled = true;
      _isSnackbarVisible = true;
      _isLoading = true;
    });
    _showUpdatingAlert();

    try {
      await _firestore
          .collection('users')
          .doc(idNumber)
          .update({'profileName': _profileNameController.text});

      setState(() {
        _isButtonDisabled = false;
        _isSnackbarVisible = false;
        _isLoading = false;
      });
      _hideAlert();

      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Profile name updated successfully.')),
      );

      _profileNameController.clear();
    } catch (error) {
      setState(() {
        _isButtonDisabled = false;
        _isSnackbarVisible = false;
        _isLoading = false;
      });
      _hideAlert();

      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile name.')),
      );
    }
  }

  void _updatePassword() async {
    if (_isButtonDisabled) return;
    _unfocusTextFields();
    final User? user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isButtonDisabled = true;
      _isSnackbarVisible = true;
      _isLoading = true;
    });
    _showUpdatingAlert();

    try {
      await user.updatePassword(_passwordController.text);

      setState(() {
        _isButtonDisabled = false;
        _isSnackbarVisible = false;
        _isLoading = false;
      });
      _hideAlert();

      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );

      _passwordController.clear();
    } catch (error) {
      setState(() {
        _isButtonDisabled = false;
        _isSnackbarVisible = false;
        _isLoading = false;
      });
      _hideAlert();

      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Failed to update password.')),
      );
    }
  }

  void _deleteAccount() async {
    if (_isButtonDisabled) return;
    _unfocusTextFields();
    final User? user = _auth.currentUser;

    if (user == null) return;

    String idNumber = user.displayName ?? 'No id number';

    final bool? confirm = await showDialog<bool>(
      context: _context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    setState(() {
      _isButtonDisabled = true;
      _isSnackbarVisible = true;
      _isLoading = true;
    });
    _showDeletingAlert();

    if (confirm == true) {
      try {
        await _firestore.collection('users').doc(user.uid).delete();
        await _firestore.collection('users').doc(idNumber).delete();
        await user.delete();

        ScaffoldMessenger.of(_context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
        );

        setState(() {
          _isButtonDisabled = false;
          _isSnackbarVisible = false;
          _isLoading = false;
        });
        _hideAlert();

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LogInScreen()),
            (route) => false);
      } catch (error) {
        setState(() {
          _isButtonDisabled = false;
          _isSnackbarVisible = false;
          _isLoading = false;
        });
        _hideAlert();

        ScaffoldMessenger.of(_context).showSnackBar(
          const SnackBar(content: Text('Failed to delete account.')),
        );
      }
    }
  }

  void _unfocusTextFields() {
    FocusScope.of(_context).unfocus();
  }

  void _showDeletingAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.0),
                Text(
                  'Deleting account...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpdatingAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.0),
                Text(
                  'Updating...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideAlert() {
    Navigator.of(context).pop();
  }

  Future<String> getUserEmail() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      return user.email ?? '';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    return GestureDetector(
      onTap: _unfocusTextFields,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile Settings'),
          leading: _isSnackbarVisible
              ? const IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: null,
                )
              : null,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profile Name', style: TextStyle(fontSize: 18)),
                Opacity(
                  opacity: _isButtonDisabled ? 0.5 : 1.0,
                  child: TextFormField(
                    controller: _profileNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your profile name',
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Opacity(
                  opacity: _isButtonDisabled ? 0.5 : 1.0,
                  child: ElevatedButton(
                    onPressed: _updateProfileName,
                    child: const Text('Update Profile Name'),
                  ),
                ),
                const SizedBox(height: 32.0),
                const Text('Email', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10.0),
                Stack(
                  children: [
                    FutureBuilder<String>(
                      future: getUserEmail(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              snapshot.data ?? '',
                              style: const TextStyle(fontSize: 16),
                            );
                          }
                        } else {
                          return const Text(
                            '',
                            style: TextStyle(fontSize: 16),
                          );
                        }
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 32),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black54,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                const Text('Password', style: TextStyle(fontSize: 18)),
                Opacity(
                  opacity: _isButtonDisabled ? 0.5 : 1.0,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter your new password',
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Opacity(
                  opacity: _isButtonDisabled ? 0.5 : 1.0,
                  child: ElevatedButton(
                    onPressed: _updatePassword,
                    child: const Text('Update Password'),
                  ),
                ),
                const SizedBox(height: 32.0),
                Opacity(
                  opacity: _isButtonDisabled ? 0.5 : 1.0,
                  child: ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
