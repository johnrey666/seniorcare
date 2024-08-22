import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isImagePickerActive = false;
  LatLng _selectedLocation =
      LatLng(13.1435, 123.7438); // Default to Daraga, Albay, Philippines
  String _locationAddress = '';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _selectedLocation =
          LatLng(13.1435, 123.7438); // Daraga, Albay, Philippines
    });
    _locationAddress = await _getAddressFromLatLng(_selectedLocation);
  }

  Future<void> _pickImage() async {
    if (_isImagePickerActive) return;

    setState(() {
      _isImagePickerActive = true;
    });

    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() {
        _isImagePickerActive = false;
      });
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      _showErrorDialog("Title and Description are required.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog("No user logged in.");
        return;
      }

      // Fetch user profile data
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        _showErrorDialog("User profile not found.");
        return;
      }

      var userData = userDoc.data() as Map<String, dynamic>;

      String firstName = userData['firstName'] ?? 'Anonymous';
      String lastName = userData['lastName'] ?? '';
      String profileImageUrl = userData['profileImageUrl'] ?? '';

      String? imageUrl;
      if (_selectedImage != null) {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = await storageRef.putFile(_selectedImage!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      // Save post data to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationAddress,
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'imagePath': imageUrl ?? '',
        'userId': user.uid,
        'profileImageUrl': profileImageUrl,
        'firstName': firstName,
        'lastName': lastName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the form after submission
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
        _selectedLocation =
            LatLng(13.1435, 123.7438); // Reset to default location
        _locationAddress = '';
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully!')),
      );

      // Navigate to homepage
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _showErrorDialog("Failed to submit post: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      print("Error getting address: $e");
      return "${position.latitude}, ${position.longitude}";
    }
  }

  Future<void> _pickLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final LatLng initialLocation =
        LatLng(position.latitude, position.longitude);

    final pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPicker(
          initialLocation: initialLocation,
        ),
      ),
    );

    if (pickedLocation != null && pickedLocation is LatLng) {
      _locationAddress = await _getAddressFromLatLng(pickedLocation);
      setState(() {
        _selectedLocation = pickedLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _titleController,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 6,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: _locationAddress),
                readOnly: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Pick a location',
                  prefixIcon:
                      Icon(Icons.location_on_outlined, color: textColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.map, color: textColor),
                    onPressed: _pickLocation,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Add Image'),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationPicker extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPicker({required this.initialLocation, Key? key})
      : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late LatLng _pickedLocation;
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    _mapController = MapController();
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _pickedLocation = location;
    });
  }

  void _onSaveLocation() {
    Navigator.of(context).pop(_pickedLocation);
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(query);
      setState(() {
        _searchResults = locations;
      });
    } catch (e) {
      print("Error searching location: $e");
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _onSearchResultTap(Location location) {
    final LatLng newLocation = LatLng(location.latitude, location.longitude);
    setState(() {
      _pickedLocation = newLocation;
      _searchResults = [];
      _searchController.clear();
    });
    _mapController.move(newLocation, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _searchPlace,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onSaveLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _pickedLocation,
              zoom: 15.0,
              onTap: (tapPosition, point) {
                _onMapTapped(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _pickedLocation,
                    builder: (ctx) => const Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_searchResults.isNotEmpty)
            Positioned(
              top: 110,
              left: 15,
              right: 15,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final location = _searchResults[index];
                    return ListTile(
                      title:
                          Text('${location.latitude}, ${location.longitude}'),
                      onTap: () => _onSearchResultTap(location),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
