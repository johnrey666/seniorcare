import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user details'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          String fullName =
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';
          String email = data['email'] ?? '';
          String profileImageUrl = data['profileImageUrl'] ?? '';
          String contactNumber = data['contactNumber'] ?? '';
          String dob = data['dob'] != null
              ? (data['dob'] as Timestamp).toDate().toString()
              : '';
          String expertise = data['expertise'] ?? '';
          String gender = data['gender'] ?? '';
          String location = data['location'] ?? '';
          bool isVerified = data['isVerified'] ?? false;
          bool isDisabled = data['isDisabled'] ?? false;

          // Additional fields for ID, Selfie, and Optional Files
          String idImageUrl = data['idImageUrl'] ?? '';
          String selfieImageUrl = data['selfieImageUrl'] ?? '';
          List<dynamic> optionalFilesUrls = data['optionalFilesUrls'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(fullName, style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 10),
                Text(email),
                const SizedBox(height: 10),
                Text('Contact: $contactNumber'),
                const SizedBox(height: 10),
                Text('Date of Birth: $dob'),
                const SizedBox(height: 10),
                Text('Expertise: $expertise'),
                const SizedBox(height: 10),
                Text('Gender: $gender'),
                const SizedBox(height: 10),
                Text('Location: $location'),
                const Divider(height: 30),

                // ID Image
                if (idImageUrl.isNotEmpty) ...[
                  const Text('ID Submitted'),
                  const SizedBox(height: 10),
                  Image.network(idImageUrl, height: 200),
                  const SizedBox(height: 20),
                ],

                // Selfie Image
                if (selfieImageUrl.isNotEmpty) ...[
                  const Text('Selfie Verification'),
                  const SizedBox(height: 10),
                  Image.network(selfieImageUrl, height: 200),
                  const SizedBox(height: 20),
                ],

                // Optional Files
                if (optionalFilesUrls.isNotEmpty) ...[
                  const Text('Optional Files'),
                  const SizedBox(height: 10),
                  Column(
                    children: optionalFilesUrls
                        .map((url) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.network(url, height: 200),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                SwitchListTile(
                  title: const Text('Verification Status'),
                  value: isVerified,
                  onChanged: (newValue) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({'isVerified': newValue});
                  },
                ),
                ListTile(
                  title:
                      Text(isDisabled ? 'Enable Account' : 'Disable Account'),
                  trailing:
                      Icon(isDisabled ? Icons.check_circle : Icons.cancel),
                  onTap: () {
                    bool newDisabledStatus = !isDisabled;

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({'isDisabled': newDisabledStatus});

                    // Optionally notify the user or take action on disable/enable
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
