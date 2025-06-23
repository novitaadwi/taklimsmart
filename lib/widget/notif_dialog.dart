import 'package:flutter/material.dart';
import 'package:taklimsmart/services/penjadwalan_service.dart';

Future<void> tampilkanNotifikasiDialog(BuildContext context) async {
  final penjadwalanService = PenjadwalanService();

  final response = await penjadwalanService.getPengajianTerdekat();

  if (response.success && response.data != null) {
    final (lokasi, penjadwalan) = response.data!;

    final String tempat = lokasi.namaLokasi;
    final String pukul = penjadwalan.waktu.substring(0, 5); // ambil jam:menit

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Jangan lupa hadir pengajian hari ini!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Tempat: $tempat\nPukul: $pukul WIB",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF425C37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Oke", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  } else {
    // Kalau gagal ambil data, bisa tampilkan error atau dialog default
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message ?? 'Gagal memuat pengajian terdekat')),
    );
  }
}
