import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api/service.dart';
import '../../services/socket_service.dart';
import '../../providers/chat_provider.dart';

class ConversationScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String userName;
  final String? avatarUrl;

  const ConversationScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.userName,
    this.avatarUrl,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? currentUserId;
  void Function(Map<String, dynamic>)? _socketListener;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _getCurrentUserId();
    _markChatAsRead();
    _setupSocket();
  }

  @override
  void dispose() {
    _cleanupSocket();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _setupSocket() async {
    final socketService = SocketService.instance;

    // Регистрируем слушатель для сообщений этого чата
    _socketListener ??= (messageData) {
      if (messageData['chatId'] == widget.chatId) {
        _handleNewMessage(messageData);
      }
    };
    socketService.addNewMessageListener(_socketListener!);

    // Присоединяемся к чату
    socketService.joinChat(widget.chatId);
  }

  void _cleanupSocket() {
    final socketService = SocketService.instance;
    socketService.leaveChat(widget.chatId);
    if (_socketListener != null) {
      socketService.removeNewMessageListener(_socketListener!);
    }
  }

  void _handleNewMessage(Map<String, dynamic> messageData) {
    print('ConversationScreen: Получено новое сообщение через сокет: $messageData');

    // Проверяем, что сообщение не от текущего пользователя (чтобы не дублировать)
    if (messageData['senderId'] != currentUserId) {
      setState(() {
        messages.add({
          'id': messageData['id'],
          'text': messageData['content'] ?? '',
          'isMe': false,
          'time': _formatTime(messageData['createdAt']),
          'senderId': messageData['senderId'],
          'createdAt': messageData['createdAt'],
        });
      });

      // Автопрокрутка к новому сообщению
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _markChatAsRead() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.markChatAsRead(widget.chatId);
  }

  Future<void> _getCurrentUserId() async {
    try {
      // Получаем ID текущего пользователя из профиля
      final profile = await ApiService.user.getProfile();
      setState(() {
        currentUserId = profile?['id']?.toString();
      });
    } catch (e) {
      print('Ошибка получения ID пользователя: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        isLoading = true;
      });

      final messagesData = await ApiService.chat.getChatMessages(widget.chatId);

      // Преобразуем данные бэкенда в формат для UI
      final List<Map<String, dynamic>> formattedMessages = messagesData.map((message) {
        return {
          'id': message['id'],
          'text': message['content'] ?? '',
          'isMe': message['senderId'] == currentUserId,
          'time': _formatTime(message['createdAt']),
          'senderId': message['senderId'],
          'createdAt': message['createdAt'],
        };
      }).toList();

      setState(() {
        messages = formattedMessages;
        isLoading = false;
      });

      // Прокручиваем к последнему сообщению
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Ошибка загрузки сообщений: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';

    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || isSending) return;

    setState(() {
      isSending = true;
    });

    // Объявляем tempMessage вне блока try-catch
    final tempMessage = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'text': messageText,
      'isMe': true,
      'time': _formatTime(DateTime.now().toIso8601String()),
      'senderId': currentUserId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      // Добавляем сообщение локально для мгновенного отображения
      setState(() {
        messages.add(tempMessage);
      });

      _messageController.clear();

      // Прокручиваем к новому сообщению
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      // Отправляем через WebSocket для мгновенной доставки
      final socketService = SocketService.instance;
      if (socketService.isConnected) {
        socketService.sendMessage(widget.chatId, messageText);
      }

      // Дублируем через HTTP API для надежности
      final newMessage = await ApiService.chat.sendMessage(widget.chatId, messageText);

      if (newMessage != null) {
        // Заменяем временное сообщение на реальное
        setState(() {
          final tempIndex = messages.indexWhere((msg) => msg['id'] == tempMessage['id']);
          if (tempIndex != -1) {
            messages[tempIndex] = {
              'id': newMessage['id'],
              'text': messageText,
              'isMe': true,
              'time': _formatTime(newMessage['createdAt']),
              'senderId': newMessage['senderId'],
              'createdAt': newMessage['createdAt'],
            };
          }
        });

        // Обновляем ChatProvider
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addNewMessage(widget.chatId, newMessage);
      }
    } catch (e) {
      print('Ошибка отправки сообщения: $e');

      // Удаляем временное сообщение при ошибке
      setState(() {
        messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка отправки сообщения: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // Возвращаем true для обновления списка чатов
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.avatarUrl != null
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: widget.avatarUrl == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Был(а) недавно',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implement call functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Звонки будут доступны в следующем обновлении')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D5F)),
            )
                : messages.isEmpty
                ? const Center(
              child: Text(
                'Нет сообщений\nНачните общение!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessage(message);
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    // TODO: Implement file attachment
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Прикрепление файлов будет доступно в следующем обновлении')),
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    // TODO: Implement camera
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Камера будет доступна в следующем обновлении')),
                    );
                  },
                ),

                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Напишите сообщение...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {
                    // TODO: Implement voice recording
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Голосовые сообщения будут доступны в следующем обновлении')),
                    );
                  },
                ),

                Container(
                  decoration: BoxDecoration(
                    color: isSending ? Colors.grey : const Color(0xFF2E7D5F),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: isSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.avatarUrl != null
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: widget.avatarUrl == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF2E7D5F) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['time'],
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}