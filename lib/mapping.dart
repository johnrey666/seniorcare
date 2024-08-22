import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userprofile.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<Marker> _markers = [];
  LatLng _userLocation =
      LatLng(13.1339, 123.7427); // Default to Albay, Philippines
  bool _isLoading = true;
  String? _selectedMarkerId;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _loadPostMarkers();
  }

  Future<void> _loadUserLocation() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = userDoc.data();
        if (data != null &&
            data.containsKey('latitude') &&
            data.containsKey('longitude')) {
          setState(() {
            _userLocation = LatLng(data['latitude'], data['longitude']);
          });
        }
      }
    } catch (e) {
      print('Error loading user location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPostMarkers() async {
    try {
      final posts = await FirebaseFirestore.instance.collection('posts').get();
      if (posts.docs.isEmpty) {
        print('No posts found in Firestore.');
        return;
      }

      setState(() {
        _markers.addAll(posts.docs
            .map((doc) {
              final data = doc.data();
              if (data.containsKey('latitude') &&
                  data.containsKey('longitude')) {
                final LatLng position =
                    LatLng(data['latitude'], data['longitude']);
                final String title = data['title'] ?? 'Untitled Post';
                final String postId = doc.id;
                final String profileImageUrl = data['profileImageUrl'] ?? '';

                return Marker(
                  point: position,
                  width: 150.0,
                  height: 150.0,
                  builder: (ctx) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMarkerId =
                            _selectedMarkerId == postId ? null : postId;
                      });
                    },
                    child: Stack(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 50.0,
                        ),
                        if (_selectedMarkerId == postId)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              width: 200.0,
                              constraints: BoxConstraints(
                                maxHeight: 100.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _navigateToPost(postId);
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: profileImageUrl
                                                  .isNotEmpty
                                              ? NetworkImage(profileImageUrl)
                                              : const AssetImage(
                                                  'assets/default_avatar.jpg',
                                                ) as ImageProvider,
                                          radius: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                print('Post is missing latitude or longitude: $data');
                return null;
              }
            })
            .whereType<Marker>()
            .toList());
      });
    } catch (e) {
      print('Error loading post markers: $e');
    }
  }

  void _navigateToPost(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Opportunities Near You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              setState(() {
                _loadUserLocation();
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: _userLocation,
                    zoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: _markers),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userLocation,
                          builder: (ctx) => Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                            size: 50.0,
                          ),
                          width: 50.0,
                          height: 50.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserLocation,
        child: const Icon(Icons.center_focus_strong),
        tooltip: 'Center Map',
      ),
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final String postId;

  const PostDetailPage({required this.postId});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('posts').doc(postId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Post not found'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          var userName =
              '${data['firstName'] ?? 'Anonymous'} ${data['lastName'] ?? ''}';
          var userPhotoUrl = data['profileImageUrl'] ?? '';
          var title = data['title'] ?? 'No Title';
          var description = data['description'] ?? 'No Description';
          var location = data['location'] ?? 'No Location';
          var imagePath = data['imagePath'];
          var clientId = data['userId'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User information
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(
                            userId: clientId,
                            isCurrentUser: currentUser?.uid == clientId,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: userPhotoUrl.isNotEmpty
                              ? NetworkImage(userPhotoUrl)
                              : const AssetImage('assets/default_avatar.jpg')
                                  as ImageProvider,
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                location,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Image
                  if (imagePath != null)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(1),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Post details
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // Apply button
                  ElevatedButton(
                    onPressed: () {
                      _showApplyConfirmationDialog(context, clientId, postId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showApplyConfirmationDialog(
      BuildContext context, String clientId, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Apply for Job'),
          content: const Text(
              'Are you sure you want to apply for this job? Your details will be sent to the client.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                Navigator.of(context).pop();
                _applyForJob(context, clientId, postId);
              },
            ),
          ],
        );
      },
    );
  }

  void _applyForJob(
      BuildContext context, String clientId, String postId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final postData = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();

        if (userData.exists && postData.exists) {
          final clientRef =
              FirebaseFirestore.instance.collection('users').doc(clientId);

          await clientRef.collection('applications').add({
            'applicantId': user.uid,
            'postId': postId,
            'appliedAt': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Application submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error submitting application')),
          );
        }
      }
    } catch (e) {
      print('Error applying for job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error applying for job')),
      );
    }
  }
}
