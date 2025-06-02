import 'package:flutter/material.dart';

class RoutineCard extends StatelessWidget {
  const RoutineCard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/images/profile.jpg'), // pastikan file ini ada
            ),
            const SizedBox(width: 16),
            Expanded( // supaya teks tidak overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("HJ. Jepri", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Jalan Kalimantan 5", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text("Pengajian Rutin\n30 Mei 2025", style: TextStyle(fontSize: 12)),
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
