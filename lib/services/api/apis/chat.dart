import 'dart:convert';

import '../core.dart';

class ChatApi {
  Future<Map<String, dynamic>?> startChat(String targetUserId) async {
    final res = await CoreApi.sendRequest(
      path: '/chat/start',
      method: 'POST',
      body: { 'targetUserId': targetUserId },
      auth: true
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }
}