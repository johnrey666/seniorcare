import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

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
  final TextEditingController _patientNameController = TextEditingController();
  DateTime _dob = DateTime.now();
  bool _isMale = true;
  String _expertise = '';
  String _condition = '';
  bool _agreedToShareInfo = false;
  XFile? _uploadedImage;
  XFile? _selfieVerification;

  final List<String> _expertiseList = [
    'Elderly Care',
    'Child Care',
    'Disability Support',
    'Nursing',
  ];

  Future<void> _pickImage(
      ImageSource source, Function(XFile?) onSelected) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    onSelected(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _uploadedImage != null
                            ? FileImage(File(_uploadedImage!.path))
                            : null,
                        child: _uploadedImage == null
                            ? const Icon(Icons.image, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () =>
                              _pickImage(ImageSource.gallery, (image) {
                            setState(() {
                              _uploadedImage = image;
                            });
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
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
                  controller: _patientNameController,
                  decoration: InputDecoration(
                    labelText: 'Patient Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  style: const TextStyle(fontSize: 14),
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
                // Date of Birth section
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Date of Birth:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
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
                            borderRadius: BorderRadius.circular(
                                24), // More rounded corners
                          ),
                          child: Center(
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_dob),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _expertise.isEmpty ? null : _expertise,
                  decoration: InputDecoration(
                    labelText: 'Preferred Caregiver Expertise',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  items: _expertiseList.map((String expertise) {
                    return DropdownMenuItem<String>(
                      value: expertise,
                      child: Text(expertise),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _expertise = newValue ?? '';
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: TextEditingController(text: _condition),
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (value) {
                    setState(() {
                      _condition = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera, (image) {
                      setState(() {
                        _selfieVerification = image;
                      });
                    }),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _selfieVerification != null
                          ? FileImage(File(_selfieVerification!.path))
                          : null,
                      child: _selfieVerification == null
                          ? const Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: CheckboxListTile(
                    title: const Text('I Agree to share these informations'),
                    value: _agreedToShareInfo,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreedToShareInfo = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Buttons in the same row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to previous screen
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15)), // Adjusted padding
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 20), // Spacing between buttons
                    ElevatedButton(
                      onPressed: () {
                        // Handle client form submission logic here
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blueAccent),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15)), // Adjusted padding
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
