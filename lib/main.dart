import 'package:flutter/material.dart';
import 'package:gmail_gemini_component/ui/complaint_screen.dart';
import 'package:gmail_gemini_component/ui/login_page.dart';
import 'package:gmail_gemini_component/ui/services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complaint App',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<int?>(
        future: _authService.getUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == null) {
            return const LoginPage();
          }

          return const ComplaintScreen();
        },
      ),
    );
  }
}