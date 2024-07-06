// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seniorcare/homepage.dart';
import 'package:seniorcare/main.dart';
import 'package:seniorcare/savedpost.dart';
import 'package:seniorcare/userprofile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'messages.dart';
import 'notifications.dart';
// ignore: unused_import
import 'profile.dart';
import 'createpost.dart';
import 'caregivershomepage.dart';

class MainPage extends StatefulWidget {
  final String userType;
  final void Function() toggleTheme;

  const MainPage({
    Key? key,
    required this.userType,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String _accountName = 'Loading...';
  String _accountEmail = 'Loading...';
  String _profileImageUrl = '';

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            setState(() {
              _accountName =
                  '${userData['firstName'] ?? 'No First Name'} ${userData['lastName'] ?? 'No Last Name'}';
              _accountEmail = user.email ?? 'No Email';
              _profileImageUrl = userData['profileImageUrl'] ?? '';
            });
          } else {
            print('User document data is null.');
          }
        } else {
          print('User document does not exist in Firestore.');
        }
      } else {
        print('No current user in FirebaseAuth.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openSettingsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Settings'),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.times),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.lock),
                title: const Text('Change Password'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  _showPasswordChangeDialog();
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.trash),
                title: const Text('Delete Account'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  _confirmDeleteAccount();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(_newPasswordController.text);
        _showSuccessSnackbar("Password changed successfully.");
      }
    } catch (e) {
      _showErrorDialog("Password change failed: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        _showSuccessSnackbar("Account deleted successfully.");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(toggleTheme: widget.toggleTheme),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      _showErrorDialog("Account deletion failed: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPasswordChangeDialog() {
    bool _showPassword = false; // State variable to toggle password visibility

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Change Password'),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.times),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _passwordController,
                    obscureText:
                        !_showPassword, // Toggle visibility based on _showPassword
                    decoration: InputDecoration(
                      labelText: 'Old Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword =
                                !_showPassword; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _newPasswordController,
                    obscureText:
                        !_showPassword, // Toggle visibility based on _showPassword
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword =
                                !_showPassword; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText:
                        !_showPassword, // Toggle visibility based on _showPassword
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword =
                                !_showPassword; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueAccent),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delete Account'),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.times),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: const Text('Are you sure you want to delete this account?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _deleteAccount();
                    },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      widget.userType == 'Caregiver'
          ? CaregiversHomePage(toggleTheme: widget.toggleTheme)
          : HomePage(
              userType: widget.userType, toggleTheme: widget.toggleTheme),
      const MessagesPage(),
      const NotificationsPage(),
      UserProfilePage(
        userId: FirebaseAuth.instance.currentUser!.uid,
        isCurrentUser: true, // Ensure this flag is set
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('assets/images/logo.png'),
        ),
        actions: <Widget>[
          if (widget.userType == 'Client')
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.plus),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostPage(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.cog),
            onPressed: () {
              _openSettingsModal(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_accountName),
              accountEmail: Text(_accountEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : null,
                child: _profileImageUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 40.0,
                        color: Colors.grey,
                      )
                    : null,
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.userType ==
                        'Caregiver') // Conditionally show for caregivers
                      ListTile(
                        leading: const FaIcon(FontAwesomeIcons.solidBookmark),
                        title: const Text('Saved Posts'),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavedPostsPage(),
                            ),
                          );
                        },
                      ),
                    ListTile(
                      leading: const FaIcon(FontAwesomeIcons.solidMoon),
                      title: const Text('Dark Mode'),
                      onTap: widget.toggleTheme,
                    ),
                    ListTile(
                      leading: const FaIcon(FontAwesomeIcons.signOutAlt),
                      title: const Text('Logout'),
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginPage(toggleTheme: widget.toggleTheme),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidCommentDots),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidBell),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidUser),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
