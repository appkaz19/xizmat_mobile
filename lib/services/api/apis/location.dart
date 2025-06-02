import 'dart:convert';

import '../core.dart';

class LocationApi {
  Future<List<Map<String, dynamic>>> getRegionsWithCities() async {
    final res = await CoreApi.sendRequest(
        path: '/location/regions',
        method: 'GET'
    );

    if (res.statusCode != 200) return [];
    final responseString = await res.transform(utf8.decoder).join();
    final data = jsonDecode(responseString) as List;

    final cities = <Map<String, String>>[];

    for (final region in data) {
      final regionName = (region['translations'] as List?)?.first?['name'] ?? 'Без названия';
      final regionCities = (region['cities'] as List?) ?? [];

      for (final city in regionCities) {
        final cityName = (city['translations'] as List?)?.first?['name'] ?? '';
        cities.add({
          'id': city['id'].toString(),
          'name': cityName,
          'region': regionName,
        });
      }
    }

    return cities;
  }
}