import 'dart:convert';

import '../core.dart';

class PurchasedApi {
  Future<List<Map<String, dynamic>>> getMyPurchasedContacts() async {
    final res = await CoreApi.sendRequest(
      path: '/purchased',
      method: 'GET',
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString) as List;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>?> buyServiceContact(String serviceId) async {
    final res = await CoreApi.sendRequest(
      path: '/services/$serviceId/contact',
      method: 'POST',
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    // Возвращаем null если не удалось купить контакт
    return null;
  }

  Future<Map<String, dynamic>?> buyJobContact(String jobId) async {
    final res = await CoreApi.sendRequest(
      path: '/jobs/$jobId/contact',
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