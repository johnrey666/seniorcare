import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userprofile.dart'; // Import your UserProfilePage

class CaregiversHomePage extends StatefulWidget {
  final void Function() toggleTheme;

  const CaregiversHomePage({Key? key, required this.toggleTheme})
      : super(key: key);

  @override
  _CaregiversHomePageState createState() => _CaregiversHomePageState();
}

class _CaregiversHomePageState extends State<CaregiversHomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  List<String> savedPosts = []; // List to store saved post IDs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search_sharp),
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var post = snapshot.data!.docs[index];

                // Safely extract fields with null checks
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
                            // Navigate to UserProfilePage
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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

                                  // Show Snackbar
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
                                _applyForJob(
                                  clientId,
                                  currentUser!.uid,
                                  userName,
                                  currentUser?.displayName ?? 'Anonymous',
                                  userPhotoUrl,
                                );
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
            );
          },
        ),
      ),
    );
  }

  Future<void> _applyForJob(String clientId, String caregiverId,
      String clientName, String caregiverName, String caregiverPhotoUrl) async {
    await FirebaseFirestore.instance.collection('hireRequests').add({
      'senderId': caregiverId,
      'caregiverId': clientId,
      'senderName': caregiverName,
      'avatarUrl': caregiverPhotoUrl,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
