import 'package:flutter/material.dart';
import 'package:taklimsmart/screen/login_screen.dart';
import 'package:taklimsmart/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  Future<void> _handleLogout() async {
  final prefs = await SharedPreferences.getInstance();
  print("Session ID dari SharedPref: ${prefs.getInt('session_id')}");
  print("Token dari SharedPref: ${prefs.getString('token')}");
  final token = prefs.getString('token');
  final sessionId = prefs.getInt('session_id');
  

  if (token == null || sessionId == null) {
    await prefs.clear();
    if (!mounted) return; // Cek apakah widget masih ada di tree
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return;
  }

  final response = await AuthService().logout(token, sessionId);

  if (response.success) {
    await prefs.clear();
    print("Logout berhasil, data dihapus");
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return; // Cek apakah widget masih ada di tree
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  } else {
    if (!mounted) return; // Cek apakah widget masih ada di tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? "Logout gagal.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mark',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD1863A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _profileItem('Username', 'Mark123'),
                  const SizedBox(height: 12),
                  _profileItem('Email', 'mark@email.com'),
                  const SizedBox(height: 12),
                  _profileItem('No Hp', '081234567890'),
                  const SizedBox(height: 12),
                  _profileItem('Alamat', 'Jl. Mawar No. 10'),
                  const SizedBox(height: 12),
                  _profileItem('Password', '********'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Tambahkan aksi edit jika diperlukan
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A5F2F),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Edit"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text("Keluar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan item profil
  static Widget _profileItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value),
        ),
      ],
    );
  }

  // Fungsi dialog konfirmasi logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Keluar dari TaklimSmart?",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async{
                  Navigator.of(context).pop(); // Tutup dialog
                  await _handleLogout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Keluar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Batalkan",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
