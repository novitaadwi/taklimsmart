import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    Future<void> pilihTanggal() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(
                  0xFFD1863A,
                ), // Warna header DatePicker (background bulan/tahun)
                onPrimary:
                    Colors
                        .white, // Warna teks di header (bulan/tahun, hari yang dipilih)
                surface:
                    Colors
                        .white, // Warna background body DatePicker (tanggal-tanggal)
                onSurface: Colors.black, // Warna teks tanggal di body
              ), // Warna background dialog secara keseluruhan
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(
                    0xFFD1863A,
                  ), // Warna teks tombol 'Batal' dan 'Oke'
                ),
              ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        String formattedDate = DateFormat(
          'EEEE, d MMMM y',
          'id_ID',
        ).format(pickedDate);
        tanggalController.text = formattedDate;
      }
    }

    Future<void> pilihWaktu() async {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(
                  0xFFD1863A,
                ), // Warna utama untuk header TimePicker
                onPrimary: Colors.white, // Warna teks di atas warna primary
                surface: Colors.white, // Warna background body TimePicker
                onSurface:
                    Colors.black, // Warna teks dan ikon di atas warna surface
              ), // Warna background dialog secara keseluruhan
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(
                    0xFFD1863A,
                  ), // Warna teks tombol 'Batal' dan 'Oke'
                ),
              ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final now = DateTime.now();
        final time = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        String formattedTime = DateFormat('HH:mm').format(time);
        waktuController.text = formattedTime;
      }
    }

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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal
                  _buildTextField(
                    'Tanggal Pengajian',
                    tanggalController,
                    readOnly: true,
                    onTap: pilihTanggal,
                  ),
                  const SizedBox(height: 12),

                  // Waktu
                  _buildTextField(
                    'Waktu Pengajian',
                    waktuController,
                    readOnly: true,
                    onTap: pilihWaktu,
                  ),
                  const SizedBox(height: 12),

                  // Tempat
                  _buildTextField('Tempat Pengajian', tempatController),
                  const SizedBox(height: 12),

                  // Penceramah
                  _buildTextField('Penceramah', penceramahController),
                  const SizedBox(height: 20),

                  // Tombol Simpan
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
                          _editJadwal(index, newJadwal);
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
                        style: TextStyle(
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFD1863A),
                width: 2.0,
              ),
            ),
            labelStyle: TextStyle(fontSize: 14, color: Colors.black),
            floatingLabelStyle: TextStyle(
              fontSize: 14,
              color: Color(0xFFD1863A),
            ),
          ),
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildJadwalCard(Map<String, String> jadwal, int index) {
    DateTime? parsedDate;
    try {
      parsedDate = DateFormat(
        'EEEE, d MMMM y',
        'id_ID',
      ).parse(jadwal['tanggal'] ?? '');
    } catch (e) {
      print('Error parsing date: ${jadwal['tanggal']} - $e');
      parsedDate = DateTime.now();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: Color(0xFFD1863A), // Background color for the card
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/pengajian.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                //informasi
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              jadwal['penceramah'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              jadwal['waktu'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${jadwal['tempat']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            // Google Maps icon
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
          ),

          Positioned(
            top: 15,
            left: 16,
            child: Container(
              width: 60,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(parsedDate),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'id_ID').format(parsedDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showTambahJadwalDialog(index: index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _hapusJadwal(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ],
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Jadwal Pengajian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Jadwal Terdekat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  jadwalList.isEmpty
                      ? Center(
                        child: Text(
                          'Belum ada jadwal.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: jadwalList.length,
                        itemBuilder: (context, index) {
                          return _buildJadwalCard(jadwalList[index], index);
                        },
                      ),
            ),
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
                        style: TextStyle(
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
            Container(
              color: const Color(0xFF4A5F2F),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
