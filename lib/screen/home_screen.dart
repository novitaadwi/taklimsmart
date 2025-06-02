import 'package:flutter/material.dart';
import '../widget/header_welcome.dart';
import '../widget/routine_card.dart';
import '../widget/icon_menu.dart';
import '../widget/history_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
        selectedItemColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderWelcome(),
            const RoutineCard(),
            const IconMenu(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Riwayat Pengajian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Lebih Lengkap>', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const HistoryItem(
              date: '22',
              month: 'Mei',
              name: 'Dika',
              location: 'Jalan Nangka, Gang II',
              time: '22 Mei 2025 19.00 WIB',
              status: 'Terlaksana',
              statusColor: Colors.green,
            ),
            const HistoryItem(
              date: '17',
              month: 'Mei',
              name: 'HJ. Saiful',
              location: 'Jalan Nangka, Gang II',
              time: '17 Mei 2025 14.00 WIB',
              status: 'Batal',
              statusColor: Colors.red,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
