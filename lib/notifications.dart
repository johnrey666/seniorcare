import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('hireRequests')
            .where('caregiverId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final notifications = snapshot.data!.docs.map((doc) {
            return NotificationItem(
              senderName: doc['senderName'],
              avatarUrl: doc['avatarUrl'],
              action: doc['status'],
              onActionPressed: () {
                _showNotificationDialog(context, doc);
              },
            );
          }).toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return notifications[index];
            },
          );
        },
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hire Request from ${doc['senderName']}'),
          content: const Text('Do you accept this hire request?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Decline'),
              onPressed: () {
                _updateHireRequestStatus(doc.id, 'Declined');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Accept'),
              onPressed: () {
                _updateHireRequestStatus(doc.id, 'Accepted');
                _createConversation(doc);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateHireRequestStatus(String requestId, String status) async {
    if (status == 'Declined') {
      await FirebaseFirestore.instance
          .collection('hireRequests')
          .doc(requestId)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection('hireRequests')
          .doc(requestId)
          .update({
        'status': status,
      });
    }
  }

  Future<void> _createConversation(DocumentSnapshot doc) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    String senderName = doc['senderName'] ?? 'Unknown';
    String currentUserName = currentUser.displayName ?? 'Unknown';

    await FirebaseFirestore.instance.collection('conversations').add({
      'users': [currentUser.uid, doc['senderId']],
      'userNames': [currentUserName, senderName],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': '',
    });
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
        onPressed: action == 'Accepted' ? null : onActionPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(action == 'Accepted' ? 'Accepted' : 'View'),
      ),
    );
  }
}
