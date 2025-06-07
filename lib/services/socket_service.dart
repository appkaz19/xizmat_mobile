import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  bool _isConnected = false;

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
        'http://uzxizmat.uz:6969', // ИСПРАВИЛИ: http вместо https
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Content-Type': 'application/json'}) // Как в документации
            .setAuth({'token': token}) // Точно как в документации
            .enableAutoConnect()
            .setTimeout(10000)
            .build(),
      );

      _socket!.onConnect((_) {
        print('✅ WebSocket подключен по HTTP на порту 6969');
        _isConnected = true;
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

      // Слушаем новые сообщения (точно как в документации)
      _socket!.on('newMessage', (data) {
        print('📨 RAW данные из newMessage: $data');
        print('📨 Тип данных: ${data.runtimeType}');
        Map<String, dynamic>? parsed;
        if (data is Map<String, dynamic>) {
          parsed = data;
        } else if (data is Map) {
          parsed = Map<String, dynamic>.from(data);
        }

        if (parsed != null) {
          print('📨 Обработка сообщения: $parsed');
          for (final listener in List.from(_newMessageListeners)) {
            listener(parsed);
          }
        } else {
          print('📨 Неожиданный формат данных: $data');
        }
      });

      // Добавим отладочные события
      _socket!.on('connect', (_) {
        print('🔗 Socket.IO connect событие');
      });

      _socket!.on('disconnect', (reason) {
        print('💔 Socket.IO disconnect: $reason');
      });

      // Слушаем все события для отладки
      _socket!.onAny((event, data) {
        print('🔥 Socket событие: $event, данные: $data');
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
      print('🔗 Socket подключен: $_isConnected');
      print('🔗 Socket состояние: ${_socket!.connected}');
      _socket!.emit('joinChat', chatId); // Точно как в документации

      // Добавим подтверждение что событие отправлено
      print('🔗 Событие joinChat отправлено для чата: $chatId');
    } else {
      print('❌ Невозможно присоединиться к чату - нет подключения');
      print('❌ Socket: $_socket, Connected: $_isConnected');
    }
  }

  void leaveChat(String chatId) {
    if (_socket != null && _isConnected) {
      print('👋 Покидаем чат: $chatId');
      // В документации нет leaveChat, но логично что такое событие должно быть
      _socket!.emit('leaveChat', chatId);
    }
  }

  void sendMessage(String chatId, String content) {
    // УБРАЛИ отправку через WebSocket!
    // Сообщения отправляются ТОЛЬКО через HTTP API
    // WebSocket используется только для получения сообщений
    print('📤 WebSocket sendMessage вызван, но отправка отключена (используется только HTTP API)');
    print('📤 ChatId: $chatId, Content: $content');
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