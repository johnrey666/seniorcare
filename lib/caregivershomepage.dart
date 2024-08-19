import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userprofile.dart'; // Import your UserProfilePage
import 'mapping.dart'; // Import your MapPage

class CaregiversHomePage extends StatefulWidget {
  final void Function() toggleTheme;

  const CaregiversHomePage({super.key, required this.toggleTheme});

  @override
  _CaregiversHomePageState createState() => _CaregiversHomePageState();
}

class _CaregiversHomePageState extends State<CaregiversHomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> posts = [];
  List<String> savedPosts = []; // List to store saved post IDs
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 5;
  DocumentSnapshot? lastDocument;

  @override
  void initState() {
    super.initState();
    _getPosts();
  }

  Future<void> _getPosts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot;

    if (lastDocument == null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get();
    }

    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }

    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      posts.addAll(querySnapshot.docs);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 24), // Adjust padding
              ),
              child: const Text(
                'Find Job Opportunities Near You',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(
                height: 16), // Add spacing between the button and the list
            Expanded(
              child: ListView.builder(
                itemCount: posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    if (hasMore) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: _getPosts,
                            child: const Text('See More'),
                          ),
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text('No more posts'),
                        ),
                      );
                    }
                  }

                  var post = posts[index];
                  var data = post.data() as Map<String, dynamic>;

                  var userName =
                      '${data['firstName'] ?? 'Anonymous'} ${data['lastName'] ?? ''}';
                  var userPhotoUrl = data['profileImageUrl'] ?? '';
                  var title = data['title'] ?? 'No Title';
                  var description = data['description'] ?? 'No Description';
                  var location = data['location'] ?? 'No Location';
                  var imagePath = data['imagePath'];
                  var clientId = data['userId'];
                  var postId = post.id;

                  bool isPostSaved = savedPosts.contains(postId);

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfilePage(
                                    userId: clientId,
                                    isCurrentUser: currentUser?.uid == clientId,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: userPhotoUrl.isNotEmpty
                                      ? NetworkImage(userPhotoUrl)
                                      : const AssetImage(
                                              'assets/default_avatar.jpg')
                                          as ImageProvider,
                                  radius: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        location,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: isPostSaved
                                      ? const Icon(Icons.bookmark)
                                      : const Icon(Icons.bookmark_border),
                                  onPressed: () {
                                    setState(() {
                                      if (isPostSaved) {
                                        savedPosts.remove(postId);
                                      } else {
                                        savedPosts.add(postId);
                                      }
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Post Saved!'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (imagePath != null)
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imagePath),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(1),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  _showApplyConfirmationDialog(
                                      context, clientId, postId);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  // Function to show confirmation dialog
  void _showApplyConfirmationDialog(
      BuildContext context, String clientId, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Application'),
        content:
            const Text('Do you want to send an application for this post?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Apply'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _applyForJob(clientId, postId);
            },
          ),
        ],
      ),
    );
  }

  // Modified function to apply for a job
  Future<void> _applyForJob(String clientId, String postId) async {
    // Check if the user has already applied for this post
    var existingApplication = await FirebaseFirestore.instance
        .collection('hireRequests')
        .where('senderId', isEqualTo: currentUser!.uid)
        .where('postId', isEqualTo: postId)
        .get();

    if (existingApplication.docs.isNotEmpty) {
      // Show message if already applied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already applied for this post.'),
        ),
      );
      return;
    }

    // Fetch the current user's details from Firestore to ensure we have the most up-to-date information
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    String senderName = userDoc['firstName'] + ' ' + userDoc['lastName'];
    String avatarUrl = userDoc['profileImageUrl'] ?? '';

    // If not applied yet, send the application
    await FirebaseFirestore.instance.collection('hireRequests').add({
      'senderId': currentUser!.uid,
      'caregiverId': clientId,
      'postId': postId,
      'senderName': senderName,
      'avatarUrl': avatarUrl,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application sent successfully!'),
      ),
    );
  }
}
