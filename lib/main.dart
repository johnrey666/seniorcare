// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'caregiver_form.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// Notification model
class Notification {
  final String senderName;
  final String avatarUrl;
  final String action;

  Notification(
      {required this.senderName,
      required this.avatarUrl,
      required this.action});
}

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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // Light mode by default

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navigation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: LoginPage(toggleTheme: _toggleTheme),
    );
  }
}

// Login Page
class LoginPage extends StatefulWidget {
  final void Function() toggleTheme;
  const LoginPage({super.key, required this.toggleTheme});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.png',
                height: 30,
                width: 250,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.black87),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black87),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.visibility_off),
                    onPressed: () {},
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainPage(toggleTheme: widget.toggleTheme)),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SignUpPage(toggleTheme: widget.toggleTheme)),
                  );
                },
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                ),
                child: const Text('Don`t have an account yet? Sign Up'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Sign Up Page
class SignUpPage extends StatefulWidget {
  final void Function() toggleTheme;
  const SignUpPage({super.key, required this.toggleTheme});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedUserType;

  final List<String> _userTypes = ['Caregiver', 'Client'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.png',
                height: 30,
                width: 250,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.black87),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black87),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: const TextStyle(color: Colors.black87),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedUserType,
                decoration: InputDecoration(
                  labelText: 'User Type',
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                items: _userTypes.map((String userType) {
                  return DropdownMenuItem<String>(
                    value: userType,
                    child: Text(userType),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUserType = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedUserType == 'Caregiver') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CaregiverFormPage(
                              toggleTheme: widget.toggleTheme)),
                    );
                  } else {
                    // Handle client sign-up logic here
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LoginPage(toggleTheme: widget.toggleTheme)),
                  );
                },
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                ),
                child: const Text('Already have an account? Log In'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Main Page with Bottom Navigation and Drawer
class MainPage extends StatefulWidget {
  final void Function() toggleTheme;
  const MainPage({super.key, required this.toggleTheme});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MessagesPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Image.asset(
                'assets/images/logo.png')), // Displaying the logo centered
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.dark_mode), // Dark mode toggle icon
            onPressed: widget.toggleTheme, // Toggle dark mode
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  'Navigation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const Spacer(), // Pushes the logout button to the bottom
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(toggleTheme: widget.toggleTheme)),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Selected icon color
        unselectedItemColor: Colors.grey, // Unselected icon color
        backgroundColor: Colors.blue, // Background color
        onTap: _onItemTapped,
      ),
    );
  }
}

// Home Page with Card Grid and Modal Detail View
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image or Avatar Placeholder
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'LastName, Fname',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text('Caregiver'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 24,
                        );
                      }),
                    ),
                    const SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        // Handle view all reviews action
                      },
                      child: const Text('View all reviews'),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Expertise:'),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Age:'),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Location:'),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Contact Number:'),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DOCUMENTS ATTACH',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.attach_file,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.attach_file,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: 10, // Number of items
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            mainAxisSpacing: 8.0, // Vertical spacing between items
            crossAxisSpacing: 8.0, // Horizontal spacing between items
            childAspectRatio: 0.75, // Aspect ratio to control height/width
          ),
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 3.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      color: Colors.grey[300], // Image placeholder color
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return const Icon(
                          Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'LastName, Fname',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _showDetails(context),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(horizontal: 16)),
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          const TextStyle(fontSize: 14),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      child: const Text('View'),
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

// Main app entry point remains unchanged

