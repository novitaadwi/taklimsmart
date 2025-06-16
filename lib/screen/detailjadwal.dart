import 'package:flutter/material.dart';


class DetailJadwalPage extends StatelessWidget {
  final Map<String, String> jadwal;

  const DetailJadwalPage({super.key, required this.jadwal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detail Jadwal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF4A5F2F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penceramah: ${jadwal['penceramah'] ?? 'N/A'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Tanggal: ${jadwal['tanggal'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Waktu: ${jadwal['waktu'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tempat: ${jadwal['tempat'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16),
            ),
            
          ],
        ),
      ),
    );
  }
}