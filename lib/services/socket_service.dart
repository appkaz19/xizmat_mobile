import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  bool _isConnected = false;
  final Set<String> _pendingChats = {};

  // Singleton pattern
  static SocketService get instance {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  SocketService._internal();

  bool get isConnected => _isConnected;

  // Слушатели для разных событий
  final List<void Function(Map<String, dynamic>)> _newMessageListeners = [];
  Function()? onConnect;
  Function()? onDisconnect;

  /// Добавить слушатель новых сообщений
  void addNewMessageListener(void Function(Map<String, dynamic>) listener) {
    if (!_newMessageListeners.contains(listener)) {
      _newMessageListeners.add(listener);
    }
  }

  /// Удалить слушатель новых сообщений
  void removeNewMessageListener(void Function(Map<String, dynamic>) listener) {
    _newMessageListeners.remove(listener);
  }

  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      print('Socket уже подключен');
      return;
    }

    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('Нет токена авторизации для подключения к сокету');
        return;
      }

      print('Подключение к WebSocket по HTTP на порту 6969...');

      _socket = IO.io(
        'http://192.168.161.79:6969',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Content-Type': 'application/json'})
            .setAuth({'token': token})
            .enableAutoConnect()
            .setTimeout(10000)
            .build(),
      );

      _socket!.onConnect((_) {
        print('✅ WebSocket подключен по HTTP на порту 6969');
        _isConnected = true;
        for (final chatId in _pendingChats) {
          _socket!.emit('joinChat', chatId);
          print('🔗 Авто join к чату после подключения: $chatId');
        }
        _pendingChats.clear();
        onConnect?.call();
      });

      _socket!.onDisconnect((reason) {
        print('❌ WebSocket отключен. Причина: $reason');
        _isConnected = false;
        onDisconnect?.call();
      });

      _socket!.onConnectError((error) {
        print('🔥 Ошибка подключения WebSocket: $error');
        _isConnected = false;
      });

      _socket!.onError((error) {
        print('🔥 WebSocket ошибка: $error');
      });

      // Слушаем новые сообщения
      _socket!.on('newMessage', (data) {
        print('📨 SocketService: RAW данные из newMessage: $data');
        print('📨 SocketService: Тип данных: ${data.runtimeType}');
        print('📨 SocketService: Количество слушателей: ${_newMessageListeners.length}');

        Map<String, dynamic>? parsed;
        if (data is Map<String, dynamic>) {
          parsed = data;
        } else if (data is Map) {
          parsed = Map<String, dynamic>.from(data);
        }

        if (parsed != null) {
          print('📨 SocketService: Обработка сообщения: $parsed');
          print('📨 SocketService: Уведомляем ${_newMessageListeners.length} слушателей');

          for (final listener in List.from(_newMessageListeners)) {
            try {
              listener(parsed);
              print('📨 SocketService: Слушатель уведомлен успешно');
            } catch (e) {
              print('📨 SocketService: Неожиданный формат данных: $data');
            }
          }
        } else {
          print('📨 Неожиданный формат данных: $data');
        }
      });

      _socket!.connect();
    } catch (e) {
      print('Ошибка при подключении к WebSocket: $e');
    }
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void joinChat(String chatId) {
    if (_socket != null && _isConnected) {
      print('🔗 Присоединяемся к чату: $chatId');
      _socket!.emit('joinChat', chatId);
      print('🔗 Событие joinChat отправлено для чата: $chatId');
    } else {
      print('❌ Невозможно присоединиться к чату - нет подключения');
      _pendingChats.add(chatId);
      print('🔗 Чат $chatId добавлен в очередь на подключение');
    }
  }

  void leaveChat(String chatId) {
    if (_socket != null && _isConnected) {
      print('👋 Покидаем чат: $chatId');
      _socket!.emit('leaveChat', chatId);
    }
    _pendingChats.remove(chatId);
  }

  void sendMessage(String chatId, String content) {
    if (_socket != null && _isConnected) {
      print('📤 Отправляем сообщение через WebSocket');
      print('📤 ChatId: $chatId, Content: $content');

      _socket!.emit('sendMessage', {
        'chatId': chatId,
        'content': content,
      });

      print('📤 Сообщение отправлено через WebSocket');
    } else {
      print('❌ Не могу отправить сообщение - нет WebSocket соединения');
    }
  }

  void disconnect() {
    if (_socket != null) {
      print('🔌 Отключаем WebSocket');
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
    }
  }

  void dispose() {
    disconnect();
    _newMessageListeners.clear();
    onConnect = null;
    onDisconnect = null;
  }
}