import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JadwalAdminScreen extends StatefulWidget {
  const JadwalAdminScreen({super.key});

  @override
  State<JadwalAdminScreen> createState() => _JadwalAdminScreenState();
}

class _JadwalAdminScreenState extends State<JadwalAdminScreen> {
  List<Map<String, String>> jadwalList = [];

  void _tambahJadwal(Map<String, String> newJadwal) {
    setState(() {
      jadwalList.add(newJadwal);
    });
  }

  void _editJadwal(int index, Map<String, String> updatedJadwal) {
    setState(() {
      jadwalList[index] = updatedJadwal;
    });
  }

  void _hapusJadwal(int index) {
    setState(() {
      jadwalList.removeAt(index);
    });
  }

  void _showTambahJadwalDialog({int? index}) {
    final isEdit = index != null;
    final TextEditingController tanggalController = TextEditingController(
      text: isEdit ? jadwalList[index]['tanggal'] : '',
    );
    final TextEditingController waktuController = TextEditingController(
      text: isEdit ? jadwalList[index]['waktu'] : '',
    );
    final TextEditingController tempatController = TextEditingController(
      text: isEdit ? jadwalList[index]['tempat'] : '',
    );
    final TextEditingController penceramahController = TextEditingController(
      text: isEdit ? jadwalList[index]['penceramah'] : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Jadwal' : 'Tambah Jadwal',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Tanggal Pengajian', tanggalController),
                  const SizedBox(height: 12),
                  _buildTextField('Waktu Pengajian', waktuController),
                  const SizedBox(height: 12),
                  _buildTextField('Tempat Pengajian', tempatController),
                  const SizedBox(height: 12),
                  _buildTextField('Penceramah', penceramahController),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final newJadwal = {
                          'tanggal': tanggalController.text,
                          'waktu': waktuController.text,
                          'tempat': tempatController.text,
                          'penceramah': penceramahController.text,
                        };
                        if (isEdit) {
                          _editJadwal(index!, newJadwal);
                        } else {
                          _tambahJadwal(newJadwal);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A5F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalCard(Map<String, String> jadwal, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Stack(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('assets/images/pengajian.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    jadwal['tanggal']?.split(' ').first ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    jadwal['tanggal']?.split(' ').last ?? '',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD1863A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          jadwal['penceramah'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showTambahJadwalDialog(index: index),
                        child:
                            const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _hapusJadwal(index),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    jadwal['waktu'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '598 m',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        jadwal['tempat'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Image.asset(
                        'assets/images/gmaps.png',
                        width: 24,
                        height: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Jadwal Pengajian',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Subheader
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Jadwal Terdekat',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // List of cards
              Expanded(
                child: jadwalList.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada jadwal.',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: jadwalList.length,
                        itemBuilder: (context, index) {
                          return _buildJadwalCard(jadwalList[index], index);
                        },
                      ),
              ),


            // Tombol Tambah Jadwal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _showTambahJadwalDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD1863A),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tambah Jadwal',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Navigation Manual
            Container(
              color: const Color(0xFF4A5F2F),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, color: Colors.white),
                      SizedBox(height: 4),
                      Text('Beranda', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      SizedBox(height: 4),
                      Text('Akun', style: TextStyle(color: Colors.white)),
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
}
