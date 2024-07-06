import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seniorcare/userprofile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? superKey, Key? key}) : super(key: superKey);
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
                  return const SizedBox.shrink();
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
                          userId: otherUserId,
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

class ConversationItem extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final String avatarUrl;
  final VoidCallback onTap;

  const ConversationItem({
    super.key,
    Key? superKey,
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

  const ConversationPage({
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
  String? _imageUrl;
  bool _showAvatar = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startCall() {
    _audioPlayer.play(AssetSource('sounds/ring.mp3')); // Play local ring sound

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.avatarUrl),
                  radius: 40,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Dialing...',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _audioPlayer.stop();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel Call'),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _audioPlayer.stop();
    });
  }

  void _showConversationActionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Conversation'),
                onTap: () {
                  _deleteConversation();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block Person'),
                onTap: () {
                  _blockPerson();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Report'),
                onTap: () {
                  _report();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteConversation() {
    FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .delete()
        .then((_) {
      print('Conversation deleted successfully');
    }).catchError((error) {
      print('Failed to delete conversation: $error');
    });
  }

  void _blockPerson() {
    print('User blocked');
  }

  void _report() {
    print('Conversation reported');
  }

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
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.phone),
            onPressed: () {
              _startCall();
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear),
            onPressed: () {
              _showConversationActionsModal(context);
            },
          ),
        ],
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
                        _showAvatar = false;
                      }

                      String? imageUrl = doc['imageUrl'];

                      return MessageItem(
                        text: doc['text'] ?? '',
                        avatarUrl: showAvatar ? senderAvatarUrl : '',
                        isCurrentUser: isCurrentUser,
                        imageUrl: imageUrl ?? '',
                        sender: '',
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
          if (_imageUrl != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _imageUrl = null;
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
                  icon: const FaIcon(FontAwesomeIcons.solidFileImage, size: 30),
                  onPressed: () {
                    _pickImage(context);
                  },
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.paperPlane),
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
        _imageUrl = imageUrl;
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
      'imageUrl': _imageUrl,
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
      _imageUrl = null;
      _showAvatar = true;
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
