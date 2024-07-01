import 'package:flutter/material.dart';

class CaregiversHomePage extends StatelessWidget {
  const CaregiversHomePage({super.key});

  // Function to handle applying to a post
  void _applyToPost(BuildContext context, int postId) {
    // Replace with your logic to handle applying to the post
    // ignore: avoid_print
    print('Applying to post with ID: $postId');
  }

  @override
  Widget build(BuildContext context) {
    // Dummy list of posts (replace with your actual data)
    final List<Post> posts = [
      Post(
        id: 1,
        title: 'Caregiver Needed',
        description: 'Looking for a caregiver for elderly person',
        location: 'New York, NY',
      ),
      Post(
        id: 2,
        title: 'Caregiver for Child',
        description: 'Childcare assistant needed for 5-year-old',
        location: 'Los Angeles, CA',
      ),
      Post(
        id: 3,
        title: 'Home Nurse Required',
        description: 'Nurse needed for medical care at home',
        location: 'Chicago, IL',
      ),
      // Add more posts as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregivers Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext context, int index) {
            final post = posts[index];
            return Card(
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(post.description),
                    const SizedBox(height: 8),
                    Text('Location: ${post.location}'),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => _applyToPost(context, post.id),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Dummy model class for Post
class Post {
  final int id;
  final String title;
  final String description;
  final String location;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
  });
}
