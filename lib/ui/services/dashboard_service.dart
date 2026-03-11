import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DashboardService {

  static const String baseUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";

  final AuthService authService = AuthService();

  Future<Map<String, dynamic>> getDashboard() async {

    final userId = await authService.getUserId();

    if (userId == null) {
      throw Exception("User not logged in");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/dashboard?user_id=$userId"),
    );

    if (response.statusCode != 200) {
      print("Dashboard API error: ${response.body}");
      throw Exception("Failed to fetch dashboard");
    }

    return jsonDecode(response.body);
  }
}