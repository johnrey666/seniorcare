import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reportedPosts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var reportedPosts = snapshot.data!.docs;

          if (reportedPosts.isEmpty) {
            return const Center(
              child: Text(
                'No reports yet.',
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          return ListView.builder(
            itemCount: reportedPosts.length,
            itemBuilder: (context, index) {
              var report = reportedPosts[index];
              var reportedBy = report['reportedBy'];
              var postId = report['postId'];

              // Fetch post details from Firestore
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .get(),
                builder: (context, postSnapshot) {
                  if (!postSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var post = postSnapshot.data!.data() as Map<String, dynamic>?;
                  if (post == null) {
                    return const SizedBox();
                  }

                  var title = post['title'] ?? 'No Title';
                  var description = post['description'] ?? 'No Description';
                  var imagePath = post['imagePath'];
                  var userName =
                      '${post['firstName'] ?? 'Anonymous'} ${post['lastName'] ?? ''}';
                  var userPhotoUrl = post['profileImageUrl'] ?? '';

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: userPhotoUrl.isNotEmpty
                                ? NetworkImage(userPhotoUrl)
                                : const AssetImage('assets/default_avatar.jpg')
                                    as ImageProvider,
                          ),
                          title: Text(userName),
                          subtitle:
                              Text('This post is reported by $reportedBy'),
                        ),
                        if (imagePath != null)
                          Image.network(
                            imagePath,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(description),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(postId)
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Post deleted successfully!'),
                                ),
                              );
                            },
                            child: const Text('Delete Post'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
