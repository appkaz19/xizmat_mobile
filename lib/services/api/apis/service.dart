import 'dart:convert';

import '../core.dart';

class ServiceApi {
  Future<List<Map<String, dynamic>>> searchServices(Map<String, dynamic> query) async {
    final res = await CoreApi.sendRequest(
        path: '/services',
        method: 'GET',
        query: query
    );
    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString) as List;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
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
}
