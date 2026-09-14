import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ChallengeService {
  static const String baseUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";
  static const String defaultChallengeText =
      "Log some waste first to generate a recycle challenge.";

  final AuthService authService = AuthService();

  Future<String> generateChallenge() async {
    final userId = await authService.getUserId();
    if (userId == null) {
      throw Exception("User not logged in");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/generate-challenge"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data["error"] ?? "Failed to generate challenge");
    }

    return data["challenge"]?.toString() ??
        data["message"]?.toString() ??
        defaultChallengeText;
  }

  Future<String> getSavedChallenge() async {
    final userId = await authService.getUserId();
    if (userId == null) {
      return defaultChallengeText;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/dashboard?user_id=$userId"),
    );

    if (response.statusCode != 200) {
      return defaultChallengeText;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final challenge = data["challenge"];

    if (challenge is Map<String, dynamic>) {
      final challengeText = challenge["challenge_text"]?.toString();
      if (challengeText != null && challengeText.isNotEmpty) {
        return challengeText;
      }
    }

    return defaultChallengeText;
  }

  Future<String> validateChallenge() async {
    final userId = await authService.getUserId();
    if (userId == null) {
      throw Exception("User not logged in");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/validate-challenge"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data["error"] ?? "Validation failed");
    }

    return data["message"]?.toString() ?? "Validation complete";
  }
}
