import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/dokumentasi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DokumentasiService {
  final Dio _dio = Dio();

  static const String _baseUrl = 'https://api-taklimsmart-production.up.railway.app';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> fetchDokumentasi() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/dokumentasi/read',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      debugPrint('get data dokumentasi: $response');
      return response.data;
    } catch (e) {
      debugPrint('Gagal mengambil dokumentasi: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> uploadFile(File file) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/dokumentasi/uploadfile');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();

      debugPrint('Status upload: ${response.statusCode}');

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        debugPrint('Response upload: $respStr');

        return json.decode(respStr);
      } else {
        debugPrint('Gagal upload file: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error saat upload file: $e');
      return null;
    }
  }

  Future<bool> tambahDokumentasi(Dokumentasi data) async {
    try {
      final token = await _getToken();
      final jsonBody = data.toJsonForCreate();
      final encoded = json.encode(jsonBody);
      debugPrint('Body JSON: $encoded');

      final res = await http.post(
        Uri.parse('$_baseUrl/dokumentasi/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: encoded,
      );

      debugPrint('Tambah Dokumentasi Status Code: ${res.statusCode}');
      debugPrint('Tambah Dokumentasi Response Body: ${res.body}');

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Gagal tambah dokumentasi: $e');
      return false;
    }
  }

  Future<bool> updateDokumentasi(Dokumentasi dokumentasi) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/dokumentasi/edit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "id_Dokumentasi": dokumentasi.idDokumentasi,
          "id_Penjadwalan": dokumentasi.idPenjadwalan,
          "uploaded_by": dokumentasi.uploadedBy,
          "caption_dokumentasi": dokumentasi.captionDokumentasi,
          "file_name": dokumentasi.fileName,
          "file_path": dokumentasi.filePath,
          "file_url": dokumentasi.fileUrl,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Gagal update dokumentasi: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception saat update dokumentasi: $e");
      return false;
    }
  }


  Future<bool> deleteDokumentasi(int id) async {
    try {
      final token = await _getToken();
      await _dio.delete(
        '$_baseUrl/dokumentasi/delete/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Gagal menghapus: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchPenjadwalan() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/Penjadwalan/read',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      debugPrint('get data penjadwalan : $response');
      return response.data;
    } catch (e) {
      debugPrint('Gagal mengambil penjadwalan: $e');
      return [];
    }
  }
}
