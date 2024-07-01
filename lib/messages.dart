// lib/messages.dart
import 'package:flutter/material.dart';

// Message model
class Message {
  final String sender;
  final String text;
  final String avatarUrl;
  final String time;

  Message({
    required this.sender,
    required this.text,
    required this.avatarUrl,
    required this.time,
  });
}

// Messages Page
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final List<Message> messages = [
      Message(
        sender: 'John Rey Dado',
        text: 'Hello, how are you?',
        avatarUrl:
            'https://scontent.fmnl8-2.fna.fbcdn.net/v/t1.6435-9/69831401_2217217731909906_2278803583040225280_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=53a332&_nc_eui2=AeFH7jUadCg5LzyR3nnKMSsPS1Lb2HEIcvFLUtvYcQhy8bB5NJIV0zqqRs7nrQk0DEKXLxgBuwE1xDjT_6UfwaGa&_nc_ohc=b6TKzUORKJQQ7kNvgGDoV8w&_nc_ht=scontent.fmnl8-2.fna&oh=00_AYBBiQshIxsVH5mCzrYeP9NrwU9VsuTBjUFg_2f5uEo1Lw&oe=66A92322', // Placeholder image URL
        time: '2m ago',
      ),
      Message(
        sender: 'Anthony Renzo Zuñiga',
        text: 'Mano, miss ko na si mailah',
        avatarUrl:
            'https://scontent.fmnl8-1.fna.fbcdn.net/v/t39.30808-1/368026047_1788561318228013_224250882585157351_n.jpg?stp=dst-jpg_s200x200&_nc_cat=100&ccb=1-7&_nc_sid=0ecb9b&_nc_eui2=AeG1bNLQ_vgERvrkD4aWVvB8aq1ONyjtactqrU43KO1pyyw9xOHdg1qYmIUtvJ8VRjVO5m4A9lVJt2f0qz4RptZk&_nc_ohc=toVV0aPBWbkQ7kNvgEysEoP&_nc_ht=scontent.fmnl8-1.fna&oh=00_AYACa-up-qsDkZEJpfxnIDQHrwUlcCihpDTVnXa1-hcuJw&oe=66875C0B',
        time: '1h ago',
      ),
      Message(
        sender: 'Jay-ar Baloloy',
        text: 'ayawkol',
        avatarUrl:
            'https://scontent.fmnl8-3.fna.fbcdn.net/v/t39.30808-1/339443135_1264591487776723_1686334611574014372_n.jpg?stp=c0.0.200.200a_dst-jpg_p200x200&_nc_cat=101&ccb=1-7&_nc_sid=0ecb9b&_nc_eui2=AeF16R7J4CQhbnsE_d0yJe9CNpZK-nCbh-o2lkr6cJuH6pZwd5_Xeu7rC5ookz6Tw8oYWo1__plts-zcXiji7l_j&_nc_ohc=iIRsCbDDOcoQ7kNvgHuko_W&_nc_ht=scontent.fmnl8-3.fna&oh=00_AYBE77uR4TZtAgDskHB5yQFqkYXTN27NWiIpn9euPo0n5Q&oe=66878230',
        time: '1h ago',
      ),
      Message(
        sender: 'Angelo Bautista',
        text: 'Tite ni mano',
        avatarUrl:
            'https://scontent.fmnl8-2.fna.fbcdn.net/v/t39.30808-1/435612700_2488039958049317_8622276536411312900_n.jpg?stp=dst-jpg_s200x200&_nc_cat=103&ccb=1-7&_nc_sid=0ecb9b&_nc_eui2=AeFlGJS3eaVeg41BscfRW8Jmb-z6_feOLHJv7Pr9944scruK2dD2Pq25JKAi4XI85zUv6MeeOhPjHwK8TGhDh8_f&_nc_ohc=dvwl8ckdUjYQ7kNvgFss7ym&_nc_ht=scontent.fmnl8-2.fna&oh=00_AYClwt0kqAwfPI8J4ujkbM-b3HFR8QMQ_seA_zQ96DoZyA&oe=66877D58',
        time: '1h ago',
      ),
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(message.avatarUrl),
            ),
            title: Text(message.sender),
            subtitle: Text(message.text),
            trailing: Text(message.time),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationPage(
                    sender: message.sender,
                    avatarUrl: message.avatarUrl,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Conversation Page
class ConversationPage extends StatelessWidget {
  final String sender;
  final String avatarUrl;

  const ConversationPage({
    super.key,
    required this.sender,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Sample data for conversation
    final List<Message> conversation = [
      Message(
        sender: 'Alice',
        text: 'Hello, how are you?',
        avatarUrl: avatarUrl,
        time: '2m ago',
      ),
      Message(
        sender: 'You',
        text: 'I am good, how about you?',
        avatarUrl: avatarUrl,
        time: '1m ago',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(sender),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: conversation.length,
              itemBuilder: (context, index) {
                final message = conversation[index];
                return ListTile(
                  leading: message.sender == 'You'
                      ? null
                      : CircleAvatar(
                          backgroundImage: NetworkImage(message.avatarUrl),
                        ),
                  title: Align(
                    alignment: message.sender == 'You'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: message.sender == 'You'
                            ? Colors.blue[100]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(message.text),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Handle send message action
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
