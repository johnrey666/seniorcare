import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seniorcare/userprofile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:seniorcare/review.dart'; // Import the ReviewPage

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        radius: 30,
      ),
      title: Text(
        userName,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
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
  Timer? _ringTimer;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _callSubscription;
  bool _hasReviewed = false;
  bool _isTransactionCancelled = false;

  @override
  void initState() {
    super.initState();
    _checkIfReviewed();
    _checkIfTransactionCancelled();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _ringTimer?.cancel();
    _callSubscription?.cancel();
    super.dispose();
  }

  void _checkIfReviewed() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final review = await FirebaseFirestore.instance
        .collection('reviews')
        .where('reviewerId', isEqualTo: currentUser.uid)
        .where('reviewedUserId', isEqualTo: widget.userId)
        .where('conversationId', isEqualTo: widget.conversationId)
        .get();

    if (review.docs.isNotEmpty) {
      setState(() {
        _hasReviewed = true;
      });
    }
  }

  void _checkIfTransactionCancelled() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final transaction = await FirebaseFirestore.instance
        .collection('transactions')
        .doc(widget.conversationId)
        .get();

    if (transaction.exists && transaction.data() != null) {
      Map<String, dynamic> data = transaction.data()!;
      if (data.containsKey(widget.userId) &&
          data[widget.userId] == 'cancelled') {
        setState(() {
          _isTransactionCancelled = true;
        });
      }
    }
  }

  void _startCall() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    DocumentReference<Map<String, dynamic>> callDoc =
        FirebaseFirestore.instance.collection('calls').doc();

    await callDoc.set({
      'callerId': currentUser.uid,
      'callerName': currentUser.displayName ?? '',
      'calleeId': widget.userId,
      'calleeName': widget.userName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'ringing',
    });

    _audioPlayer.play(AssetSource('sounds/ring.mp3')); // Play local ring sound

    _showDialingDialog(callDoc);
  }

  void _showDialingDialog(DocumentReference<Map<String, dynamic>> callDoc) {
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
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    callDoc.update({'status': 'cancelled'});
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
      callDoc.update({'status': 'cancelled'});
      _audioPlayer.stop();
    });

    _callSubscription = callDoc.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var callStatus = snapshot.data()?['status'];
        if (callStatus == 'accepted') {
          _audioPlayer.stop();
          Navigator.pop(context); // Close the dialing dialog
          _startCallConversation(callDoc.id);
        } else if (callStatus == 'missed') {
          _sendMissedCallMessage();
        }
      }
    });

    _ringTimer = Timer(const Duration(seconds: 20), () {
      callDoc.update({'status': 'missed'});
      _audioPlayer.stop();
      Navigator.pop(context);
      _showNoAnswerDialog(callDoc);
    });
  }

  void _sendMissedCallMessage() async {
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .add({
      'text': 'You missed a call.',
      'sender': 'system',
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': null,
    });

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .update({
      'lastMessage': 'You missed a call.',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': 'system',
    });
  }

  void _showNoAnswerDialog(DocumentReference<Map<String, dynamic>> callDoc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Answer'),
          content: const Text('The call was not answered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startCall();
              },
              child: const Text('Call Again'),
            ),
          ],
        );
      },
    ).then((_) {
      callDoc.update({'status': 'missed'});
      _sendMissedCallMessage();
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
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController reportController = TextEditingController();

        return AlertDialog(
          title: const Text('Report Conversation'),
          content: TextField(
            controller: reportController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Describe the issue...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitReport(reportController.text);
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReport(String reportText) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || reportText.isEmpty) return;

    await FirebaseFirestore.instance.collection('reports').add({
      'conversationId': widget.conversationId,
      'reportedUserId': widget.userId,
      'reporterId': currentUser.uid,
      'reportText': reportText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted successfully')),
    );
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Transaction'),
          content:
              const Text('Are you sure you want to cancel this transaction?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelTransaction();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _cancelTransaction() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    DocumentReference<Map<String, dynamic>> transactionDoc = FirebaseFirestore
        .instance
        .collection('transactions')
        .doc(widget.conversationId);

    final transaction = await transactionDoc.get();
    if (transaction.exists && transaction.data() != null) {
      Map<String, dynamic> data = transaction.data()!;
      data[currentUser.uid] = 'cancelled';
      await transactionDoc.update(data);

      if (data.containsValue('cancelled')) {
        setState(() {
          _isTransactionCancelled = true;
        });
      }
    } else {
      await transactionDoc.set({
        currentUser.uid: 'cancelled',
      });
    }

    setState(() {
      _isTransactionCancelled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayName = widget.userName.length > 8
        ? '${widget.userName.substring(0, 8)}..'
        : widget.userName;

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
            Flexible(
              child: Text(
                displayName,
                style: const TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.video),
            onPressed: () {},
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.phone),
            onPressed: _startCall,
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
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CAREGIVING STATUS:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _hasReviewed
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewPage(
                                userId: widget.userId,
                                conversationId: widget.conversationId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Edit Review',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewPage(
                                    userId: widget.userId,
                                    conversationId: widget.conversationId,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'Successful',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _showCancelConfirmationDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
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
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }

                      String senderAvatarUrl =
                          userSnapshot.data!['profileImageUrl'] ?? '';
                      bool isCurrentUser = doc['sender'] ==
                          FirebaseAuth.instance.currentUser!.uid;
                      bool showAvatar = _showAvatar;

                      if (_showAvatar) {
                        _showAvatar = false;
                      }

                      return MessageItem(
                        text: doc['text'] ?? '',
                        avatarUrl: showAvatar ? senderAvatarUrl : '',
                        isCurrentUser: isCurrentUser,
                        imageUrl: doc['imageUrl'] ?? '',
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
          if (_imageUrl != null)
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
          if (!_isTransactionCancelled)
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
                    icon:
                        const FaIcon(FontAwesomeIcons.solidFileImage, size: 30),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.paperPlane),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          if (_isTransactionCancelled)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'You can\'t reply to this conversation anymore, this transaction is cancelled.',
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  void _pickImage() async {
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

  void _startCallConversation(String callDocId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallConversationPage(
          callDocId: callDocId,
          conversationId: widget.conversationId,
          userName: widget.userName,
          avatarUrl: widget.avatarUrl,
        ),
      ),
    );
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

class CallConversationPage extends StatefulWidget {
  final String callDocId;
  final String conversationId;
  final String userName;
  final String avatarUrl;

  const CallConversationPage({
    Key? key,
    required this.callDocId,
    required this.conversationId,
    required this.userName,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  _CallConversationPageState createState() => _CallConversationPageState();
}

class _CallConversationPageState extends State<CallConversationPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _endCall() {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callDocId)
        .update({'status': 'ended'});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call with ${widget.userName}'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatarUrl),
              radius: 50,
            ),
            const SizedBox(height: 20),
            const Text('In Call...', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _endCall,
              child: const Text('End Call'),
            ),
          ],
        ),
      ),
    );
  }
}
