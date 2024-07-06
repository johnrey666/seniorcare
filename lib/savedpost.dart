import 'package:flutter/material.dart';

class SavedPostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch saved posts for the current user
    List<String> savedPosts = []; // Replace with actual logic to fetch saved posts

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: ListView.builder(
        itemCount: savedPosts.length,
        itemBuilder: (context, index) {
          var postId = savedPosts[index];

          // Use postId to fetch and display each saved post
          return ListTile(
            title: Text('Post ID: $postId'), // Replace with actual post content
          );
        },
      ),
    );
  }
}
