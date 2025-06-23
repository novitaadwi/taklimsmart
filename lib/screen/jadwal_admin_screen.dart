import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taklimsmart/models/penjadwalan_model.dart';
import 'package:taklimsmart/services/penjadwalan_service.dart';
import 'package:taklimsmart/models/lokasi_model.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:url_launcher/url_launcher.dart';


class JadwalAdminScreen extends StatefulWidget {
  const JadwalAdminScreen({super.key});

  @override
  State<JadwalAdminScreen> createState() => _JadwalAdminScreenState();
}

class _JadwalAdminScreenState extends State<JadwalAdminScreen> {
  List<PenjadwalanModel> jadwalList = [];
  Map<int, LokasiModel> lokasiMap = {};
  List<LokasiModel> lokasiList = [];
  
  final penjadwalanService = PenjadwalanService();
  Future<void> openGoogleMaps(double latitude, double longitude) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }//untuk list lokasi yang ada di tabel lokasi

  Future<void> _searchLokasi() async {
  final result = await PenjadwalanService().getAllLokasi();
  if (result.success && result.data != null) {
    setState(() {
      lokasiList = result.data!;
      lokasiMap = {
        for (var lokasi in lokasiList) lokasi.idLokasi: lokasi,
      };
    });
  } else {
      print(result.message);
    }
  }

  Future<void> _fetchJadwal() async {
  final result = await PenjadwalanService().getAllPenjadwalan();
  setState(() {
    jadwalList = result.data!.where((jadwal) {
      try {
        final tanggal = DateFormat('yyyy-MM-dd').parse(jadwal.tanggal);
        final today = DateTime.now();
        return !tanggal.isBefore(DateTime(today.year, today.month, today.day));
      } catch (e) {
        print('Error parsing tanggal: ${jadwal.tanggal}');
        return false;
      }
    }).toList();
  });
  if (result.success && result.data != null) {
    setState(() {
      jadwalList = result.data!;
    });
  } else {
      print(result.message);
    }
  }

  Future<void> _tambahJadwal(PenjadwalanModel newJadwal) async {
    final response = await PenjadwalanService().createJadwal(newJadwal);
    if (response.success) {
      await _fetchJadwal();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Jadwal berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Jadwal gagal ditambahkan')),
      );
    }
  }

  void _editJadwal(int index, PenjadwalanModel updatedJadwal) {
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
    final jadwal = isEdit ? jadwalList[index] : null;

    final tanggalController = TextEditingController(text: jadwal?.tanggal ?? '');
    final waktuController = TextEditingController(text: jadwal?.waktu ?? '');
    final deskripsiController = TextEditingController(text: jadwal?.deskripsi ?? '');
    final namaController = TextEditingController(text: jadwal?.namaPenjadwalan ?? '');
    final idLokasiController = TextEditingController(text: jadwal?.idLokasi.toString() ?? '');
    final tempatController = TextEditingController(
      text: isEdit
          ? lokasiList.firstWhere(
              (lokasi) => lokasi.idLokasi == jadwal?.idLokasi,
              orElse: () => LokasiModel(idLokasi: 0, namaLokasi: '', alamat: '', latitude: 0.0, longitude: 0.0),
            ).namaLokasi
          : '',
    );
    String formatWaktuUntukBackend(String input) {
      try {
        final parsed = DateFormat('HH:mm').parse(input);
        return DateFormat('HH:mm:ss').format(parsed);
      } catch (e) {
        print('Gagal format waktu untuk backend: $e');
        return '';
      }
    }

    String formatTanggalUntukBackend(String input) {
      try {
        final parsed = DateFormat('EEEE, d MMMM y', 'id_ID').parseStrict(input);
        final result = DateFormat('yyyy-MM-dd').format(parsed);
        print('Tanggal dikonversi untuk backend: $result');
        return result;
      } catch (e) {
        print('Gagal format tanggal untuk backend dari "$input": $e');
        return '';
      }
    }


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

                  // Nama Pengajian
                  _buildTextField('Nama Pengajian', namaController),
                  const SizedBox(height: 12),

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
                  Text('Tempat Pengajian',
                    style: TextStyle(fontSize: 14),
                  ),
                  TypeAheadField<LokasiModel>(
                    suggestionsCallback: (search) {
                      final suggestions = lokasiList
                          .where((lokasi) =>
                              lokasi.namaLokasi.toLowerCase().contains(search.toLowerCase()))
                          .toList();
                      return Future.value(suggestions);
                    },
                    builder: (context, _, focusNode) {
                      return TextField(
                        controller: tempatController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    },
                    itemBuilder: (context, LokasiModel lokasi) {
                      return ListTile(
                        title: Text(lokasi.namaLokasi),
                      );
                    },
                    onSelected: (LokasiModel lokasi) {
                      tempatController.text = lokasi.namaLokasi;
                      idLokasiController.text = lokasi.idLokasi.toString();
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildTextField('Deskripsi Pengajian', deskripsiController),
                  const SizedBox(height: 12),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async{
                        final newJadwal = PenjadwalanModel(
                          idPenjadwalan: isEdit ? jadwalList[index].idPenjadwalan : 0,
                          namaPenjadwalan: namaController.text,
                          tanggal: formatTanggalUntukBackend(tanggalController.text),
                          waktu: formatWaktuUntukBackend(waktuController.text),
                          idLokasi: int.tryParse(idLokasiController.text) ?? 0,
                          deskripsi: deskripsiController.text,
                          status: StatusPenjadwalan.diproses,
                        );
                        if (isEdit) {
                          _editJadwal(index, newJadwal);
                        } else {
                          await _tambahJadwal(newJadwal);
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

//Menampilkan Penjadwalan
  Widget _buildJadwalCard(PenjadwalanModel jadwal, int index) {
    DateTime? parsedDate;
    try {
      parsedDate = DateFormat('yyyy-MM-dd').parse(jadwal.tanggal);
      DateFormat('EEEE, d MMMM y', 'id_ID').format(parsedDate);
    } catch (e) {
      print('Error parsing date: ${jadwal.tanggal} - $e');
      parsedDate = DateTime.now();
    }

    String waktuFormatted = '';
    try {
      final parsedTime = DateFormat('HH:mm:ss').parse(jadwal.waktu);
      waktuFormatted = DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      print('Error parsing time: ${jadwal.waktu} - $e');
      waktuFormatted = jadwal.waktu;
    }

    final lokasi = lokasiMap[jadwal.idLokasi];

    final lokasiNama = jadwal.idLokasi != 0
    ? lokasiMap[jadwal.idLokasi]?.namaLokasi ?? 'Lokasi tidak ditemukan'
    : 'Lokasi tidak tersedia';

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
                              jadwal.namaPenjadwalan,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              jadwal.deskripsi ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "Waktu : $waktuFormatted",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Tempat : $lokasiNama",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            // Google Maps icon
                            IconButton(
                              icon: 
                              Image.asset(
                                'assets/images/gmaps.png',
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () {
                                if (lokasi != null) {
                                  openGoogleMaps(lokasi.latitude, lokasi.longitude);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lokasi tidak ditemukan')),
                                  );
                                }
                              },
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
  void initState() {
    super.initState();
    _fetchJadwal();
    _searchLokasi();
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
