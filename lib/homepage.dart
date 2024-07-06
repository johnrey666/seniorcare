import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seniorcare/userprofile.dart';

class HomePage extends StatefulWidget {
  final void Function() toggleTheme;

  const HomePage({
    super.key,
    required this.toggleTheme,
    required String userType,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  String calculateAge(Timestamp dob) {
    DateTime now = DateTime.now();
    DateTime birthDate = dob.toDate();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return '$age years old';
  }

  Future<void> _hireCaregiver(
      BuildContext context, DocumentSnapshot caregiverSnapshot) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to hire a caregiver.')),
      );
      return;
    }

    // Check if a hire request already exists
    QuerySnapshot existingRequest = await FirebaseFirestore.instance
        .collection('hireRequests')
        .where('senderId', isEqualTo: currentUser.uid)
        .where('caregiverId', isEqualTo: caregiverSnapshot.id)
        .get();

    if (existingRequest.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You have already sent a hire request to this caregiver.')),
      );
      return;
    }

    DocumentSnapshot currentUserSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    String senderName =
        '${currentUserSnapshot['firstName']} ${currentUserSnapshot['lastName']}';
    String avatarUrl = currentUserSnapshot['profileImageUrl'];

    await FirebaseFirestore.instance.collection('hireRequests').add({
      'senderId': currentUser.uid,
      'senderName': senderName,
      'avatarUrl': avatarUrl,
      'caregiverId': caregiverSnapshot.id,
      'caregiverName':
          '${caregiverSnapshot['firstName']} ${caregiverSnapshot['lastName']}',
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hire request sent successfully.')),
    );

    // Close the modal
    Navigator.of(context).pop();
  }

  Future<bool> _isAlreadyHired(DocumentSnapshot caregiverSnapshot) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return false;
    }

    // Check if a hire request with "Accepted" status already exists
    QuerySnapshot acceptedRequest = await FirebaseFirestore.instance
        .collection('hireRequests')
        .where('senderId', isEqualTo: currentUser.uid)
        .where('caregiverId', isEqualTo: caregiverSnapshot.id)
        .where('status', isEqualTo: 'Accepted')
        .get();

    return acceptedRequest.docs.isNotEmpty;
  }

  void _showDetails(
      BuildContext context, DocumentSnapshot caregiverSnapshot) async {
    String lastName = caregiverSnapshot['lastName'];
    String firstName = caregiverSnapshot['firstName'];
    String profileImageUrl = caregiverSnapshot['profileImageUrl'];

    bool isAlreadyHired = await _isAlreadyHired(caregiverSnapshot);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
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
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(50),
                        image: profileImageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(profileImageUrl),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage(
                                    'assets/default_profile_image.jpg'),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: profileImageUrl.isEmpty
                          ? const Center(
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$firstName $lastName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      'Caregiver',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (isAlreadyHired)
                          ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Hired',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () =>
                                _hireCaregiver(context, caregiverSnapshot),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Hire',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfilePage(
                                  userId: caregiverSnapshot.id,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
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
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('userType', isEqualTo: 'Caregiver')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            List<DocumentSnapshot> caregivers = snapshot.data!.docs;

            if (_searchQuery.isNotEmpty) {
              caregivers = caregivers.where((doc) {
                String firstName = doc['firstName'].toString().toLowerCase();
                String lastName = doc['lastName'].toString().toLowerCase();
                return firstName.contains(_searchQuery) ||
                    lastName.contains(_searchQuery);
              }).toList();
            }

            return GridView.builder(
              itemCount: caregivers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot caregiverSnapshot = caregivers[index];
                String lastName = caregiverSnapshot['lastName'];
                String firstName = caregiverSnapshot['firstName'];
                String expertise = caregiverSnapshot['expertise'];
                String profileImageUrl = caregiverSnapshot['profileImageUrl'];

                return GestureDetector(
                  onTap: () => _showDetails(context, caregiverSnapshot),
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            image: profileImageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(profileImageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: AssetImage(
                                        'assets/images/default.png'),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: profileImageUrl.isEmpty
                              ? const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return const Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 25,
                            );
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$firstName $lastName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                expertise,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
