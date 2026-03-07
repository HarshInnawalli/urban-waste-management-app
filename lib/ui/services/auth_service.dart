import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "597188082312-esit0u235je6regdvmeo1t5ceskqs616.apps.googleusercontent.com",
  );
  static const String baseUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";

  Future<void> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return;

    final auth = await account.authentication;
    final idToken = auth.idToken;

    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"idToken": idToken}),
    );

    if (response.statusCode != 200) {
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      throw Exception("Login failed: ${response.body}");
    }

    final data = jsonDecode(response.body);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("user_id", data["user_id"]);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _googleSignIn.signOut();
  }
}