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

  Future<ApiResponse<void>> updateJadwal(int id, PenjadwalanModel jadwal) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Token otorisasi tidak tersedia.', data: null);
      }

      final url = Uri.parse('$baseUrl/Penjadwalan/edit/$id');
      final requestBody = jsonEncode(jadwal.toJson());
      print('Request Body (updateJadwal): $requestBody');

      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      print('Status Code (updateJadwal): ${response.statusCode}');
      print('Response Body (updateJadwal): ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) {
          return ApiResponse(success: true, message: jsonData['message'] ?? 'Jadwal berhasil diperbarui', data: null);
        } else {
          return ApiResponse(success: false, message: jsonData['message'] ?? 'Gagal memperbarui jadwal (API respons tidak sukses)', data: null);
        }
      } else if (response.statusCode == 404) {
        return ApiResponse(success: false, message: 'Jadwal tidak ditemukan', data: null);
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse(success: false, message: errorData['message'] ?? 'Gagal memperbarui jadwal (Status: ${response.statusCode})', data: null);
      }
    } catch (e, stackTrace) {
      print('Error memperbarui jadwal: $e');
      print('Stacktrace: $stackTrace');
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan saat memperbarui jadwal: $e', data: null);
    }
  }

  Future<ApiResponse<void>> deleteJadwal(int id) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Token otorisasi tidak tersedia.', data: null);
      }

      final url = Uri.parse('$baseUrl/Penjadwalan/delete/$id'); 

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Status Code (deleteJadwal): ${response.statusCode}');
      print('Response Body (deleteJadwal): ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true) { // Asumsi back-end menggunakan 'status'
          return ApiResponse(success: true, message: jsonData['message'] ?? 'Jadwal berhasil dihapus', data: null);
        } else {
          return ApiResponse(success: false, message: jsonData['message'] ?? 'Gagal menghapus jadwal (API respons tidak sukses)', data: null);
        }
      } else if (response.statusCode == 404) {
        return ApiResponse(success: false, message: 'Jadwal tidak ditemukan', data: null);
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse(success: false, message: errorData['message'] ?? 'Gagal menghapus jadwal (Status: ${response.statusCode})', data: null);
      }
    } catch (e, stackTrace) {
      print('Error menghapus jadwal: $e');
      print('Stacktrace: $stackTrace');
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan saat menghapus jadwal: $e', data: null);
    }
  }
}