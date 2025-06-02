import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get userName => _userName;

  Future<void> login(String phone, String password) async {
    // Implement login logic
    _isLoggedIn = true;
    _userId = '123';
    _userName = 'Пример Примеров';
    notifyListeners();
  }

  Future<void> socialLogin(String provider) async {
    // Implement social login
    _isLoggedIn = true;
    _userId = '123';
    _userName = 'Пример Примеров';
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userId = null;
    _userName = null;
    notifyListeners();
  }
}
