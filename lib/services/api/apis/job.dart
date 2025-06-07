import 'dart:convert';

import '../core.dart';

class JobApi {
  Future<Map<String, dynamic>?> createJob(Map<String, dynamic> body) async {
    final res = await CoreApi.sendRequest(
      path: '/jobs',
      method: 'POST',
      body: body,
      auth: true
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }

  Future<bool> promoteJob(String jobId, int days) async {
    final res = await CoreApi.sendRequest(
      path: '/jobs/$jobId/promote',
      method: 'POST',
      body: {'days': days},
      auth: true
    );

    return res.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> searchJobs(Map<String, dynamic> queryParams) async {
    final res = await CoreApi.sendRequest(
      path: '/jobs',
      method: 'GET',
      query: queryParams,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString) as List;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getJobById(String id) async {
    final res = await CoreApi.sendRequest(
      path: '/jobs/$id',
      method: 'GET',
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }

  Future<Map<String, dynamic>?> buyEmployerContact(String jobId) async {
    final res = await CoreApi.sendRequest(
      path: '/jobs/$jobId/contact',
      method: 'POST',
      auth: true
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    return null;
  }

  Future<dynamic> getMyJobs({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await CoreApi.sendRequest(
      path: '/jobs/my',
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
      throw Exception('Failed to load my jobs: ${res.statusCode}');
    }
  }
}