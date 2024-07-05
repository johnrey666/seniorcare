import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserProfile userProfile; // Assume fetched UserProfile object

  @override
  void initState() {
    super.initState();
    // Simulated data, replace with actual Firestore data fetching logic
    userProfile = UserProfile(
      profileImageUrl:
          'https://scontent.fmnl8-2.fna.fbcdn.net/v/t1.6435-9/69831401_2217217731909906_2278803583040225280_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=53a332&_nc_eui2=AeFH7jUadCg5LzyR3nnKMSsPS1Lb2HEIcvFLUtvYcQhy8bB5NJIV0zqqRs7nrQk0DEKXLxgBuwE1xDjT_6UfwaGa&_nc_ohc=b6TKzUORKJQQ7kNvgGDoV8w&_nc_ht=scontent.fmnl8-2.fna&oh=00_AYBBiQshIxsVH5mCzrYeP9NrwU9VsuTBjUFg_2f5uEo1Lw&oe=66A92322',
      firstName: 'John Rey',
      lastName: 'Dado',
      bio: 'Kergiber',
      starRating: 4.5,
      dob: '2003-02-04',
      expertise: 'Caregiverers',
      location: 'Legazpi City',
      isVerified: true,
      contactNumber: '+1234567890',
      attachedFiles: [
        'https://cdn.enhancv.com/simple_double_column_resume_template_aecca5d139.png',
        'https://cdn.enhancv.com/simple_double_column_resume_template_aecca5d139.png',
        'https://cdn.enhancv.com/simple_double_column_resume_template_aecca5d139.png',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(userProfile: userProfile),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Attached Files',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FileGrid(attachedFiles: userProfile.attachedFiles),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(userProfile: userProfile),
            ),
          ).then((updatedProfile) {
            if (updatedProfile != null) {
              setState(() {
                userProfile = updatedProfile;
              });
            }
          });
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}

// ProfileHeader widget
class ProfileHeader extends StatelessWidget {
  final UserProfile userProfile;

  const ProfileHeader({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _getImageProvider(userProfile.profileImageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${userProfile.firstName} ${userProfile.lastName}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (userProfile.isVerified)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 20,
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    RatingBarIndicator(
                      rating: userProfile.starRating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(userProfile.bio),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.cake, size: 20),
              const SizedBox(width: 8),
              Text('Birthdate: ${userProfile.dob}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.work, size: 20),
              const SizedBox(width: 8),
              Text('Expertise: ${userProfile.expertise}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 8),
              Text('Location: ${userProfile.location}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 20),
              const SizedBox(width: 8),
              Text('Contact Number: ${userProfile.contactNumber}'),
            ],
          ),
        ],
      ),
    );
  }

  ImageProvider<Object>? _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return NetworkImage(imageUrl);
    } else {
      File file = File(imageUrl);
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        // Handle case where image path is not valid or image does not exist
        return null; // or return a default image provider as needed
      }
    }
  }
}

// FileGrid widget
class FileGrid extends StatelessWidget {
  final List<String> attachedFiles;

  const FileGrid({Key? key, required this.attachedFiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: attachedFiles.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: InteractiveViewer(
                      maxScale: 4.0,
                      child: Image.network(attachedFiles[index]),
                    ),
                  ),
                ),
              ),
            );
          },
          child: Image.network(attachedFiles[index]),
        );
      },
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({Key? key, required this.userProfile})
      : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _locationController;
  late TextEditingController _contactNumberController;
  late TextEditingController _expertiseController;
  late DateTime _dob;
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.userProfile.firstName);
    _lastNameController =
        TextEditingController(text: widget.userProfile.lastName);
    _locationController =
        TextEditingController(text: widget.userProfile.location);
    _contactNumberController =
        TextEditingController(text: widget.userProfile.contactNumber);
    _expertiseController =
        TextEditingController(text: widget.userProfile.expertise);
    _dob = DateTime.parse(widget.userProfile.dob);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _contactNumberController.dispose();
    _expertiseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    setState(() {
      _profileImage = image;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    UserProfile updatedProfile = UserProfile(
      profileImageUrl: widget.userProfile.profileImageUrl,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      bio: widget.userProfile.bio,
      starRating: widget.userProfile.starRating,
      dob: DateFormat('yyyy-MM-dd').format(_dob),
      expertise: _expertiseController.text,
      location: _locationController.text,
      isVerified: widget.userProfile.isVerified,
      contactNumber: _contactNumberController.text,
      attachedFiles: widget.userProfile.attachedFiles,
    );

    // Save profile logic here (e.g., update Firestore)

    Navigator.pop(context, updatedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Choose an option'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text('Camera'),
                                onTap: () {
                                  _pickImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text('Gallery'),
                                onTap: () {
                                  _pickImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(File(_profileImage!.path))
                          : null,
                    )),
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expertiseController,
                decoration: InputDecoration(labelText: 'Expertise'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your expertise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Date of Birth'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
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
                child: Text(DateFormat('yyyy-MM-dd').format(_dob)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfile {
  final String profileImageUrl;
  final String firstName;
  final String lastName;
  final String bio;
  final double starRating;
  final String dob;
  final String expertise;
  final String location;
  final bool isVerified;
  final String contactNumber;
  final List<String> attachedFiles;

  UserProfile({
    required this.profileImageUrl,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.starRating,
    required this.dob,
    required this.expertise,
    required this.location,
    required this.isVerified,
    required this.contactNumber,
    required this.attachedFiles,
  });
}
