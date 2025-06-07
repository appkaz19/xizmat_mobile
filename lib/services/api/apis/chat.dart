import 'dart:convert';
import '../core.dart';

class ChatApi {
  // Существующий метод
  Future<Map<String, dynamic>?> startChat(String targetUserId) async {
    final res = await CoreApi.sendRequest(
      path: '/chat/start',
      method: 'POST',
      body: {'targetUserId': targetUserId},
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }

  // НОВЫЙ МЕТОД: Получить список чатов
  Future<List<Map<String, dynamic>>> getMyChats() async {
    final res = await CoreApi.sendRequest(
      path: '/chat',
      method: 'GET',
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final List<dynamic> chatsJson = jsonDecode(responseString);
      return chatsJson.map((chat) => Map<String, dynamic>.from(chat)).toList();
    } else {
      throw Exception('Failed to load chats: ${res.statusCode}');
    }
  }

  // НОВЫЙ МЕТОД: Получить сообщения чата
  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    final res = await CoreApi.sendRequest(
      path: '/chat/$chatId/messages',
      method: 'GET',
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final List<dynamic> messagesJson = jsonDecode(responseString);
      return messagesJson.map((message) => Map<String, dynamic>.from(message)).toList();
    } else {
      throw Exception('Failed to load messages: ${res.statusCode}');
    }
  }

  // НОВЫЙ МЕТОД: Отправить сообщение
  Future<Map<String, dynamic>?> sendMessage(String chatId, String content) async {
    final res = await CoreApi.sendRequest(
      path: '/chat/$chatId/messages',
      method: 'POST',
      body: {'content': content},
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    } else {
      throw Exception('Failed to send message: ${res.statusCode}');
    }
  }
}