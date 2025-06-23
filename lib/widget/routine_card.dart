import 'package:flutter/material.dart';
import 'package:taklimsmart/models/lokasi_model.dart';
import 'package:taklimsmart/models/penjadwalan_model.dart';
import 'package:intl/intl.dart';

class RoutineCard extends StatelessWidget {
  final LokasiModel lokasi;
  final PenjadwalanReadModel penjadwalan;

  const RoutineCard({
    super.key,
    required this.lokasi,
    required this.penjadwalan,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final tanggalFormatted = DateFormat('d MMMM y', 'id').format(penjadwalan.tanggalAsDateTime);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: screenWidth, // responsif
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // CircleAvatar(
            //   radius: 24,
            //   backgroundImage: AssetImage('assets/images/profile.jpg'),
            // ),
            const SizedBox(width: 10),
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lokasi.namaLokasi, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(lokasi.alamat, style: TextStyle(fontSize: 13)),
                  SizedBox(height: 4),
                  Text(penjadwalan.namaPenjadwalan, style: TextStyle(fontSize: 12)),
                  Text(tanggalFormatted, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Image.asset(
              'assets/images/masjid.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
