import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core.dart';

class RegisterResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? user;

  RegisterResult({required this.success, this.message, this.user});

  factory RegisterResult.fromJson(int statusCode, String body) {
    try {
      final json = jsonDecode(body);

      if (statusCode == 200) {
        return RegisterResult(
          success: true,
          message: json['message'],
          user: json['user'],
        );
      } else {
        return RegisterResult(
          success: false,
          message: json['error'] ?? 'Ошибка регистрации',
        );
      }
    } catch (e) {
      return RegisterResult(success: false, message: 'Ошибка разбора ответа');
    }
  }
}

class AuthApi {
  Future<RegisterResult> register(String phone, String password) async {
    final res = await CoreApi.sendRequest(
      path: '/auth/register',
      method: 'POST',
      body: {'phone': phone, 'password': password},
    );

    final body = await res.transform(utf8.decoder).join();

    return RegisterResult.fromJson(res.statusCode, body);
  }

  Future<bool> login(String phone, String password) async {
    final res = await CoreApi.sendRequest(
      path: '/auth/login',
      method: 'POST',
      body: {'phone': phone, 'password': password},
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      return true;
    }

    return false;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    final res = await CoreApi.sendRequest(
      path: '/auth/verify-otp',
      method: 'POST',
      body: {'phone': phone, 'otp': otp},
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      return true;
    }

    return false;
  }

  Future<bool> requestResetPassword(String phone) async {
    final res = await CoreApi.sendRequest(
      path: '/auth/request-reset-password',
      method: 'POST',
      body: {'phone': phone},
    );

    return res.statusCode == 200;
  }

  Future<bool> verifyResetOtp(String phone, String otp) async {
    final res = await CoreApi.sendRequest(
      path: '/auth/verify-reset-otp',
      method: 'POST',
      body: {'phone': phone, 'otp': otp},
    );

    return res.statusCode == 200;
  }

  Future<bool> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    final res = await CoreApi.sendRequest(
      path: '/auth/reset-password',
      method: 'POST',
      body: {
        'phone': phone,
        'otp': otp,
        'newPassword': newPassword,
      },
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      return true;
    }

    return false;
  }
}