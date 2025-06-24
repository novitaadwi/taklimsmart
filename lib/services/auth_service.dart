import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taklimsmart/models/response_model.dart';
import 'package:taklimsmart/models/auth_model.dart';
import 'package:taklimsmart/models/user_model.dart';

class AuthService {
  final String baseUrl = 'https://api-taklimsmart-production.up.railway.app';

  Future<ApiResponse<User>> getProfile(String token) async {
    final url = Uri.parse('$baseUrl/akun');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final jsonData = jsonDecode(response.body);
      if (jsonData['status'] == true) {
        final user = User.fromJson(jsonData['data']);
        return ApiResponse(success: true, message: "Berhasil", data: user);
      } else {
        return ApiResponse(success: false, message: jsonData['message']);
      }
    } catch (e) {
      return ApiResponse(success: false, message: "Gagal memuat profil");
    }
  }
  
  Future<ApiResponse<void>> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final jsonData = jsonDecode(response.body);
      return ApiResponse<void>.fromJson(jsonData, null);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Terjadi kesalahan saat Login, mohon coba lagi',
        data: null,
      );
    }
  }
  
  Future<ApiResponse<Auth>> login(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final jsonData = jsonDecode(response.body);
      print("Raw response: ${response.body}");

      if (jsonData['success'] == true) {
        final authData = jsonData['data'];
        return ApiResponse<Auth>.fromJson(jsonData, (_) => Auth.fromJson(authData));
      } else {
        return ApiResponse<Auth>(
          success: false,
          message: jsonData['message'] ?? 'Login gagal',
          data: null,
        );
      }

    } catch (e) {
      return ApiResponse<Auth>(
        success: false,
        message: 'Terjadi kesalahan: $e',
        data: null,
      );
    }
  }

  Future<ApiResponse<void>> logout(String token, int sessionId) async {
  final url = Uri.parse('$baseUrl/logout');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'session_id': sessionId}),
    );

    print("Logout with token: $token");
    print("Session ID: $sessionId");
    print("Logout response: ${response.body}");

    final jsonData = jsonDecode(response.body);
    return ApiResponse<void>.fromJson(jsonData, null);
  } catch (e) {
      return ApiResponse<void>(

        success: false,
        message: 'Terjadi kesalahan saat Logout, mohon coba lagi',
        data: null,
      );
    }
  }
}
