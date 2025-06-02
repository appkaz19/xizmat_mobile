import 'dart:convert';

import '../core.dart';

class UserApi {
  Future<Map<String, dynamic>?> getProfile() async {
    final res = await CoreApi.sendRequest(
        path: '/users/me',
        method: 'GET',
        auth: true
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }

  Future<bool> updateProfile(Map<String, dynamic> body) async {
    final res = await CoreApi.sendRequest(
      path: '/users/me',
      method: 'PATCH',
      body: body,
      auth: true
    );

    return res.statusCode == 200;
  }
}
