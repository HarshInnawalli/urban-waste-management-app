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
      title: 'Waste Management App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

      // App starts at login page
      home: const LoginPage(),

      // Named routes for navigation
      routes: {
        '/home': (context) => const HomePage(),
      },

    );
  }
}