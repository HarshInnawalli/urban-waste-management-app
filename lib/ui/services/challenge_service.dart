import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ChallengeService {

  static const String baseUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";

  final AuthService authService = AuthService();

  // GENERATE CHALLENGE
  Future<String> generateChallenge() async {

    final userId = await authService.getUserId();

    final response = await http.post(
      Uri.parse("$baseUrl/generate-challenge"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data["error"] ?? "Failed to generate challenge");
    }

    return data["challenge"] ??
        data["message"] ??
        "No challenge available";
  }

  // VALIDATE CHALLENGE
  Future<String> validateChallenge() async {

    final userId = await authService.getUserId();

    final response = await http.post(
      Uri.parse("$baseUrl/validate-challenge"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data["error"] ?? "Validation failed");
    }

    return data["message"] ?? "Validation complete";
  }
}