import 'package:flutter/material.dart';
// import 'package:taklimsmart/screen/jadwal_warga_screen.dart';
import 'package:taklimsmart/screen/jadwal_admin_screen.dart';
import 'package:taklimsmart/screen/dokumentasi_admin_screen.dart';

class IconMenu extends StatelessWidget {
  const IconMenu({super.key});

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DokumentasiAdminScreen()),
              );
            },
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
