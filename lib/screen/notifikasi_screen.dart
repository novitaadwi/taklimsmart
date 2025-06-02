import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  void _onNotificationTap(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kamu menekan notifikasi: $title'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget buildNotificationItem({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () => _onNotificationTap(context, title),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 36, height: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          buildNotificationItem(
            context: context,
            imagePath: 'assets/images/star.png', // ganti sesuai path asset kamu
            title: 'Selamat Datang!',
            subtitle: 'Selamat datang di aplikasi TaklimSmart.',
          ),
          buildNotificationItem(
            context: context,
            imagePath:
                'assets/images/quran.png', // ganti sesuai path asset kamu
            title: 'Yuk, pengajian!',
            subtitle: 'Jangan lupa datang di pengajian ya.',
          ),
        ],
      ),
    );
  }
}
