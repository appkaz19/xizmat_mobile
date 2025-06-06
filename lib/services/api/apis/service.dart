import 'dart:convert';

import '../core.dart';

class ServiceApi {
  Future<Map<String, dynamic>> searchServices(Map<String, dynamic> query) async {
    final res = await CoreApi.sendRequest(
      path: '/services',
      method: 'GET',
      query: query,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString);

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception('Invalid API response format: not a Map');
      }
    }

    throw Exception('Failed to fetch services');
  }

  Future<Map<String, dynamic>?> getServiceById(String id) async {
    final res = await CoreApi.sendRequest(
      path: '/services/$id',
      method: 'GET',
      auth: true
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }

  Future<Map<String, dynamic>?> createService(Map<String, dynamic> body) async {
    final res = await CoreApi.sendRequest(
      path: '/services',
      method: 'POST',
      body: body,
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }

  Future<bool> promoteService(String serviceId, int days) async {
    final res = await CoreApi.sendRequest(
      path: '/services/$serviceId/promote',
      method: 'POST',
      body: {'days': days},
      auth: true,
    );

    return res.statusCode == 200;
  }

  Future<Map<String, dynamic>?> buyProviderContact(String serviceId) async {
    final res = await CoreApi.sendRequest(
      path: '/services/$serviceId/contact',
      method: 'POST',
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }

  Future<dynamic> getMyServices({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await CoreApi.sendRequest(
      path: '/services/my',
      method: 'GET',
      query: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    } else {
      throw Exception('Failed to load my services: ${res.statusCode}');
    }
  }
}
