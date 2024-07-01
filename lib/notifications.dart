// notifications.dart
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// Notification model
class Notification {
  final String senderName;
  final String avatarUrl;
  final String action;

  Notification({
    required this.senderName,
    required this.avatarUrl,
    required this.action,
  });
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
        onPressed: onActionPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(action),
      ),
    );
  }
}

// Notifications page
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example notifications
    final notifications = [
      Notification(
          senderName: 'John Rey Dado',
          avatarUrl:
              'https://scontent.fmnl8-2.fna.fbcdn.net/v/t1.6435-9/69831401_2217217731909906_2278803583040225280_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=53a332&_nc_eui2=AeFH7jUadCg5LzyR3nnKMSsPS1Lb2HEIcvFLUtvYcQhy8bB5NJIV0zqqRs7nrQk0DEKXLxgBuwE1xDjT_6UfwaGa&_nc_ohc=b6TKzUORKJQQ7kNvgGDoV8w&_nc_ht=scontent.fmnl8-2.fna&oh=00_AYBBiQshIxsVH5mCzrYeP9NrwU9VsuTBjUFg_2f5uEo1Lw&oe=66A92322',
          action: 'View'),
      Notification(
          senderName: 'Anthony Renzo Zuniga',
          avatarUrl:
              'https://scontent.fmnl8-1.fna.fbcdn.net/v/t39.30808-1/368026047_1788561318228013_224250882585157351_n.jpg?stp=dst-jpg_s200x200&_nc_cat=100&ccb=1-7&_nc_sid=0ecb9b&_nc_eui2=AeG1bNLQ_vgERvrkD4aWVvB8aq1ONyjtactqrU43KO1pyyw9xOHdg1qYmIUtvJ8VRjVO5m4A9lVJt2f0qz4RptZk&_nc_ohc=toVV0aPBWbkQ7kNvgEysEoP&_nc_ht=scontent.fmnl8-1.fna&oh=00_AYACa-up-qsDkZEJpfxnIDQHrwUlcCihpDTVnXa1-hcuJw&oe=66875C0B',
          action: 'View'),
      // Add more notifications here
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItem(
            senderName: notification.senderName,
            avatarUrl: notification.avatarUrl,
            action: notification.action,
            onActionPressed: () {
              // Handle view action
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Application from ${notification.senderName}'),
                    content: const Text('Viewing application details...'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
