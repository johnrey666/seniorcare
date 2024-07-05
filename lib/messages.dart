import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seniorcare/userprofile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? key});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('users', arrayContains: currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final conversations = snapshot.data!.docs.map((doc) {
            String otherUserId = (doc['users'] as List<dynamic>)
                .firstWhere((id) => id != currentUser!.uid);

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox
                      .shrink(); // Return an empty widget while waiting for data
                }
                String otherUserName =
                    '${userSnapshot.data!['firstName']} ${userSnapshot.data!['lastName']}';
                String avatarUrl = userSnapshot.data!['profileImageUrl'] ?? '';
                String lastMessage = doc['lastMessage'];

                return ConversationItem(
                  userName: otherUserName,
                  lastMessage: lastMessage,
                  avatarUrl: avatarUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationPage(
                          conversationId: doc.id,
                          userName: otherUserName,
                          avatarUrl: avatarUrl,
                          userId: otherUserId, // Pass the userId here
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }).toList();

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              return conversations[index];
            },
          );
        },
      ),
    );
  }
}

// Conversation item widget
class ConversationItem extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final String avatarUrl;
  final VoidCallback onTap;

  const ConversationItem({
    Key? key,
    required this.userName,
    required this.lastMessage,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        radius: 30,
      ),
      title: Text(userName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}

class ConversationPage extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String avatarUrl;
  final String userId;

  ConversationPage({
    Key? key,
    required this.conversationId,
    required this.userName,
    required this.avatarUrl,
    required this.userId,
  }) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _imageUrl; // Track selected image URL
  bool _showAvatar = true; // Flag to show avatar on first message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserProfilePage(userId: widget.userId),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.avatarUrl),
                radius: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.userName, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(doc['sender'])
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      String senderAvatarUrl =
                          userSnapshot.data!['profileImageUrl'] ?? '';
                      bool isCurrentUser = doc['sender'] ==
                          FirebaseAuth.instance.currentUser!.uid;
                      bool showAvatar = false;

                      if (_showAvatar) {
                        showAvatar = true;
                        _showAvatar = false; // Reset flag after showing avatar
                      }

                      // Check if imageUrl field exists in the document
                      String? imageUrl = doc['imageUrl']; // Change here

                      return MessageItem(
                        text: doc['text'] ?? '',
                        avatarUrl: showAvatar ? senderAvatarUrl : '',
                        isCurrentUser: isCurrentUser,
                        imageUrl: imageUrl ?? '',
                        sender: '', // Provide a default value if null
                      );
                    },
                  );
                }).toList();

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return messages[index];
                  },
                );
              },
            ),
          ),
          // Image preview above TextField
          if (_imageUrl != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _imageUrl = null; // Clear image preview on tap
                  });
                },
                child: Image.network(
                  _imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.image, size: 30),
                  onPressed: () {
                    _pickImage(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send, size: 30),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String imageUrl = await _uploadImage(imageFile);
      setState(() {
        _imageUrl = imageUrl; // Update image preview
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child('images').child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _sendMessage() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    String message = _messageController.text.trim();

    if (message.isEmpty && _imageUrl == null) return;

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .add({
      'text': message,
      'sender': currentUser.uid,
      'avatarUrl': currentUser.photoURL ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': _imageUrl, // Save imageUrl along with the message
    });

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': currentUser.uid,
    });

    _messageController.clear();
    setState(() {
      _imageUrl = null; // Clear image preview after sending message
      _showAvatar = true; // Show avatar on next message sent
    });
  }
}

class MessageItem extends StatelessWidget {
  final String text;
  final String avatarUrl;
  final bool isCurrentUser;
  final String? imageUrl;

  const MessageItem({
    Key? key,
    required this.text,
    required this.avatarUrl,
    required this.isCurrentUser,
    this.imageUrl,
    required String sender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (imageUrl != null && imageUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Image.network(
              imageUrl!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: !isCurrentUser
                ? Border.all(color: Colors.grey[300]!)
                : Border.all(color: Colors.blue),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: isCurrentUser ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
