import 'dart:convert';

import '../core.dart';

class SubcategoryApi {
  Future<List<Map<String, String>>> getSubcategoriesByCategory(String categoryId) async {
    final res = await CoreApi.sendRequest(
        path: '/subcategories/by-category/$categoryId',
        method: 'GET'
    );
    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString) as List;
      return data.map<Map<String, String>>(
              (e) => {
            'id': e['id'].toString(),
            'name': (e['SubcategoryTranslation']?.first?['name'] ?? '').toString(),
          }
      ).toList();
    }
    return [];
  }
}