import 'package:flutter/material.dart';
import 'package:taklimsmart/services/auth_service.dart';
import 'package:taklimsmart/models/response_model.dart';
import 'package:taklimsmart/models/auth_model.dart';
import 'package:taklimsmart/screen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  bool _obscurePassword = true;

  void _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password tidak boleh kosong')),
      );
      return;
    }

    setState(() => isLoading = true);
    final ApiResponse<Auth> response = await AuthService().login({
      'username': username,
      'password': password,
    });
    setState(() => isLoading = false);

    if (response.success && response.data != null) {
      final token = response.data!.token;
      final user = response.data!.user;
      final sessionId = response.data!.sessionId;
      final idUser = response.data!.user.idUser;

      // Simpan token & sessionId
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('session_id', sessionId);
      await prefs.setInt('id_user', idUser);

      Map<String, dynamic> claims = Jwt.parseJwt(token);
      String role = (claims['user_Role'] ?? claims['role']).toString();
      await prefs.setString('role', role);
      print("Claims: $claims");
      print("Role dari token: $role");

      // Feedback ke user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selamat datang, ${user.username}')),
      );

      // Navigasi ke halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Terjadi kesalahan saat login')),
      );
      print("Success: ${response.success}");
      print("Message: ${response.message}");
      print("Token: ${response.data?.token}");
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
            const SizedBox(height: 20),
            Image.asset('assets/images/logo.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              'Masuk',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
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
                  backgroundColor: const Color(0xFF4A5F2F),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Masuk', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
