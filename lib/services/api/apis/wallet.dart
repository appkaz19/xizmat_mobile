import 'dart:convert';

import '../core.dart';
class WalletApi {
  Future<Map<String, dynamic>?> getWallet() async {
    final res = await CoreApi.sendRequest(
      path: '/wallet',
      method: 'GET',
      auth: true
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }
}
