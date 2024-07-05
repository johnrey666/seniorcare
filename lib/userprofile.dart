import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class UserProfilePage extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const UserProfilePage({
    Key? key,
    required this.userId,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<DocumentSnapshot> userFuture;
  String fullName = 'User Profile';

  @override
  void initState() {
    super.initState();
    userFuture =
        FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    _fetchUserData();
  }

  void _fetchUserData() async {
    var snapshot = await userFuture;
    if (snapshot.exists) {
      var userData = snapshot.data() as Map<String, dynamic>;
      String first = userData['firstName'] ?? '';
      String last = userData['lastName'] ?? '';
      setState(() {
        fullName = '${first.capitalize()} ${last.capitalize()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isCurrentUser
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              iconTheme:
                  const IconThemeData(color: Color.fromARGB(255, 52, 68, 76)),
              titleTextStyle: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0,
              title: Text(fullName),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String firstName = userData['firstName'] ?? '';
          String lastName = userData['lastName'] ?? '';
          String avatarUrl = userData['profileImageUrl'] ?? '';
          String patientName = userData['patientName'] ?? '';
          String expertise = userData['expertise'] ?? '';
          String location = userData['location'] ?? '';
          String contactNumber = userData['contactNumber'] ?? '';
          Timestamp? dobTimestamp = userData['dob'];
          String dob = dobTimestamp != null
              ? DateFormat('yyyy-MM-dd').format(dobTimestamp.toDate())
              : 'Not provided';
          List<String> optionalFilesUrls = userData['optionalFilesUrls'] != null
              ? List<String>.from(userData['optionalFilesUrls'])
              : [];

          bool isClientUser = userData['userType'] == 'Client';
          bool isVerified = userData['isVerified'] ?? true;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        image: avatarUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage('assets/default_avatar.png'),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    if (widget.isCurrentUser)
                      Positioned(
                        bottom: 8,
                        right: 16,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Handle edit profile action
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit profile action'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$firstName $lastName',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isVerified)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const StarRating(
                        rating: 4,
                        size: 30,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      if (isClientUser)
                        ProfileDetail(
                          icon: Icons.person,
                          title: 'Patient Name',
                          value: patientName,
                          textColor: Colors.lightBlue,
                          iconColor: Colors.blue,
                        ),
                      ProfileDetail(
                        icon: Icons.work,
                        title: 'Expertise',
                        value: expertise,
                        textColor: Colors.lightBlue,
                        iconColor: Colors.blue,
                      ),
                      ProfileDetail(
                        icon: Icons.location_on,
                        title: 'Location',
                        value: location,
                        textColor: Colors.lightBlue,
                        iconColor: Colors.blue,
                      ),
                      ProfileDetail(
                        icon: Icons.phone,
                        title: 'Contact',
                        value: contactNumber,
                        textColor: Colors.lightBlue,
                        iconColor: Colors.blue,
                      ),
                      ProfileDetail(
                        icon: Icons.cake,
                        title: 'Date of Birth',
                        value: dob,
                        textColor: Colors.lightBlue,
                        iconColor: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Attached Documents',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      optionalFilesUrls.isNotEmpty
                          ? GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: optionalFilesUrls.length,
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
                                              child: Image.network(
                                                  optionalFilesUrls[index]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        optionalFilesUrls[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Text(
                              'No optional files available.',
                              style: TextStyle(color: Colors.grey),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final int rating;
  final double size;
  final Color color;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 24,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: color,
          size: size,
        );
      }),
    );
  }
}

class ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? textColor;
  final Color? iconColor;

  const ProfileDetail({
    required this.icon,
    required this.title,
    required this.value,
    this.textColor,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? Colors.blueGrey,
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor ?? Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
