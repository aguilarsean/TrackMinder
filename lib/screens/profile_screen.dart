// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:transparent_image/transparent_image.dart';

import '../content/profile_settings_content.dart';
import 'login_screen.dart';

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
  // ignore: unused_field
  bool _isImageLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImageUrl();
  }

  Future<void> _loadProfileImageUrl() async {
    try {
      setState(() {
        _isImageLoading = true;
      });

      final User? user = _auth.currentUser;
      if (user == null) return;

      final String userId = user.uid;
      final DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('profilePicture')) {
        setState(() {
          _imageUrl = data['profilePicture'];
          _isImageLoading = false;
        });
      }
      print(_imageUrl);
    } catch (error) {
      print('Error loading profile image URL: $error');
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

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
      await _uploadImage();
    }
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

  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    try {
      setState(() {
        _isImageLoading = true;
      });
      _showImageLoadingAlert();

      final User? user = _auth.currentUser;
      if (user == null) return;

      final String userId = user.uid;
      final String fileName = 'profile_image_$userId.jpg';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': userId},
      );

      final compressedImage = await compressFile(_pickedImage!);
      if (compressedImage == null) {
        print('Error compressing image');
        return;
      }

      final UploadTask uploadTask =
          storageRef.putData(compressedImage, metadata);

      final TaskSnapshot taskSnapshot = await uploadTask;

      final imageUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = imageUrl;
        _isImageLoading = false;
      });
      _hideImageLoadingAlert();

      await _storeImageUrl(userId, imageUrl);
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  Future<Uint8List?> compressFile(File? file) async {
    if (file == null) return null;

    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 300,
      minHeight: 300,
      quality: 85,
    );
    return result;
  }

  Future<void> _storeImageUrl(String userId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profilePicture': imageUrl});
    } catch (error) {
      print('Error storing image URL: $error');
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

  void _openProfileSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileSettingsContent()),
    );
  }

  void _showImageLoadingAlert() {
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
                  'Changing profile picture...',
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

  void _hideImageLoadingAlert() {
    Navigator.of(context).pop();
  }

  Widget _buildAvatarWidget() {
    if (!kIsWeb) {
      return GestureDetector(
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
            color: Colors.transparent,
          ),
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(top: 20),
          alignment: Alignment.topCenter,
          child: Stack(
            children: [
              if (_pickedImage != null || _imageUrl != null)
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (_imageUrl != null
                          ? FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: _imageUrl!,
                            ).image
                          : null),
                ),
              if (_imageUrl == null && _pickedImage == null)
                const Center(
                  child: Icon(Icons.person, size: 50),
                ),
              if (_imageUrl != null && _pickedImage == null)
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (_imageUrl != null
                          ? FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: _imageUrl!,
                            ).image
                          : null),
                ),
              if (_imageUrl == null && _pickedImage != null)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black87,
            width: 1.0,
          ),
          color: Colors.transparent,
        ),
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(top: 20),
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            if (_imageUrl == null)
              const Center(
                child: Icon(Icons.person, size: 50),
              ),
            if (_imageUrl != null)
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.transparent,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : (_imageUrl != null
                        ? FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: _imageUrl!,
                          ).image
                        : null),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildDisplayNameWidget(String displayName) {
    return Text(
      displayName,
      style: const TextStyle(fontSize: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _getUserDocumentStream(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final displayName = data?['displayName'] as String? ?? '';

        return Column(
          children: [
            _buildAvatarWidget(),
            const SizedBox(height: 20),
            _buildDisplayNameWidget(displayName),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              onTap: _openProfileSettingsScreen,
              title: const Text('Edit Profile'),
            ),
            const Divider(),
            ListTile(
              onTap: _logout,
              title: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Stream<DocumentSnapshot> _getUserDocumentStream() {
    final User? user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    } else {
      final String userId = user.uid;
      return _firestore.collection('users').doc(userId).snapshots();
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogInScreen()),
    );
  }
}
