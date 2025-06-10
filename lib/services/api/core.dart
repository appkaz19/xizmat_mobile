import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class CoreApi {
  static const _baseUrl = '192.168.161.25:6969';
  static const _basePath = '/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<HttpClientResponse> sendRequest({
    required String path,
    required String method,
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? query,
    bool auth = false,
  }) async {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;

    final uri = Uri.http(_baseUrl, '$_basePath$path', query);
    print('➡ ${method.toUpperCase()} ${uri.toString()}');
    final request = await client.openUrl(method, uri);

    headers?.forEach(request.headers.set);
    request.headers.contentType = ContentType.json;

    if (auth) {
      final token = await _getToken();
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
    }

    if (body != null) {
      request.add(utf8.encode(jsonEncode(body)));
    }

    return await request.close();
  }
}
