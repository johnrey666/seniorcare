import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _expertiseController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  File? _profileImage;
  String? _profileImageUrl;
  bool _imageLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    var userData = snapshot.data() as Map<String, dynamic>;
    _firstNameController.text = userData['firstName'] ?? '';
    _lastNameController.text = userData['lastName'] ?? '';
    _expertiseController.text = userData['expertise'] ?? '';
    _locationController.text = userData['location'] ?? '';
    _contactNumberController.text = userData['contactNumber'] ?? '';
    var dobTimestamp = userData['dob'] as Timestamp?;
    if (dobTimestamp != null) {
      _selectedDate = dobTimestamp.toDate();
      _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }
    _profileImageUrl = userData['profileImageUrl'];

    setState(() {});
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = _profileImageUrl ?? '';

      if (_profileImage != null) {
        imageUrl = await _uploadProfileImage();
      }

      FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'expertise': _expertiseController.text,
        'location': _locationController.text,
        'contactNumber': _contactNumberController.text,
        'dob':
            _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'profileImageUrl': imageUrl,
      });

      Navigator.pop(context, true); // Pass true to indicate successful update
    }
  }

  Future<String> _uploadProfileImage() async {
    setState(() {
      _imageLoading = true;
    });

    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('${widget.userId}_profile.jpg');

    final UploadTask uploadTask = storageReference.putFile(_profileImage!);
    await uploadTask.whenComplete(() => null);
    final imageUrl = await storageReference.getDownloadURL();

    setState(() {
      _imageLoading = false;
    });

    return imageUrl;
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _getImage,
                    child: Stack(
                      children: [
                        _buildProfileImage(),
                        if (_imageLoading)
                          const Positioned.fill(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                ),
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                ),
                _buildTextField(
                  controller: _expertiseController,
                  label: 'Expertise',
                ),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                ),
                _buildTextField(
                  controller: _contactNumberController,
                  label: 'Contact Number',
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _dobController,
                      label: 'Date of Birth',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16),
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

  Widget _buildProfileImage() {
    if (_profileImage != null) {
      return ClipOval(
        child: Image.file(
          _profileImage!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _profileImageUrl!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          size: 100,
          color: Colors.grey,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
