import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiversHomePage extends StatelessWidget {
  final void Function() toggleTheme;

  const CaregiversHomePage({Key? key, required this.toggleTheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 1.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
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

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: userPhotoUrl.isNotEmpty
                                ? NetworkImage(userPhotoUrl)
                                : const AssetImage('assets/default_avatar.jpg')
                                    as ImageProvider,
                            child: userPhotoUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 8.0),
                          Text(userName),
                          const Spacer(),
                          const Icon(Icons.bookmark_border),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 241, 199, 139),
                            width: 0.5,
                          ),
                          color: Colors.grey[300],
                        ),
                        child: imagePath != null
                            ? Image.network(
                                imagePath,
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: 200, // Set height here
                              )
                            : Center(
                                child: Icon(Icons.image,
                                    size: 100, color: Colors.grey[700]),
                              ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 4.0),
                          Text(location),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          // Implement apply functionality here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          textStyle: const TextStyle(color: Colors.white),
                          minimumSize: const Size(150, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                      const Divider(),
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
}
