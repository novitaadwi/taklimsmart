import 'package:flutter/material.dart';
import 'package:taklimsmart/models/register_model.dart';
import 'package:taklimsmart/screen/login_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:taklimsmart/services/auth_service.dart';
import 'package:taklimsmart/widget/map_picker.dart';
import 'package:geocoding/geocoding.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  LatLng? selectedLocation;
  bool isLoading = false;

  void _bukaMapPicker() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          onLocationSelected: (LatLng pickedLocation) async {
            List<Placemark> placemarks = await placemarkFromCoordinates(
              pickedLocation.latitude,
              pickedLocation.longitude,
            );

            if (placemarks.isNotEmpty) {
              final placemark = placemarks.first;
              final alamatLengkap = '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}';

              setState(() {
                addressController.text = alamatLengkap;
                selectedLocation = pickedLocation;
              });
            }
          },
        ),
      ),
    );
  }

  void _submitRegister() async {
  final lat = selectedLocation?.latitude;
  final lon = selectedLocation?.longitude;

  if (selectedLocation == null || addressController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Silakan pilih lokasi di peta terlebih dahulu.")),
    );
    return;
  } else if (lat == null || lon == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lokasi tidak valid.")),
    );
    return;
  }

  if (nameController.text.isEmpty ||
      emailController.text.isEmpty ||
      phoneController.text.isEmpty ||
      passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mohon lengkapi semua field.")),
    );
    return;
  }

  final data = RegisterModel(
    username: nameController.text,
    password: passwordController.text,
    email: emailController.text,
    noHp: phoneController.text,
    alamat: addressController.text,
    latitude: lat,
    longitude: lon,
  );

  setState(() => isLoading = true);
  final response = await AuthService().register(data.toJson());
  setState(() => isLoading = false);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(response.message ?? "Terjadi kesalahan saat registrasi")),);

    if (response.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              alignment: Alignment.topLeft,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            Image.asset('assets/images/logo.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              'Registrasi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No Hp',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
              ),
              
            ),
            ElevatedButton(
              onPressed: _bukaMapPicker,
              child: Text("Pilih Lokasi di Peta"),
        ),

            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 197, 23),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                onPressed: _submitRegister,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Daftar',
                        style: TextStyle(color: Colors.white),
                      ),
                // () {
                //   Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(builder: (context) => LoginScreen()),
                //   );
                // },
                // child: const Text(
                //   'Daftar',
                //   style: TextStyle(color: Colors.white),
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}