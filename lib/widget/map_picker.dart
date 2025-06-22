import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapPickerScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  const MapPickerScreen({super.key, required this.onLocationSelected});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? currentLocation;
  LatLng? selectedLocation;
  LatLng? searchedLocation;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  
  bool isLoading = true;
  String errorMessage = '';
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = 'Layanan lokasi dinonaktifkan';
          isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = 'Izin lokasi ditolak';
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = 'Izin lokasi ditolak permanen';
          isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation = currentLocation;
        isLoading = false;
      });

      if (isMapReady) {
        _mapController.move(currentLocation!, 15);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal mendapatkan lokasi: ${e.toString()}';
      });
    }
  }

  void _onMapTap(LatLng latlng) {
    setState(() {
      selectedLocation = latlng;
    });
  }

  Future<void> searchLocationSuggestions(String query) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1'
  );

  final response = await http.get(url, headers: {
    'User-Agent': 'flutter_map_app'
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      searchResults = data;
    });
  }
}

  void _submitLocation() {
    if (selectedLocation != null) {
      widget.onLocationSelected(selectedLocation!);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih lokasi di peta")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi"),
        backgroundColor: const Color.fromARGB(255, 255, 197, 23),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentLocation == null
              ? Center(child: Text(errorMessage))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentLocation!,
                    initialZoom: 16.0,
                    onTap: (tapPosition, latlng) => _onMapTap(latlng),
                  ),
                  
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.geolocator_app',
                    ),
                    if (selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    if (searchedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: searchedLocation!,
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari Lokasi',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            final query = _searchController.text.trim();
                            if (query.isNotEmpty) {
                              searchLocationSuggestions(query);
                            }
                          },
                        ),
                      ),
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          searchLocationSuggestions(value);
                        } else {
                          setState(() => searchResults = []);
                        }
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) searchLocationSuggestions(value);
                      },
                    ),
                  ),
                ),
                if (searchResults.isNotEmpty)
                  Positioned(
                    top: 60,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final result = searchResults[index];
                          return ListTile(
                            title: Text(result['display_name'] ?? 'Lokasi tidak ditemukan'),
                            onTap: () {
                              final lat = double.parse(result['lat']);
                              final lon = double.parse(result['lon']);
                              final latLng = LatLng(lat, lon);
                              setState(() {
                                searchedLocation = latLng;
                                selectedLocation = latLng;
                                _searchController.text = result['display_name'];
                                _mapController.move(latLng, 16.0);
                                searchResults = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitLocation,
        backgroundColor: const Color.fromARGB(255, 255, 197, 23),
        icon: const Icon(Icons.check),
        label: const Text("Pilih Lokasi"),
      ),
    );
  }
}
