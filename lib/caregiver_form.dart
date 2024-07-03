import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: unused_import
import 'package:seniorcare/main.dart'; // Update import path if necessary

class CaregiverFormPage extends StatefulWidget {
  final void Function() toggleTheme;

  const CaregiverFormPage({super.key, required this.toggleTheme});

  @override
  _CaregiverFormPageState createState() => _CaregiverFormPageState();
}

class _CaregiverFormPageState extends State<CaregiverFormPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  DateTime _dob = DateTime.now();
  bool _isMale = true;
  bool _isLoading = false;
  XFile? _profileImage;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    setState(() {
      _profileImage = image;
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      String filePath = 'profileImages/${user.uid}.png';
      await FirebaseStorage.instance.ref(filePath).putFile(imageFile);
      String downloadURL =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      return downloadURL;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _contactNumberController.text.isEmpty ||
        _expertiseController.text.isEmpty ||
        _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill out all fields and upload a profile image.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in.');
      }

      String? profileImageUrl = await _uploadImage(File(_profileImage!.path));
      if (profileImageUrl == null) {
        throw Exception('Failed to upload profile image.');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'location': _locationController.text,
        'contactNumber': _contactNumberController.text,
        'expertise': _expertiseController.text,
        'dob': _dob,
        'gender': _isMale ? 'Male' : 'Female',
        'email': user.email,
        'profileImageUrl': profileImageUrl,
        'userType': 'Caregiver',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed up successfully')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save form data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Registration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(File(_profileImage!.path))
                          : null,
                      child: _profileImage == null
                          ? const Icon(Icons.image, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Radio<bool>(
                        value: true,
                        groupValue: _isMale,
                        onChanged: (bool? value) {
                          setState(() {
                            _isMale = value!;
                          });
                        },
                      ),
                      const Text('Male', style: TextStyle(fontSize: 16)),
                      Radio<bool>(
                        value: false,
                        groupValue: _isMale,
                        onChanged: (bool? value) {
                          setState(() {
                            _isMale = value!;
                          });
                        },
                      ),
                      const Text('Female', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Date of Birth:',
                style: TextStyle(fontSize: 16),
              ),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dob,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null && pickedDate != _dob) {
                    setState(() {
                      _dob = pickedDate;
                    });
                  }
                },
                child: Container(
                  height: 32, // Reduced height
                  width: 150, // Adjusted width
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius:
                        BorderRadius.circular(24), // More rounded corners
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_dob),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contactNumberController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _expertiseController,
                decoration: InputDecoration(
                  labelText: 'Expertise',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
