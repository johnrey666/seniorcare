import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'conversation.dart';

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
      body: Stack(
        children: [
          StreamBuilder(
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

                    if (!userSnapshot.data!.exists) {
                      // Handle the case where the user document does not exist
                      return const SizedBox.shrink();
                    }

                    String otherUserName =
                        '${userSnapshot.data!['firstName']} ${userSnapshot.data!['lastName']}';
                    String avatarUrl =
                        userSnapshot.data!['profileImageUrl'] ?? '';
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
        ],
      ),
    );
  }
}
