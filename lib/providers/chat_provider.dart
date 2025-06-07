import 'package:flutter/material.dart';
import '../services/api/service.dart';
import '../services/socket_service.dart';

class ChatProvider with ChangeNotifier {
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  List<Map<String, dynamic>> get chats => _chats;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  // Получаем общее количество непрочитанных сообщений
  int get totalUnreadCount {
    return _chats.fold(0, (sum, chat) {
      final unreadCount = chat['unreadCount'] ?? 0;
      return sum + (unreadCount is int ? unreadCount : 0);
    });
  }

  // Проверяем есть ли непрочитанные сообщения
  bool get hasUnreadMessages => totalUnreadCount > 0;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await loadChats();
      await _initializeSocket();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
      print('Ошибка инициализации ChatProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeSocket() async {
    final socketService = SocketService.instance;

    // Устанавливаем callback для новых сообщений
    socketService.onNewMessage = (messageData) {
      _handleNewSocketMessage(messageData);
    };

    // При подключении к сокету присоединяемся ко всем чату
    socketService.onConnect = () {
      for (final chat in _chats) {
        final chatId = chat['id']?.toString();
        if (chatId != null) {
          socketService.joinChat(chatId);
        }
      }
    };

    // Подключаемся к сокету
    await socketService.connect();
  }

  void _handleNewSocketMessage(Map<String, dynamic> messageData) {
    print('ChatProvider: Обработка нового сообщения из сокета: $messageData');

    final chatId = messageData['chatId']?.toString();
    if (chatId == null) return;

    // Находим чат и обновляем его
    final chatIndex = _chats.indexWhere((chat) => chat['id'] == chatId);
    if (chatIndex != -1) {
      // Добавляем сообщение в начало списка
      final messages = _chats[chatIndex]['messages'] as List<dynamic>;
      messages.insert(0, messageData);

      // Увеличиваем счетчик непрочитанных
      final currentUnread = _chats[chatIndex]['unreadCount'] ?? 0;
      _chats[chatIndex]['unreadCount'] = currentUnread + 1;

      // Обновляем время последнего обновления
      _chats[chatIndex]['updatedAt'] = messageData['createdAt'];

      // Перемещаем чат в начало списка
      final updatedChat = _chats.removeAt(chatIndex);
      _chats.insert(0, updatedChat);

      notifyListeners();

      print('ChatProvider: Обновлен чат $chatId, новых непрочитанных: ${_chats[0]['unreadCount']}');
    }
  }

  Future<void> loadChats() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final chatsData = await ApiService.chat.getMyChats();

      // Преобразуем данные и извлекаем количество непрочитанных
      _chats = chatsData.map((chat) {
        return {
          'id': chat['id'],
          'unreadCount': chat['unreadCount'] ?? 0,
          'userA': chat['userA'],
          'userB': chat['userB'],
          'messages': chat['messages'] ?? [],
          'updatedAt': chat['updatedAt'],
        };
      }).toList();

      print('ChatProvider: Загружено чатов: ${_chats.length}');
      print('ChatProvider: Всего непрочитанных: $totalUnreadCount');
    } catch (e) {
      _error = e.toString();
      print('Ошибка загрузки чатов в ChatProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Обновляем количество непрочитанных для конкретного чата
  void updateChatUnreadCount(String chatId, int unreadCount) {
    final chatIndex = _chats.indexWhere((chat) => chat['id'] == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex]['unreadCount'] = unreadCount;
      notifyListeners();
    }
  }

  // Сбрасываем счетчик непрочитанных для чата (когда пользователь заходит в чат)
  void markChatAsRead(String chatId) {
    updateChatUnreadCount(chatId, 0);
  }

  // Добавляем новое сообщение через API (не через сокет)
  void addNewMessage(String chatId, Map<String, dynamic> message) {
    final chatIndex = _chats.indexWhere((chat) => chat['id'] == chatId);
    if (chatIndex != -1) {
      // Добавляем сообщение
      final messages = _chats[chatIndex]['messages'] as List<dynamic>;
      messages.insert(0, message);

      // Обновляем время
      _chats[chatIndex]['updatedAt'] = message['createdAt'];

      // Перемещаем чат в начало списка
      final updatedChat = _chats.removeAt(chatIndex);
      _chats.insert(0, updatedChat);

      notifyListeners();
    }
  }

  // Принудительное обновление (для pull-to-refresh)
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Отключаем сокет при удалении провайдера
    SocketService.instance.dispose();
    super.dispose();
  }
}