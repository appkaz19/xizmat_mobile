import 'dart:convert';

import '../core.dart';

class ReviewsApi {
  Future<List<Map<String, dynamic>>> getReviews(String serviceId) async {
    final res = await CoreApi.sendRequest(
      path: '/reviews',
      method: 'GET',
      query: {'serviceId': serviceId},
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString) as List;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>?> submitReview({
    required String serviceId,
    required int rating,
    required String comment,
  }) async {
    final res = await CoreApi.sendRequest(
      path: '/reviews',
      method: 'POST',
      body: {
        'serviceId': serviceId,
        'rating': rating,
        'comment': comment,
      },
      auth: true,
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      return jsonDecode(responseString);
    }

    // Если статус 400, выбрасываем исключение с соответствующим сообщением
    if (res.statusCode == 400) {
      final responseString = await res.transform(utf8.decoder).join();
      final errorData = jsonDecode(responseString);
      throw Exception('400: ${errorData['error'] ?? 'Bad Request'}');
    }

    return null;
  }
}