// Messages Page
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final List<Message> messages = [
      Message(
        sender: 'John Rey Dado',
        text: 'Hello, how are you?',
        avatarUrl:
            'https://scontent.fmnl8-2.fna.fbcdn.net/v/t1.6435-9/69831401_2217217731909906_2278803583040225280_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=53a332&_nc_eui2=AeFH7jUadCg5LzyR3nnKMSsPS1Lb2HEIcvFLUtvYcQhy8bB5NJIV0zqqRs7nrQk0DEKXLxgBuwE1xDjT_6UfwaGa&_nc_ohc=b6TKzUORKJQQ7kNvgGDoV8w&_nc_ht=scontent.fmnl8-2.fna&oh=00_AYBBiQshIxsVH5mCzrYeP9NrwU9VsuTBjUFg_2f5uEo1Lw&oe=66A92322', // Placeholder image URL
        time: '2m ago',
      ),
      Message(
        sender: 'Anthony Renzo Zuñiga',
        text: 'Mano, miss ko na si mailah',
        avatarUrl:
            'https://scontent.fmnl8-1.fna.fbcdn.net/v/t39.30808-1/368026047_1788561318228013_224250882585157351_n.jpg?stp=dst-jpg_s200x200&_nc_cat=100&ccb=1-7&_nc_sid=0ecb9b&_nc_eui2=AeG1bNLQ_vgERvrkD4aWVvB8aq1ONyjtactqrU43KO1pyyw9xOHdg1qYmIUtvJ8VRjVO5m4A9lVJt2f0qz4RptZk&_nc_ohc=toVV0aPBWbkQ7kNvgEysEoP&_nc_ht=scontent.fmnl8-1.fna&oh=00_AYACa-up-qsDkZEJpfxnIDQHrwUlcCihpDTVnXa1-hcuJw&oe=66875C0B',
        time: '1h ago',
      ),
      Message(
        sender: 'Jay-ar Baloloy',
        text: 'ayawkol',
        avatarUrl:
            'https://scontent.fmnl8-3.fna.fbcdn.net/v/t39.30808-1/339443135_1264591487776723_1686334611574014372_n.jpg?stp=c0.0.200.200a_dst-jpg_p200x200&_nc_cat=101&ccb=1-7&_nc_sid=0ecb9b&_nc_eui2=AeF16R7J4CQhbnsE_d0yJe9CNpZK-nCbh-o2lkr6cJuH6pZwd5_Xeu7rC5ookz6Tw8oYWo1__plts-zcXiji7l_j&_nc_ohc=iIRsCbDDOcoQ7kNvgHuko_W&_nc_ht=scontent.fmnl8-3.fna&oh=00_AYBE77uR4TZtAgDskHB5yQFqkYXTN27NWiIpn9euPo0n5Q&oe=66878230',
        time: '1h ago',
      ),
      Message(
        sender: 'Angelo Bautista',
        text: 'Tite ni mano',
        avatarUrl:
            'https://scontent.fmnl8-2.fna.fbcdn.net/v/t39.30808-1/435612700_2488039958049317_8622276536411312900_n.jpg?stp=dst-jpg_s200x200&_nc_cat=103&ccb=1-7&_nc_sid=0ecb9b&_nc_eui2=AeFlGJS3eaVeg41BscfRW8Jmb-z6_feOLHJv7Pr9944scruK2dD2Pq25JKAi4XI85zUv6MeeOhPjHwK8TGhDh8_f&_nc_ohc=dvwl8ckdUjYQ7kNvgFss7ym&_nc_ht=scontent.fmnl8-2.fna&oh=00_AYClwt0kqAwfPI8J4ujkbM-b3HFR8QMQ_seA_zQ96DoZyA&oe=66877D58',
        time: '1h ago',
      ),
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(message.avatarUrl),
            ),
            title: Text(message.sender),
            subtitle: Text(message.text),
            trailing: Text(message.time),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationPage(
                    sender: message.sender,
                    avatarUrl: message.avatarUrl,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Message model
class Message {
  final String sender;
  final String text;
  final String avatarUrl;
  final String time;

  Message({
    required this.sender,
    required this.text,
    required this.avatarUrl,
    required this.time,
  });
}

// Conversation Page
class ConversationPage extends StatelessWidget {
  final String sender;
  final String avatarUrl;

  const ConversationPage({
    super.key,
    required this.sender,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Sample data for conversation
    final List<Message> conversation = [
      Message(
          sender: 'Alice',
          text: 'Hello, how are you?',
          avatarUrl: avatarUrl,
          time: '2m ago'),
      Message(
          sender: 'You',
          text: 'I am good, how about you?',
          avatarUrl: avatarUrl,
          time: '1m ago'),
      // Add more sample messages here
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(sender),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: conversation.length,
              itemBuilder: (context, index) {
                final message = conversation[index];
                return ListTile(
                  leading: message.sender == 'You'
                      ? null
                      : CircleAvatar(
                          backgroundImage: NetworkImage(message.avatarUrl),
                        ),
                  title: Align(
                    alignment: message.sender == 'You'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: message.sender == 'You'
                            ? Colors.blue[100]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(message.text),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Handle send message action
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Notification item widget
class NotificationItem extends StatelessWidget {
  final String senderName;
  final String avatarUrl;
  final String action;
  final VoidCallback onActionPressed;

  const NotificationItem({
    super.key,
    required this.senderName,
    required this.avatarUrl,
    required this.action,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Text('$senderName sent an application'),
      trailing: ElevatedButton(
        onPressed: onActionPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(action),
      ),
    );
  }
}

// Notifications page
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example notifications
    final notifications = [
      Notification(
          senderName: 'John Rey Dado',
          avatarUrl:
              'https://scontent.fmnl8-2.fna.fbcdn.net/v/t1.6435-9/69831401_2217217731909906_2278803583040225280_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=53a332&_nc_eui2=AeFH7jUadCg5LzyR3nnKMSsPS1Lb2HEIcvFLUtvYcQhy8bB5NJIV0zqqRs7nrQk0DEKXLxgBuwE1xDjT_6UfwaGa&_nc_ohc=b6TKzUORKJQQ7kNvgGDoV8w&_nc_ht=scontent.fmnl8-2.fna&oh=00_AYBBiQshIxsVH5mCzrYeP9NrwU9VsuTBjUFg_2f5uEo1Lw&oe=66A92322',
          action: 'View'),
      Notification(
          senderName: 'Anthony Renzo Zuniga',
          avatarUrl:
              'https://scontent.fmnl8-1.fna.fbcdn.net/v/t39.30808-1/368026047_1788561318228013_224250882585157351_n.jpg?stp=dst-jpg_s200x200&_nc_cat=100&ccb=1-7&_nc_sid=0ecb9b&_nc_eui2=AeG1bNLQ_vgERvrkD4aWVvB8aq1ONyjtactqrU43KO1pyyw9xOHdg1qYmIUtvJ8VRjVO5m4A9lVJt2f0qz4RptZk&_nc_ohc=toVV0aPBWbkQ7kNvgEysEoP&_nc_ht=scontent.fmnl8-1.fna&oh=00_AYACa-up-qsDkZEJpfxnIDQHrwUlcCihpDTVnXa1-hcuJw&oe=66875C0B',
          action: 'View'),
      // Add more notifications here
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItem(
            senderName: notification.senderName,
            avatarUrl: notification.avatarUrl,
            action: notification.action,
            onActionPressed: () {
              // Handle view action
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Application from ${notification.senderName}'),
                    content: const Text('Viewing application details...'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
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

  // ignore: use_key_in_widget_constructors
  const FileGrid({Key? key, required this.attachedFiles});

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

// ProfilePage widget
class ProfilePage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ProfilePage({Key? key});

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

// Placeholder for EditProfilePage
class EditProfilePage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const EditProfilePage({Key? key});

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
