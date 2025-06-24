import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taklimsmart/models/penjadwalan_model.dart';
import 'package:taklimsmart/models/response_model.dart';
import 'package:taklimsmart/models/lokasi_model.dart';
import 'package:taklimsmart/services/token_service.dart';

class PenjadwalanService {
  final String baseUrl =  'https://api-taklimsmart-production.up.railway.app';

  Future<ApiResponse<(LokasiModel, PenjadwalanReadModel)>> getPengajianTerdekat() async {
    final url = Uri.parse('$baseUrl/lokasi-terdekat');

    try {
      final token = await TokenService.getToken();
      print("Logout with token: $token");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print("Logout with token: $token");
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] == true && jsonData['data'] != null) {
        final lokasi = LokasiModel.fromJson(jsonData['data']['lokasi']);
        final penjadwalan = PenjadwalanReadModel.fromJson(jsonData['data']['penjadwalan']);

        return ApiResponse(
          success: true,
          message: jsonData['message'] ?? 'Berhasil',
          data: (lokasi, penjadwalan),
        );
      } else {
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Data tidak ditemukan',
          data: null,
        );
      }

    } catch (e, stackTrace) {
      print('Error ambil penjadwalan: $e');
      print('Stacktrace: $stackTrace');
      return ApiResponse(
        success: false,
        message: 'Gagal mengambil pengajian terdekat',
        data: null,
      );
    }
  }

  Future<ApiResponse<List<LokasiModel>>> getAllLokasi() async {
  final url = Uri.parse('$baseUrl/lokasi');

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
    final List<dynamic> listData = jsonDecode(response.body);

    final lokasiList = listData.map((e) => LokasiModel.fromJson(e)).toList();

    return ApiResponse(
    success: true,
    message: 'Berhasil',
    data: lokasiList,
  );
  } catch (e, stackTrace) {
    print('Error ambil lokasi: $e');
    print('Stacktrace: $stackTrace');
      return ApiResponse(
        success: false,
        message: 'Gagal mengambil lokasi',
        data: null,
      );
    }
  }

  Future<ApiResponse<List<PenjadwalanModel>>> getAllPenjadwalan() async {
  final url = Uri.parse('$baseUrl/Penjadwalan/read');

  try {
    final token = await TokenService.getToken();
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final jsonData = jsonDecode(response.body);
    final List<dynamic> listData = jsonData['data'];

    final List<PenjadwalanModel> jadwalList =
        listData.map((e) => PenjadwalanModel.fromJson(e)).toList();

    return ApiResponse(
      success: true,
      message: jsonData['message'] ?? 'Berhasil',
      data: jadwalList,
    );
  } catch (e, stackTrace) {
    print('Error ambil penjadwalan: $e');
    print('Stacktrace: $stackTrace');
      return ApiResponse(
        success: false,
        message: 'Gagal mengambil jadwal',
        data: null,
      );
    }
  }

  Future<ApiResponse<void>> createJadwal(PenjadwalanModel data) async {
    final url = Uri.parse('$baseUrl/Penjadwalan/create');

    try {
      final token = await TokenService.getToken();
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data.toJson()),
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print(jsonEncode(data.toJson()));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final jsonData = jsonDecode(response.body);
        return ApiResponse<void>.fromJson(jsonData, null);
      } else {
        return ApiResponse(
          success: false,
          message: 'Gagal menambahkan jadwal',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print('Error tambah penjadwalan: $e');
      print('Stacktrace: $stackTrace');
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan Menambahkan Jadwal, mohon coba lagi',
        data: null,
      );
    }
  }
}