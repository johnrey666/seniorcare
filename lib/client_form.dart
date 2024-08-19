import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ClientFormPage extends StatefulWidget {
  final void Function() toggleTheme;

  const ClientFormPage({super.key, required this.toggleTheme});

  @override
  // ignore: library_private_types_in_public_api
  _ClientFormPageState createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  DateTime _dob = DateTime.now();
  bool _isMale = true;
  bool _isLoading = false;
  XFile? _profileImage;
  XFile? _idImage;
  XFile? _selfieImage;
  int _currentStep = 1;

  Future<void> _pickImage(ImageSource source, String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    setState(() {
      if (type == 'profile') {
        _profileImage = image;
      } else if (type == 'id') {
        _idImage = image;
      } else if (type == 'selfie') {
        _selfieImage = image;
      }
    });
  }

  Future<String?> _uploadImage(File imageFile, String path) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      String filePath = '$path/${user.uid}.png';
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
        _patientNameController.text.isEmpty ||
        _profileImage == null ||
        _idImage == null ||
        _selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill out all fields and upload all required images.')),
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

      String? profileImageUrl =
          await _uploadImage(File(_profileImage!.path), 'profileImages');
      String? idImageUrl = await _uploadImage(File(_idImage!.path), 'idImages');
      String? selfieImageUrl =
          await _uploadImage(File(_selfieImage!.path), 'selfieImages');
      if (profileImageUrl == null ||
          idImageUrl == null ||
          selfieImageUrl == null) {
        throw Exception('Failed to upload images.');
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
        'idImageUrl': idImageUrl,
        'selfieImageUrl': selfieImageUrl,
        'userType': 'Client',
        'patientName': _patientNameController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form data saved successfully')),
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

  void _nextStep() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _contactNumberController.text.isEmpty ||
        _expertiseController.text.isEmpty ||
        _patientNameController.text.isEmpty ||
        _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill out all fields and upload a profile image.')),
      );
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Registration'),
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
          child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
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
                  onPressed: () => _pickImage(ImageSource.gallery, 'profile'),
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
        DropdownButtonFormField<bool>(
          value: _isMale,
          onChanged: (bool? newValue) {
            setState(() {
              _isMale = newValue!;
            });
          },
          decoration: InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          items: const <DropdownMenuItem<bool>>[
            DropdownMenuItem<bool>(
              value: true,
              child: Text('Male'),
            ),
            DropdownMenuItem<bool>(
              value: false,
              child: Text('Female'),
            ),
          ],
        ),
        const SizedBox(height: 20),
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
            height: 58,
            width: double.infinity,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(_dob),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _contactNumberController,
          decoration: InputDecoration(
            labelText: 'Contact Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _expertiseController,
          decoration: InputDecoration(
            labelText: 'Expertise',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _patientNameController,
          decoration: InputDecoration(
            labelText: 'Patient Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isLoading ? null : _nextStep,
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text('Next'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        const Text(
          'Upload ID',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Center(
          child: Stack(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _idImage != null
                    ? Image.file(File(_idImage!.path), fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 50),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => _pickImage(ImageSource.gallery, 'id'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Selfie Verification',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Center(
          child: Stack(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selfieImage != null
                    ? Image.file(File(_selfieImage!.path), fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 50),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => _pickImage(ImageSource.camera, 'selfie'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
