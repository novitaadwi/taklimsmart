import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taklimsmart/models/riwayat_model.dart';
import 'package:taklimsmart/models/response_model.dart';
import 'package:taklimsmart/services/token_service.dart';

class RiwayatService {
  final String baseUrl =  'https://api-taklimsmart-production.up.railway.app';

  Future<ApiResponse<List<RiwayatModel>>> getRiwayatPengajian() async {
    final url = Uri.parse('$baseUrl/riwayat/read');
    
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      final jsonData = jsonDecode(response.body);
      final List<dynamic> listData = jsonData['data'];

      final List<RiwayatModel> riwayatList =
          listData.map((e) => RiwayatModel.fromJson(e)).toList();

      return ApiResponse(
        success: true,
        message: jsonData['message'] ?? 'Berhasil',
        data: riwayatList,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }
}