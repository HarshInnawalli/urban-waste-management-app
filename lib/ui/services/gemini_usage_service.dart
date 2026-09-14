import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class GeminiUsageInfo {
  const GeminiUsageInfo({
    required this.usage,
    required this.remaining,
  });

  final int usage;
  final int remaining;
}

class GeminiUsageService {
  static const int dailyLimit = 2;
  static const String baseUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";

  final AuthService authService = AuthService();

  Future<GeminiUsageInfo> getTodayUsage() async {
    final userId = await authService.getUserId();
    if (userId == null) {
      throw Exception("User not logged in");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/gemini-usage?user_id=$userId"),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data["error"] ?? "Failed to fetch Gemini usage");
    }

    return GeminiUsageInfo(
      usage: (data["usage"] as num?)?.toInt() ?? 0,
      remaining: (data["remaining"] as num?)?.toInt() ?? dailyLimit,
    );
  }
}
