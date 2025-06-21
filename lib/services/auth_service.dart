import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taklimsmart/models/response_model.dart';
import 'package:taklimsmart/models/auth_model.dart';

class AuthService {
  final String baseUrl = 'https://api-taklimsmart-production.up.railway.app';

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
        return ApiResponse<Auth>.fromJson(jsonData, Auth.fromJson);
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
}
