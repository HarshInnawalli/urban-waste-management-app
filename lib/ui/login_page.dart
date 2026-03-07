import 'package:flutter/material.dart';
import 'package:gmail_gemini_component/ui/services/auth_service.dart';
import 'complaint_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await authService.signIn();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ComplaintScreen(),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Login error: $e")),
              );
            }
          },
          child: const Text("Login with Google"),
        ),
      ),
    );
  }
}