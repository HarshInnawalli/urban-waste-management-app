import 'package:flutter/material.dart';

import 'ui/pages/login_page.dart';
import 'ui/pages/home_page.dart';

void main() {
  runApp(const WasteApp());
}

class WasteApp extends StatelessWidget {
  const WasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF4CAF50),
        scaffoldBackgroundColor: const Color(0xFFF2FAF0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF81C784),
          surface: Color(0xFFFFFFFF),
          background: Color(0xFFF2FAF0),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.black,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.black54),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4CAF50)),
          ),
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/home': (context) => const HomePage(),
      },
    );
  }
}
