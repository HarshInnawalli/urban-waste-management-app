import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class WasteService {

  static const String baseUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";

  final AuthService authService = AuthService();

  // ADD WASTE
  Future<void> addWaste({
    required String category,
    required double amount,
    String? itemName,
    String? ward,
    bool recycled = false,
  }) async {

    final userId = await authService.getUserId();

    if (userId == null) {
      throw Exception("User not logged in");
    }

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/add-waste"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "category": category,
          "amount": amount,
          "item_name": itemName,
          "ward": ward,
          "recycled": recycled
        }),
      );

      print("Add Waste Status: ${response.statusCode}");
      print("Add Waste Response: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to add waste: ${response.body}");
      }

    } catch (e) {
      print("Add Waste Error: $e");
      rethrow;
    }
  }


  // GET WASTE LOGS (FOR ANALYTICS)
  Future<List<Map<String, dynamic>>> getWasteLogs() async {

    final userId = await authService.getUserId();

    if (userId == null) {
      throw Exception("User not logged in");
    }

    try {

      final response = await http.get(
        Uri.parse("$baseUrl/waste-logs?user_id=$userId"),
      );

      print("Waste Logs Status: ${response.statusCode}");
      print("Waste Logs Response: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch waste logs: ${response.body}");
      }

      final data = jsonDecode(response.body);

      return List<Map<String, dynamic>>.from(data);

    } catch (e) {
      print("Waste Logs Error: $e");
      rethrow;
    }
  }
}