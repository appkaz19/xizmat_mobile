import 'dart:convert';

import '../core.dart';

class FavoritesApi {
  // Services favorites
  Future<List<Map<String, dynamic>>> getFavoriteServices() async {
    final res = await CoreApi.sendRequest(
      path: '/favorites/services',
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

  Future<bool> addFavoriteService(String serviceId) async {
    final res = await CoreApi.sendRequest(
      path: '/favorites/services/$serviceId',
      method: 'POST',
      auth: true,
    );

    return res.statusCode == 200;
  }

  Future<bool> removeFavoriteService(String serviceId) async {
    final res = await CoreApi.sendRequest(
      path: '/favorites/services/$serviceId',
      method: 'DELETE',
      auth: true,
    );

    return res.statusCode == 200;
  }

  // Jobs favorites
  Future<List<Map<String, dynamic>>> getFavoriteJobs() async {
    final res = await CoreApi.sendRequest(
      path: '/favorites/jobs',
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

  Future<bool> addFavoriteJob(String jobId) async {
    final res = await CoreApi.sendRequest(
      path: '/favorites/jobs/$jobId',
      method: 'POST',
      auth: true,
    );

    return res.statusCode == 200;
  }

  Future<bool> removeFavoriteJob(String jobId) async {
    final res = await CoreApi.sendRequest(
      path: '/favorites/jobs/$jobId',
      method: 'DELETE',
      auth: true,
    );

    return res.statusCode == 200;
  }
}