import 'dart:convert';
import '../core.dart';

class ChatApi {
  Future<Map<String, dynamic>?> startChat(String targetUserId) async {
    try {
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
    } catch (e) {
      print('Ошибка начала чата: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMyChats() async {
    try {
      final res = await CoreApi.sendRequest(
        path: '/chat',
        method: 'GET',
        auth: true,
      );

      if (res.statusCode == 200) {
        final responseString = await res.transform(utf8.decoder).join();
        final List<dynamic> chatsJson = jsonDecode(responseString);
        return chatsJson
            .map((chat) => Map<String, dynamic>.from(chat))
            .toList();
      } else {
        throw Exception('Failed to load chats: ${res.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения чатов: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    try {
      final res = await CoreApi.sendRequest(
        path: '/chat/$chatId/messages',
        method: 'GET',
        auth: true,
      );

      if (res.statusCode == 200) {
        final responseString = await res.transform(utf8.decoder).join();
        final List<dynamic> messagesJson = jsonDecode(responseString);
        return messagesJson
            .map((message) => Map<String, dynamic>.from(message))
            .toList();
      } else {
        throw Exception('Failed to load messages: ${res.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения сообщений: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> sendMessage(String chatId, String content) async {
    try {
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
      return null;
    } catch (e) {
      print('Ошибка отправки сообщения: $e');
      return null;
    }
  }

  Future<bool> markChatAsRead(String chatId) async {
    try {
      final res = await CoreApi.sendRequest(
        path: '/chat/$chatId/mark-read',
        method: 'POST',
        body: {},
      );

      return res.statusCode == 200;
    } catch (e) {
      print('Ошибка отметки чата как прочитанного: $e');
      return false;
    }
  }
}