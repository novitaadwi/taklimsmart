import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Foto profil
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                'assets/profile.jpg',
              ), // ganti sesuai aset
            ),
            const SizedBox(height: 10),
            const Text(
              'Mark',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 16),
                SizedBox(width: 4),
                Text('Alamat'),
              ],
            ),
            const SizedBox(height: 20),

            // Card form kuning
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFFD54F), // warna kuning
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _formItem(FontAwesomeIcons.penToSquare, 'Username'),
                  const SizedBox(height: 12),
                  _formItem(Icons.lock, 'Email'),
                  const SizedBox(height: 12),
                  _formItem(Icons.lock, 'No Hp'),
                  const SizedBox(height: 12),
                  _formItem(Icons.lock, 'Alamat'),
                  const SizedBox(height: 12),
                  _formItem(Icons.lock, 'Password'),
                  const SizedBox(height: 12),
                  // Baris tombol Edit dan Keluar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
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

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // aktif di 'Akun'
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green[800],
      ),
    );
  }

  Widget _formItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}
