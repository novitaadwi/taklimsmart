import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:taklimsmart/screen/jadwal_warga_screen.dart';
import 'package:taklimsmart/screen/jadwal_admin_screen.dart';
import 'package:taklimsmart/screen/dokumentasi_admin_screen.dart';

import '../screen/dokumentasi_warga_screen.dart';

class IconMenu extends StatelessWidget {
  const IconMenu({super.key});

  Future<void> _navigateToDokumentasi(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';

    if (role == 'admin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DokumentasiAdminScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DokumentasiWargaScreen()),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ==================== JADWAL ====================
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JadwalAdminScreen()),
              );
            },
            child: Column(
              children: const [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.calendar_today, color: Colors.black),
                ),
                SizedBox(height: 4),
                Text("Jadwal"),
              ],
            ),
          ),

          // ==================== DOKUMENTASI ====================
          GestureDetector(
            onTap: () => _navigateToDokumentasi(context),
            child: Column(
              children: const [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.image, color: Colors.black),
                ),
                SizedBox(height: 4),
                Text("Dokumentasi"),
              ],
            ),
          ),

          // ==================== LOKASI ====================
          GestureDetector(
            onTap: () {
              // tambahkan navigasi jika ada screen Lokasi
            },
            child: Column(
              children: const [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.location_on, color: Colors.black),
                ),
                SizedBox(height: 4),
                Text("Lokasi"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
