import 'dart:convert';

import '../core.dart';

class CategoryApi {
  Future<List<Map<String, String>>> getCategories() async {
    final res = await CoreApi.sendRequest(
        path: '/categories',
        method: 'GET'
    );
    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString) as List;
      return data.map<Map<String, String>>(
              (e) => {
            'id': e['id'].toString(),
            'name': (e['CategoryTranslation'] != null && e['CategoryTranslation'].isNotEmpty)
                ? e['CategoryTranslation'][0]['name'].toString()
                : '',
          }
      ).toList();
    }
    return [];
  }
}