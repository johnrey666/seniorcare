import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seniorcare/main.dart';
import 'caregiver_list.dart';
import 'client_list.dart';

class AdminPage extends StatelessWidget {
  final void Function() toggleTheme;

  const AdminPage({super.key, required this.toggleTheme});

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
                    builder: (context) => LoginPage(toggleTheme: toggleTheme),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: const DefaultTabController(
        length: 2, // Number of tabs
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  ClientListPage(),
                  CaregiverListPage(),
                ],
              ),
            ),
            TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.people),
                  text: 'Clients',
                ),
                Tab(
                  icon: Icon(Icons.people_outline),
                  text: 'Caregivers',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
