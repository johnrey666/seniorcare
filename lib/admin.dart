import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  final void Function() toggleTheme;

  const AdminPage({Key? key, required this.toggleTheme});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _toggleVerification(String userId, bool currentStatus) async {
    await _firestore.collection('users').doc(userId).update({
      'isVerified': !currentStatus,
    });
  }

  Future<void> _toggleDisableAccount(String userId, bool currentStatus) async {
    await _firestore.collection('users').doc(userId).update({
      'isDisabled': !currentStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No users found.'));
          }
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['profileImage'] ?? ''),
                ),
                title: Text('${user['firstName']} ${user['lastName']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${user['email']}'),
                    Text('Verified: ${user['isVerified']}'),
                    Text('Disabled: ${user['isDisabled']}'),
                  ],
                ),
                trailing: Wrap(
                  spacing: 12, // space between two icons
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        user['isVerified'] ? Icons.verified : Icons.verified_outlined,
                        color: user['isVerified'] ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => _toggleVerification(
                        user.id,
                        user['isVerified'],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        user['isDisabled'] ? Icons.lock : Icons.lock_open,
                        color: user['isDisabled'] ? Colors.red : Colors.blue,
                      ),
                      onPressed: () => _toggleDisableAccount(
                        user.id,
                        user['isDisabled'],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
