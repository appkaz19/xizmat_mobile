import 'package:flutter/material.dart';
import '../chat/conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> conversations = [
    {
      'id': '1',
      'name': 'Пример Примеров',
      'lastMessage': 'Привет! Когда можем встретиться?',
      'time': 'Вчера 19:24',
      'isOnline': true,
      'unreadCount': 2,
      'avatar': 'https://example.com/avatar1.jpg',
    },
    {
      'id': '2',
      'name': 'Пример Примеров',
      'lastMessage': 'В только что закончил 😊',
      'time': '10:48',
      'isOnline': false,
      'unreadCount': 0,
      'avatar': 'https://example.com/avatar2.jpg',
    },
    {
      'id': '3',
      'name': 'Пример Примеров',
      'lastMessage': 'Вы круты! 🔥🔥🔥',
      'time': '09:25',
      'isOnline': true,
      'unreadCount': 1,
      'avatar': 'https://example.com/avatar3.jpg',
    },
    {
      'id': '4',
      'name': 'Пример Примеров',
      'lastMessage': 'Уау, это реально красиво 😍',
      'time': 'Вчера',
      'isOnline': false,
      'unreadCount': 0,
      'avatar': 'https://example.com/avatar4.jpg',
    },
    {
      'id': '5',
      'name': 'Пример Примеров',
      'lastMessage': 'Отлично, договорились 😊',
      'time': 'В следующий раз 😊',
      'isOnline': false,
      'unreadCount': 0,
      'avatar': 'https://example.com/avatar5.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Чат'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Show search
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Чаты'),
              Tab(text: 'Звонки'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChatsList(),
            _buildCallsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              if (conversation['isOnline'])
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            conversation['name'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            conversation['lastMessage'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: conversation['unreadCount'] > 0
                  ? Colors.black
                  : Colors.grey[600],
              fontWeight: conversation['unreadCount'] > 0
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                conversation['time'],
                style: TextStyle(
                  color: conversation['unreadCount'] > 0
                      ? const Color(0xFF2E7D5F)
                      : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (conversation['unreadCount'] > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D5F),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    conversation['unreadCount'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationScreen(
                  userId: conversation['id'],
                  userName: conversation['name'],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCallsList() {
    return const Center(
      child: Text(
        'История звонков',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
