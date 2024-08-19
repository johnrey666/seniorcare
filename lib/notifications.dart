import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'conversation.dart'; // Import the conversation page

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Check if the snapshot is still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if there's an error in the snapshot
          if (snapshot.hasError) {
            return const Center(
                child: Text('An error occurred while loading notifications.'));
          }

          // Check if there's no data or the data is empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications available.'));
          }

          // Map the documents to a list of NotificationItems
          final notifications = snapshot.data!.docs.map((doc) {
            final data =
                doc.data() as Map<String, dynamic>?; // Safely cast the data
            if (data == null) {
              return const Center(
                  child: Text('Error: Invalid notification data.'));
            }

            return NotificationItem(
              senderName: data['senderName'] ?? 'Unknown',
              avatarUrl: data['avatarUrl'] ?? '',
              message: data['message'] ?? 'No message',
              type: data['type'] ?? '',
              senderId: data['senderId'] ?? '',
              conversationId: data['conversationId'] ?? '',
              onMessagePressed: () {
                _navigateToConversation(
                  context,
                  data['conversationId'] ?? '',
                  data['senderId'] ?? '',
                  data['senderName'] ?? 'Unknown',
                  data['avatarUrl'] ?? '',
                );
              },
            );
          }).toList();

          // Return the ListView of notifications
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

  void _navigateToConversation(BuildContext context, String conversationId,
      String senderId, String senderName, String avatarUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          conversationId: conversationId,
          userName: senderName,
          avatarUrl: avatarUrl,
          userId: senderId,
        ),
      ),
    );
  }
}

// Notification item widget
class NotificationItem extends StatelessWidget {
  final String senderName;
  final String avatarUrl;
  final String message;
  final String type;
  final String senderId;
  final String conversationId;
  final VoidCallback onMessagePressed;

  const NotificationItem({
    super.key,
    required this.senderName,
    required this.avatarUrl,
    required this.message,
    required this.type,
    required this.senderId,
    required this.conversationId,
    required this.onMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl)
            : const AssetImage('assets/default_avatar.png') as ImageProvider,
      ),
      title: Text(senderName),
      subtitle: Text(message),
      trailing: type == 'HireNotification'
          ? ElevatedButton(
              onPressed: onMessagePressed,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Send Message'),
            )
          : null,
    );
  }
}
