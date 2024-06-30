import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CaregiverFormPage extends StatefulWidget {
  final void Function() toggleTheme;
  const CaregiverFormPage({super.key, required this.toggleTheme});

  @override
  // ignore: library_private_types_in_public_api
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
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
                  labelText: 'Area of Expertise',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle caregiver form submission logic here
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
