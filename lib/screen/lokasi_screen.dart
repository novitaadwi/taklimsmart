import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:taklimsmart/models/lokasi_model.dart';
import 'package:taklimsmart/models/penjadwalan_model.dart';
import 'package:taklimsmart/models/response_model.dart';
import 'package:taklimsmart/services/penjadwalan_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LokasiScreen extends StatefulWidget {
  const LokasiScreen({super.key});

  @override
  State<LokasiScreen> createState() => _LokasiScreenState();
}

class _LokasiScreenState extends State<LokasiScreen> {
  final penjadwalanService = PenjadwalanService();
  Future<void> openGoogleMaps(double latitude, double longitude) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lokasi Pengajian"),
        backgroundColor: const Color.fromARGB(255, 255, 197, 23),
      ),
      body: FutureBuilder<ApiResponse<(LokasiModel, PenjadwalanReadModel)>>(
        future: penjadwalanService.getPengajianTerdekat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data?.data == null) {
            return Center(
              child: Text(snapshot.data?.message ?? 'Gagal memuat lokasi pengajian.'),
            );
          }

          final (lokasi, _) = snapshot.data!.data!;

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lokasi.latitude, lokasi.longitude),
                  initialZoom: 16.0,
                ),
                children: [
                  TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.geolocator_app',
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lokasi.latitude, lokasi.longitude),
                        child: Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 16,
                left: 20,
                right: 20,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lokasi.namaLokasi,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(lokasi.alamat, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            IconButton(
                              icon: Image.asset(
                                'assets/images/gmaps.png',
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () => openGoogleMaps(lokasi.latitude, lokasi.longitude),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Latitude: ${lokasi.latitude}, Longitude: ${lokasi.longitude}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}