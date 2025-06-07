import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadChats();

    setState(() {
      conversations = chatProvider.chats.map((chat) {
        // Определяем собеседника (не текущего пользователя)
        final userA = chat['userA'] as Map<String, dynamic>?;
        final userB = chat['userB'] as Map<String, dynamic>?;

        // Логика определения собеседника зависит от того, как бэкенд возвращает данные
        final otherUser = userA; // Упрощенно, нужно будет уточнить логику

        final messages = chat['messages'] as List<dynamic>? ?? [];
        final lastMessage = messages.isNotEmpty ? messages.first : null;

        return {
          'id': chat['id'],
          'chatId': chat['id'], // ID чата для API вызовов
          'name': otherUser?['fullName'] ?? otherUser?['phone'] ?? 'Неизвестный пользователь',
          'lastMessage': lastMessage?['content'] ?? 'Нет сообщений',
          'time': _formatTime(lastMessage?['createdAt']),
          'isOnline': false, // Статус онлайн не реализован в бэкенде
          'unreadCount': chat['unreadCount'] ?? 0,
          'avatar': otherUser?['avatarUrl'], // Если есть поле avatarUrl в User
          'otherUserId': otherUser?['id'], // ID собеседника
        };
      }).toList();
      isLoading = false;
      error = null;
    });
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';

    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} дн. назад';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ч. назад';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} мин. назад';
      } else {
        return 'Только что';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _refreshChats() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.refresh();
    await _loadChats();
  }

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
                // TODO: Implement search
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF2E7D5F),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2E7D5F),
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
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D5F)),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки чатов',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshChats,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D5F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'У вас пока нет чатов',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Начните общаться с другими пользователями',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshChats,
      color: const Color(0xFF2E7D5F),
      child: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: conversation['avatar'] != null
                      ? NetworkImage(conversation['avatar'])
                      : null,
                  child: conversation['avatar'] == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
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
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    chatId: conversation['chatId'],
                    otherUserId: conversation['otherUserId'],
                    userName: conversation['name'],
                    avatarUrl: conversation['avatar'],
                  ),
                ),
              );

              // Обновляем список чатов если вернулись из разговора
              if (result == true) {
                _refreshChats();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCallsList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'История звонков',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Функция будет доступна в следующем обновлении',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}