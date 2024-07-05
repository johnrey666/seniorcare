// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isImagePickerActive = false;

  Future<void> _pickImage() async {
    if (_isImagePickerActive) {
      return;
    }

    setState(() {
      _isImagePickerActive = true;
    });

    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() {
        _isImagePickerActive = false;
      });
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showErrorDialog("Title and Description are required.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog("No user logged in.");
        return;
      }

      // Fetch user profile data
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        _showErrorDialog("User profile not found.");
        return;
      }

      var userData = userDoc.data() as Map<String, dynamic>;

      String firstName = userData['firstName'] ?? 'Anonymous';
      String lastName = userData['lastName'] ?? '';
      String profileImageUrl = userData['profileImageUrl'] ?? '';

      String? imageUrl;
      if (_selectedImage != null) {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = await storageRef.putFile(_selectedImage!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      // Save post data to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'imagePath': imageUrl ?? '',
        'userId': user.uid,
        'profileImageUrl': profileImageUrl,
        'firstName': firstName,
        'lastName': lastName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the form after submission
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      setState(() {
        _selectedImage = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully!')),
      );

      // Navigate to homepage
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _showErrorDialog("Failed to submit post: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 6,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Add location (optional)',
                  prefixIcon:
                      Icon(Icons.location_on_outlined, color: textColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Add Image'),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitPost,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Post',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
