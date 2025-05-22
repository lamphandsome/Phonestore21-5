import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Tải token và user từ SharedPreferences khi khởi động app
  Future<void> loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (_token != null && userJson != null) {
        final userMap = Map<String, dynamic>.from(
          // Parse JSON string back to Map
            await Future.value(userJson).then((json) =>
            Map<String, dynamic>.from(
                userJson.split(',').fold<Map<String, String>>({}, (map, item) {
                  final parts = item.split(':');
                  if (parts.length == 2) {
                    map[parts[0].trim()] = parts[1].trim();
                  }
                  return map;
                })
            )
            )
        );
        _user = User.fromJson(userMap);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }

  // Lưu user và token vào SharedPreferences
  Future<void> _saveUserToStorage(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user', user.toJson().toString());
    } catch (e) {
      print('Error saving user to storage: $e');
    }
  }

  // Xóa user và token khỏi SharedPreferences
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    } catch (e) {
      print('Error clearing user from storage: $e');
    }
  }

  // Đăng nhập
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = LoginRequest(
        username: username,
        password: password,
      );

      final response = await UserApiService.login(request);

      _user = response.user;
      _token = response.token;

      await _saveUserToStorage(_user!, _token!);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Đăng ký
  Future<bool> register(String username, String email, String password, String fullname, {String? phone}) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        fullname: fullname,
        phone: phone,
      );

      await UserApiService.register(request);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Kích hoạt tài khoản
  Future<bool> activeAccount(String email, String key) async {
    _setLoading(true);
    _setError(null);

    try {
      await UserApiService.activeAccount(email, key);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Quên mật khẩu (gửi mật khẩu mới qua email)
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await UserApiService.forgotPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Yêu cầu đặt lại mật khẩu (gửi link qua email)
  Future<bool> requestResetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await UserApiService.requestResetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Đặt lại mật khẩu
  Future<bool> resetPassword(String email, String key, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await UserApiService.resetPassword(email, key, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Đổi mật khẩu
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_token == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      await UserApiService.changePassword(_token!, oldPassword, newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    _user = null;
    _token = null;
    await _clearUserFromStorage();
    notifyListeners();
  }
}