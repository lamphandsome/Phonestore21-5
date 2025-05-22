import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserApiService {
  // Thay đổi base URL theo server của bạn
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Login
  static Future<TokenResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TokenResponse.fromJson(data);
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Register
  static Future<User> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/regis'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      print('Register error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Active Account
  static Future<String> activeAccount(String email, String key) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/active-account?email=$email&key=$key'),
        headers: headers,
      );

      print('Active account response status: ${response.statusCode}');
      print('Active account response body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Kích hoạt tài khoản thất bại');
      }
    } catch (e) {
      print('Active account error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Forgot Password
  static Future<String> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password?email=$email'),
        headers: headers,
      );

      print('Forgot password response status: ${response.statusCode}');
      print('Forgot password response body: ${response.body}');

      if (response.statusCode == 200) {
        return 'Mật khẩu mới đã được gửi về email của bạn';
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gửi yêu cầu thất bại');
      }
    } catch (e) {
      print('Forgot password error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Request Reset Password
  static Future<String> requestResetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/public/quen-mat-khau?email=$email'),
        headers: headers,
      );

      print('Request reset password response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return 'Link đặt lại mật khẩu đã được gửi về email của bạn';
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gửi yêu cầu thất bại');
      }
    } catch (e) {
      print('Request reset password error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Reset Password
  static Future<String> resetPassword(String email, String key, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/public/dat-lai-mat-khau?email=$email&key=$key&password=$password'),
        headers: headers,
      );

      print('Reset password response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return 'Đặt lại mật khẩu thành công';
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đặt lại mật khẩu thất bại');
      }
    } catch (e) {
      print('Reset password error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Change Password
  static Future<String> changePassword(String token, String oldPass, String newPass) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/change-password'),
        headers: getAuthHeaders(token),
        body: jsonEncode({
          'oldPass': oldPass,
          'newPass': newPass,
        }),
      );

      print('Change password response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return 'Đổi mật khẩu thành công';
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đổi mật khẩu thất bại');
      }
    } catch (e) {
      print('Change password error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }
}