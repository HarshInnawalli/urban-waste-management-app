import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AnalyticsService {

  static const String baseUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";

  final AuthService authService = AuthService();

  Future<List<Map<String, dynamic>>> getWasteLogs() async {

    final userId = await authService.getUserId();

    if (userId == null) {
      throw Exception("User not logged in");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/waste-logs?user_id=$userId"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load waste logs");
    }

    final data = jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(data);
  }
}