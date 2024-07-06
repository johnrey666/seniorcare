import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seniorcare/main.dart';

class AdminPage extends StatelessWidget {
  final void Function() toggleTheme;

  const AdminPage({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
ListTile(
                      leading: const FaIcon(FontAwesomeIcons.solidMoon),
                      title: const Text('Dark Mode'),
                      onTap: toggleTheme,
                    ),
                    ListTile(
                      leading: const FaIcon(FontAwesomeIcons.rightFromBracket),
                      title: const Text('Logout'),
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginPage(toggleTheme: toggleTheme),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
            
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ClientList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Caregivers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: CaregiverList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientList extends StatelessWidget {
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

            return ListTile(
              leading: profileImageUrl.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                    )
                  : CircleAvatar(
                      child: const Icon(Icons.person),
                    ),
              title: Text(fullName),
              subtitle: Text(email),
              trailing: Switch(
                value: data['isVerified'] ?? false,
                onChanged: (newValue) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(clients[index].id)
                      .update({'isVerified': newValue});
                },
              ),
            );
          },
        );
      },
    );
  }
}

class CaregiverList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'Caregiver')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching caregivers'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> caregivers = snapshot.data!.docs;

        return ListView.builder(
          itemCount: caregivers.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                caregivers[index].data() as Map<String, dynamic>;

            String fullName =
                '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';
            String email = data['email'] ?? '';
            String profileImageUrl = data['profileImageUrl'] ?? '';

            return ListTile(
              leading: profileImageUrl.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                    )
                  : CircleAvatar(
                      child: const Icon(Icons.person),
                    ),
              title: Text(fullName),
              subtitle: Text(email),
              trailing: Switch(
                value: data['isVerified'] ?? false,
                onChanged: (newValue) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(caregivers[index].id)
                      .update({'isVerified': newValue});
                },
              ),
            );
          },
        );
      },
    );
  }
}
