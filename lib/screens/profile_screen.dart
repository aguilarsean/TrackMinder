import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackminder/screens/login_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileContent extends StatefulWidget {
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
      bucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '');
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImageUrl();
  }

  Future<void> _loadProfileImageUrl() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      final String userId = user.uid;
      final DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();

      final data = snapshot.data();
      if (data != null &&
          data is Map<String, dynamic> &&
          data.containsKey('profilePicture')) {
        setState(() {
          _imageUrl = data['profilePicture'];
        });
      }
      print(_imageUrl);
    } catch (error) {
      print('Error loading profile image URL: $error');
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      final String userId = user.uid;
      final String fileName = 'profile_image_$userId.jpg';
      final Reference storageRef =
          _storage.ref().child('profile_images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(_pickedImage!);
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

      final imageUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = imageUrl;
      });

      await _storeImageUrl(userId, imageUrl);
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  Future<void> _storeImageUrl(String userId, String imageUrl) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'profilePicture': imageUrl});
    } catch (error) {
      print('Error storing image URL: $error');
    }
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Change Profile Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _showImagePickerOptions();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Profile Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImageFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
      await _uploadImage();
    }
  }

  void _removeProfilePicture() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      final String userId = user.uid;

      if (_imageUrl != null) {
        final Reference storageRef = _storage.refFromURL(_imageUrl!);
        await storageRef.delete();
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .update({'profilePicture': null});

      setState(() {
        _imageUrl = null;
        _pickedImage = null;
      });
    } catch (error) {
      print('Error removing profile picture: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!kIsWeb)
            GestureDetector(
              onTap: () {
                _showOptionsBottomSheet(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black87,
                    width: 1.0,
                  ),
                ),
                margin: const EdgeInsets.only(top: 20),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (_imageUrl != null ? NetworkImage(_imageUrl!) : null)
                          as ImageProvider<Object>?,
                  child: _pickedImage == null && _imageUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
            ),
          if (kIsWeb)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black87,
                  width: 1.0,
                ),
              ),
              margin: const EdgeInsets.only(top: 20),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : (_imageUrl != null ? NetworkImage(_imageUrl!) : null)
                        as ImageProvider<Object>?,
                child: _pickedImage == null && _imageUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            child: const Text("Log out"),
            onPressed: () {
              _auth.signOut().then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogInScreen()),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
