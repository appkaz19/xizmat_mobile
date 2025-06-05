import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core.dart';

class OtpVerificationResult {
  final bool success;
  final String? message;
  final String? otpToken;

  OtpVerificationResult({
    required this.success,
    this.message,
    this.otpToken
  });

  factory OtpVerificationResult.fromJson(int statusCode, String body) {
    try {
      final json = jsonDecode(body);
      if (statusCode == 200) {
        return OtpVerificationResult(
          success: true,
          message: json['message'],
          otpToken: json['otpToken'],
        );
      } else {
        return OtpVerificationResult(
          success: false,
          message: json['error'] ?? 'Ошибка верификации',
        );
      }
    } catch (e) {
      return OtpVerificationResult(
          success: false,
          message: 'Ошибка разбора ответа'
      );
    }
  }
}

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
  // Временное хранение OTP токена для сброса пароля  
  static String? _resetPasswordToken;

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

  Future<OtpVerificationResult> verifyResetOtp(String phone, String otp) async {
    final res = await CoreApi.sendRequest(
      path: '/auth/verify-reset-otp',
      method: 'POST',
      body: {'phone': phone, 'otp': otp},
    );

    final body = await res.transform(utf8.decoder).join();
    final result = OtpVerificationResult.fromJson(res.statusCode, body);

    if (result.success && result.otpToken != null) {
      _resetPasswordToken = result.otpToken;
    }

    return result;
  }

  Future<bool> resetPassword({
    required String newPassword,
  }) async {
    if (_resetPasswordToken == null) {
      throw Exception('OTP token not found. Please verify OTP first.');
    }

    final res = await CoreApi.sendRequest(
      path: '/auth/reset-password',
      method: 'POST',
      body: {'newPassword': newPassword},
      headers: {'Authorization': 'Bearer $_resetPasswordToken'},
    );

    if (res.statusCode == 200) {
      final responseString = await res.transform(utf8.decoder).join();
      final data = jsonDecode(responseString);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      _resetPasswordToken = null;
      return true;
    }
    return false;
  }

  // Метод для очистки OTP токена (на случай отмены операции)
  static void clearResetPasswordToken() {
    _resetPasswordToken = null;
  }
}