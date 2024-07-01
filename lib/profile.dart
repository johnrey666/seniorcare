import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example user profile
    final userProfile = UserProfile(
      username: 'John Rey Dado',
      avatarUrl:
          'https://scontent.fmnl8-2.fna.fbcdn.net/v/t1.6435-9/69831401_2217217731909906_2278803583040225280_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=53a332&_nc_eui2=AeFH7jUadCg5LzyR3nnKMSsPS1Lb2HEIcvFLUtvYcQhy8bB5NJIV0zqqRs7nrQk0DEKXLxgBuwE1xDjT_6UfwaGa&_nc_ohc=b6TKzUORKJQQ7kNvgGDoV8w&_nc_ht=scontent.fmnl8-2.fna&oh=00_AYBBiQshIxsVH5mCzrYeP9NrwU9VsuTBjUFg_2f5uEo1Lw&oe=66A92322',
      bio: 'Kergiber',
      starRating: 4.5,
      birthdate: '2003-02-04',
      expertise: 'Caregiverers',
      location: 'Legazpi City',
      isVerified: true,
      attachedFiles: [
        'https://cdn.enhancv.com/simple_double_column_resume_template_aecca5d139.png',
        'https://cdn.enhancv.com/simple_double_column_resume_template_aecca5d139.png',
        'https://cdn.enhancv.com/simple_double_column_resume_template_aecca5d139.png',
        // Add more file URLs here
      ],
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              username: userProfile.username,
              avatarUrl: userProfile.avatarUrl,
              bio: userProfile.bio,
              starRating: userProfile.starRating,
              birthdate: userProfile.birthdate,
              expertise: userProfile.expertise,
              location: userProfile.location,
              isVerified: userProfile.isVerified,
            ),
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
    );
  }
}

// ProfileHeader widget
class ProfileHeader extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final String bio;
  final double starRating;
  final String birthdate;
  final String expertise;
  final String location;
  final bool isVerified;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.starRating,
    required this.birthdate,
    required this.expertise,
    required this.location,
    required this.isVerified,
  });

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
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isVerified)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 20,
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    RatingBarIndicator(
                      rating: starRating,
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
          Text(bio),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.cake, size: 20),
              const SizedBox(width: 8),
              Text('Birthdate: $birthdate'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.work, size: 20),
              const SizedBox(width: 8),
              Text('Expertise: $expertise'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 8),
              Text('Location: $location'),
            ],
          ),
        ],
      ),
    );
  }
}

// FileGrid widget
class FileGrid extends StatelessWidget {
  final List<String> attachedFiles;

  const FileGrid({super.key, required this.attachedFiles});

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

// Placeholder for EditProfilePage
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: const Center(
        child: Text('Edit'),
      ),
    );
  }
}

// Define UserProfile class here or import from another file
class UserProfile {
  final String username;
  final String avatarUrl;
  final String bio;
  final double starRating;
  final String birthdate;
  final String expertise;
  final String location;
  final bool isVerified;
  final List<String> attachedFiles;

  UserProfile({
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.starRating,
    required this.birthdate,
    required this.expertise,
    required this.location,
    required this.isVerified,
    required this.attachedFiles,
  });
}
