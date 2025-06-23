import 'package:flutter/material.dart';
import '../widget/header_welcome.dart';
import '../widget/routine_card.dart';
import '../widget/icon_menu.dart';
import '../widget/history_item.dart';
import '../services/penjadwalan_service.dart';
import '../models/penjadwalan_model.dart';
import '../models/lokasi_model.dart';
import '../models/response_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final penjadwalanService = PenjadwalanService();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderWelcome(),
            FutureBuilder<ApiResponse<(LokasiModel, PenjadwalanReadModel)>>(
              future: penjadwalanService.getPengajianTerdekat(),
              builder: (context, snapshot) {
                print('HAS ERROR: ${snapshot.hasError}');
                print('ERROR: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError || snapshot.data?.data == null) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(snapshot.data?.message ?? 'Terjadi kesalahan yang tidak diketahui'),
                  );
                }

                final (lokasi, penjadwalan) = snapshot.data!.data!;
                return RoutineCard(lokasi: lokasi, penjadwalan: penjadwalan);
              },
            ),
            const IconMenu(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Riwayat Pengajian',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
