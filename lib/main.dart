import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taklimsmart/screen/welcome_screen.dart';
import 'package:taklimsmart/screen/main_screen.dart';
import 'package:taklimsmart/screen/akun_screen.dart';

void main() {
  runApp(const TaklimSmartApp());
}

class TaklimSmartApp extends StatelessWidget {
  const TaklimSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaklimSmart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins', 
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFD1863A),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A5F2F),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1863A), width: 2.0),
          ),
          labelStyle: TextStyle(fontSize: 14, color: Colors.black),
          floatingLabelStyle: TextStyle(fontSize: 14, color: Color(0xFFD1863A)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('id', ''),
      ],
      locale: const Locale('id', ''),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/main': (context) => const MainScreen(),
        '/akun': (context) => const AkunScreen(),
      },
    );
  }
}
