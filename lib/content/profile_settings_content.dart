// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileSettingsContent extends StatefulWidget {
  const ProfileSettingsContent({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsContent> createState() => _ProfileSettingsContentState();
}

class _ProfileSettingsContentState extends State<ProfileSettingsContent> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late BuildContext _context;
  bool _isButtonDisabled = false;
  bool _isSnackbarVisible = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateDisplayName() async {
    if (_isButtonDisabled) return;
    _unfocusTextFields();
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      setState(() {
        _isButtonDisabled = true;
        _isSnackbarVisible = true;
      });

      await user.updateDisplayName(_displayNameController.text);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'displayName': _displayNameController.text});
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Display name updated successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Failed to update display name.')),
      );
    } finally {
      setState(() {
        _isButtonDisabled = false;
        _isSnackbarVisible = false;
      });
    }
  }

  void _updateEmail() async {
    if (_isButtonDisabled) return;
    _unfocusTextFields();
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      setState(() {
        _isButtonDisabled = true;
        _isSnackbarVisible = true;
      });

      await user.updateEmail(_emailController.text);
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Email updated successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Failed to update email.')),
      );
    } finally {
      setState(() {
        _isButtonDisabled = false;
        _isSnackbarVisible = false;
      });
    }
  }

  void _updatePassword() async {
    if (_isButtonDisabled) {
      return _unfocusTextFields();
    }
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      setState(() {
        _isButtonDisabled = true;
        _isSnackbarVisible = true;
      });

      await user.updatePassword(_passwordController.text);
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Failed to update password.')),
      );
    } finally {
      setState(() {
        _isButtonDisabled = false;
        _isSnackbarVisible = false;
      });
    }
  }

  void _deleteAccount() async {
    if (_isButtonDisabled) return;
    _unfocusTextFields();
    final User? user = _auth.currentUser;
    if (user == null) return;

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

    if (confirm == true) {
      try {
        setState(() {
          _isButtonDisabled = true;
          _isSnackbarVisible = true;
        });

        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        ScaffoldMessenger.of(_context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
        );
        Navigator.pop(_context);
      } catch (error) {
        ScaffoldMessenger.of(_context).showSnackBar(
          const SnackBar(content: Text('Failed to delete account.')),
        );
      } finally {
        setState(() {
          _isButtonDisabled = false;
          _isSnackbarVisible = false;
        });
      }
    }
  }

  void _unfocusTextFields() {
    FocusScope.of(_context).unfocus();
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
                const Text('Display Name', style: TextStyle(fontSize: 18)),
                Opacity(
                  opacity: _isButtonDisabled ? 0.5 : 1.0,
                  child: TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your display name',
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Opacity(
                  opacity: _isButtonDisabled ? 0.5 : 1.0,
                  child: ElevatedButton(
                    onPressed: _updateDisplayName,
                    child: const Text('Update Display Name'),
                  ),
                ),
                const SizedBox(height: 32.0),
                const Text('Email', style: TextStyle(fontSize: 18)),
                Opacity(
                  opacity: _isButtonDisabled ? 0.5 : 1.0,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Opacity(
                  opacity: _isButtonDisabled ? 0.5 : 1.0,
                  child: ElevatedButton(
                    onPressed: _updateEmail,
                    child: const Text('Update Email'),
                  ),
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete Account'),
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
