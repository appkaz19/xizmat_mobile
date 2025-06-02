import 'dart:convert';

import '../core.dart';

class PurchasedApi {
  Future<List<String>> getPurchasedContacts() async {
    final res = await CoreApi.sendRequest(
      path: '/purchased',
      method: 'GET',
      auth: true
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString) as List;
      return data.map<String>((e) => e['serviceId'].toString()).toList();
    }
    return [];
  }
}