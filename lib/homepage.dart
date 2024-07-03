import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class HomePage extends StatelessWidget {
  final void Function() toggleTheme;

  const HomePage({
    Key? key,
    required this.toggleTheme,
    required String userType,
  }) : super(key: key);

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

  void _showDetails(BuildContext context, DocumentSnapshot caregiverSnapshot) {
    // Fetch additional details from Firestore
    String lastName = caregiverSnapshot['lastName'];
    String firstName = caregiverSnapshot['firstName'];
    String expertise = caregiverSnapshot['expertise'];
    Timestamp dobTimestamp =
        caregiverSnapshot['dob']; // Date of birth as Timestamp
    String dob = calculateAge(dobTimestamp); // Calculate age from Timestamp
    String location = caregiverSnapshot['location'];
    String contactNumber = caregiverSnapshot['contactNumber'];
    String profileImageUrl = caregiverSnapshot['profileImageUrl'];

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
                      '$lastName, $firstName',
                      style: const TextStyle(
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Expertise: $expertise'),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Age: $dob'),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Location: $location'),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Contact Number: $contactNumber'),
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
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users') // Adjust collection name if needed
              .where('userType', isEqualTo: 'Caregiver')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return GridView.builder(
              itemCount: snapshot.data!.docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot caregiverSnapshot = snapshot.data!.docs[index];
                String lastName = caregiverSnapshot['lastName'];
                String firstName = caregiverSnapshot['firstName'];
                String profileImageUrl = caregiverSnapshot['profileImageUrl'];

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
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                            image: profileImageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(profileImageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image:
                                        AssetImage('assets/images/default.png'),
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
                        Text(
                          '$lastName, $firstName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () =>
                              _showDetails(context, caregiverSnapshot),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(150, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('View'),
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
