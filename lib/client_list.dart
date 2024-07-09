import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientListPage extends StatelessWidget {
  const ClientListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: const ClientList(),
    );
  }
}

class ClientList extends StatelessWidget {
  const ClientList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'Client')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching clients'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> clients = snapshot.data!.docs;

        return ListView.builder(
          itemCount: clients.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                clients[index].data() as Map<String, dynamic>;

            String fullName =
                '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';
            String email = data['email'] ?? '';
            String profileImageUrl = data['profileImageUrl'] ?? '';

            bool isVerified = data['isVerified'] ?? false;
            bool isDisabled = data['isDisabled'] ?? false;

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: profileImageUrl.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(profileImageUrl),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      title: Text(fullName),
                      subtitle: Text(email),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Verification Status',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Switch(
                              value: isVerified,
                              onChanged: (newValue) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(clients[index].id)
                                    .update({'isVerified': newValue});
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              isDisabled ? 'Enable Account' : 'Disable Account',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            IconButton(
                              icon: isDisabled
                                  ? const Icon(Icons.check_circle)
                                  : const Icon(Icons.cancel),
                              onPressed: () {
                                // Toggle isDisabled status
                                bool newDisabledStatus = !isDisabled;

                                // Update Firestore document
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(clients[index].id)
                                    .update({'isDisabled': newDisabledStatus});

                                // Handle account disabling logic
                                if (newDisabledStatus) {
                                  // Notify the user their account is disabled, for example, through a notification or email
                                  // Optionally, sign the user out if they are currently logged in
                                } else {
                                  // Re-enable logic
                                  // Notify the user their account is re-enabled, for example, through a notification or email
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
