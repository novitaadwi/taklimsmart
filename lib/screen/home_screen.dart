import 'package:flutter/material.dart';
import 'package:taklimsmart/widget/history_item.dart';
import '../widget/header_welcome.dart';
import '../widget/routine_card.dart';
import '../widget/icon_menu.dart';
import '../services/penjadwalan_service.dart';
import '../models/penjadwalan_model.dart';
import '../models/lokasi_model.dart';
import '../models/response_model.dart';
import '../widget/notif_dialog.dart';
import '../models/riwayat_model.dart';
import '../services/riwayat_services.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<int, PenjadwalanModel> penjadwalanMap = {};
  List<RiwayatModel> riwayatList = [];
  Map<int, LokasiModel> lokasiMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        tampilkanNotifikasiDialog(context);
      } catch (e) {
        print('Notifikasi error: $e');
      }
    });

    _loadRiwayat();
  }

  String statusToString(StatusPenjadwalan status) {
    switch (status) {
      case StatusPenjadwalan.diproses:
        return 'Diproses';
      case StatusPenjadwalan.disetujui:
        return 'Terlaksana';
      case StatusPenjadwalan.ditolak:
        return 'Batal';
    }
  }

  Color getStatusColor(StatusPenjadwalan status) {
    switch (status) {
      case StatusPenjadwalan.disetujui:
        return Colors.green;
      case StatusPenjadwalan.ditolak:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String formatedTanggal(String? tgl) {
    try {
      if (tgl == null) return 'Tanggal tidak tersedia';
      return DateFormat('dd MMM yyyy').format(DateTime.parse(tgl));
    } catch (e) {
      print('Format tanggal error: $e');
      return 'Tanggal invalid';
    }
  }

  Future<void> _loadRiwayat() async {
    final lokasiService = PenjadwalanService(); 
    final lokasiResult = await lokasiService.getAllLokasi();
    if (lokasiResult.success && lokasiResult.data != null) {
      lokasiMap = {
        for (var item in lokasiResult.data!) item.idLokasi: item,
      };
      print('Lokasi berhasil dimuat. Total: ${lokasiMap.length}');
      print('ID lokasi yang dimuat: ${lokasiMap.keys}');
    } else {
      print('Gagal ambil lokasi: ${lokasiResult.message}');
    }


    print('Loading riwayat...');
    final riwayatService = RiwayatService();
    final penjadwalanService = PenjadwalanService();

    try {
      // Ambil semua penjadwalan
      final penjadwalanResult = await penjadwalanService.getAllPenjadwalan();
      if (penjadwalanResult.success && penjadwalanResult.data != null) {
        final list = penjadwalanResult.data!;
        penjadwalanMap = {
        for (var item in list) item.idPenjadwalan: item,};
      }

      // Ambil riwayat
      final result = await riwayatService.getRiwayatPengajian();
      if (result.success && result.data != null) {
        print('Riwayat ditemukan: ${penjadwalanResult.data!.length}');
        setState(() {
          riwayatList = result.data!;
        });
      } else {
        print('Gagal ambil riwayat: ${result.message}');;
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  
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
                ],
              ),
            ),
            ListView.builder(
              itemCount: riwayatList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final riwayat = riwayatList[index];
                final penjadwalan = penjadwalanMap[riwayat.idPenjadwalan];

                if (penjadwalan == null) return const SizedBox();

                final tanggalWaktuStr = '${penjadwalan.tanggal} ${penjadwalan.waktu}';
                  DateTime? tanggal;
                  try {
                    tanggal = DateFormat('yyyy-MM-dd HH:mm').parse(tanggalWaktuStr);
                  } catch (e) {
                    print('Gagal parse tanggal & waktu: $e');
                    tanggal = null;
                  }
                final day = tanggal != null ? DateFormat('dd').format(tanggal) : '--';
                final month = tanggal != null ? DateFormat('MMM', 'id_ID').format(tanggal) : '--';
                final name = penjadwalan.namaPenjadwalan;
                final lokasi = lokasiMap[penjadwalan.idLokasi];
                  if (lokasi == null) {
                    print('Lokasi tidak ditemukan untuk id: ${penjadwalan.idLokasi}');
                    print('Tipe penjadwalan.idLokasi: ${penjadwalan.idLokasi.runtimeType}');
                    print('Semua ID lokasi di map: ${lokasiMap.keys}');
                  }
                final alamat = lokasi?.alamat ?? '-';
                final time = tanggal != null ? DateFormat("HH.mm", 'id_ID').format(tanggal) + " WIB" : 'Waktu tidak valid';
                final statusText = statusToString(riwayat.statusBaru);
                final statusColor = getStatusColor(riwayat.statusBaru);

                return HistoryItem(
                  date: day,
                  month: month,
                  name: name,
                  location: alamat,
                  time: time,
                  status: statusText,
                  statusColor: statusColor,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}