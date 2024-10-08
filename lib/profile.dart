import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'edit_profile_page.dart'; // Import the EditProfilePage
import 'all_review.dart'; // Import the AllReviewPage

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
  List<Post> userPosts = [];
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    userFuture =
        FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    _fetchUserData();
    _fetchUserPosts();
    _fetchAverageRating();
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

  void _fetchUserPosts() async {
    var postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: widget.userId)
        .get();

    setState(() {
      userPosts =
          postsSnapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  void _fetchAverageRating() async {
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: widget.userId)
        .get();

    if (reviewsSnapshot.docs.isNotEmpty) {
      double totalRating = 0.0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += doc['rating'];
      }

      setState(() {
        averageRating = totalRating / reviewsSnapshot.docs.length;
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
              iconTheme: const IconThemeData(
                color: Color.fromARGB(255, 52, 68, 76),
              ),
              titleTextStyle: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0,
              title: Text(fullName),
              leading: IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowLeft),
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
                            // Navigate to EditProfilePage
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  userId: widget.userId,
                                ),
                              ),
                            )
                                .then((_) {
                              // Refresh the user data after returning from edit
                              setState(() {
                                userFuture = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.userId)
                                    .get();
                                _fetchUserData();
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(255, 255, 255, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const FaIcon(
                            FontAwesomeIcons.pen,
                            color: Colors.blue,
                          ),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors
                                      .white, // Adjust text color for dark mode
                            ),
                          ),
                          if (isVerified)
                            const Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'verified',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      StarRating(
                        rating: averageRating,
                        size: 30,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllReviewPage(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'View all reviews',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isClientUser)
                        ProfileDetail(
                          icon: FontAwesomeIcons.person,
                          title: 'Patient Name',
                          value: patientName,
                          textColor: Colors.grey,
                        ),
                      ProfileDetail(
                        icon: FontAwesomeIcons.briefcase,
                        title: 'Expertise',
                        value: expertise,
                        textColor: Colors.grey,
                      ),
                      ProfileDetail(
                        icon: FontAwesomeIcons.locationDot,
                        title: 'Location',
                        value: location,
                        textColor: Colors.grey,
                      ),
                      ProfileDetail(
                        icon: FontAwesomeIcons.phone,
                        title: 'Contact',
                        value: contactNumber,
                        textColor: Colors.grey,
                      ),
                      ProfileDetail(
                        icon: FontAwesomeIcons.calendarWeek,
                        title: 'Date of Birth',
                        value: dob,
                        textColor: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      if (isClientUser)
                        const Text(
                          'Recent Posts',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (isClientUser)
                        if (userPosts.isEmpty)
                          const Center(
                            child: Text('No posts yet.'),
                          )
                        else
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: userPosts.length,
                            itemBuilder: (context, index) {
                              var post = userPosts[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (post.imagePath != null)
                                      Image.network(
                                        post.imagePath!,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.title,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            post.description,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Location: ${post.location}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      const SizedBox(height: 16),
                      if (!isClientUser)
                        const Text(
                          'Attached Documents',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (optionalFilesUrls.isNotEmpty)
                        GridView.builder(
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
                      else if (!isClientUser)
                        const Text(
                          'No files available',
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
  final double rating;
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
        if (index < rating.floor()) {
          return Icon(
            Icons.star,
            color: color,
            size: size,
          );
        } else if (index < rating) {
          return Icon(
            Icons.star_half,
            color: color,
            size: size,
          );
        } else {
          return Icon(
            Icons.star_border,
            color: color,
            size: size,
          );
        }
      }),
    );
  }
}

class ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? textColor;

  const ProfileDetail({
    required this.icon,
    required this.title,
    required this.value,
    this.textColor,
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
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.blueGrey
                : Colors.white, // Adjust icon color for dark mode
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white, // Adjust title color for dark mode
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor ??
                        (Theme.of(context).brightness == Brightness.light
                            ? Colors.black54
                            : Colors.white), // Adjust text color for dark mode
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

class Post {
  final String title;
  final String description;
  final String location;
  final String? imagePath;

  Post({
    required this.title,
    required this.description,
    required this.location,
    this.imagePath,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Post(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      imagePath: data['imagePath'],
    );
  }
}
