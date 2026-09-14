import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class WasteService {
  static const String baseUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";
  static const Duration rapidRepeatWindow = Duration(seconds: 30);

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

    final existingLogs = await getWasteLogs();

    final rapidRepeatEntries = existingLogs.where((entry) {
      final entryTimestamp = _parseTimestamp(entry);
      final entryCategory = _parseCategory(entry);
      final entryAmount = _parseAmount(entry);

      return entryTimestamp != null &&
          _isWithinRapidRepeatWindow(entryTimestamp) &&
          entryCategory == category.toLowerCase() &&
          _isSameAmount(entryAmount, amount);
    }).length;

    if (rapidRepeatEntries >= 3) {
      throw Exception(
        "The same $category amount was logged too many times in quick succession. Please wait before submitting again.",
      );
    }

    if (existingLogs.isNotEmpty) {
      final amounts = existingLogs
          .map(_parseAmount)
          .where((value) => value > 0)
          .toList();

      if (amounts.isNotEmpty) {
        final mean = amounts.reduce((a, b) => a + b) / amounts.length;
        final variance =
            amounts.map((value) => pow(value - mean, 2)).reduce((a, b) => a + b) /
            amounts.length;
        final sd = sqrt(variance);

        if (amount > mean + 3 * sd) {
          throw Exception(
            "Waste amount exceeds 3 standard deviations of your logged history.",
          );
        }
      }
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
          "recycled": recycled,
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

  DateTime? _parseTimestamp(Map<String, dynamic> log) {
    final rawValue = log["timestamp"] ?? log["created_at"] ?? log["date"];

    if (rawValue is DateTime) {
      return rawValue;
    }
    if (rawValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawValue);
    }
    if (rawValue is String) {
      return DateTime.tryParse(rawValue);
    }

    return null;
  }

  String _parseCategory(Map<String, dynamic> log) {
    return (log["category"] ?? log["wasteType"] ?? "")
        .toString()
        .trim()
        .toLowerCase();
  }

  double _parseAmount(Map<String, dynamic> log) {
    final rawValue = log["amount"] ?? log["value"] ?? log["weight"];
    if (rawValue is num) {
      return rawValue.toDouble();
    }
    if (rawValue is String) {
      return double.tryParse(rawValue) ?? 0;
    }
    return 0;
  }

  bool _isWithinRapidRepeatWindow(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toLocal());
    return !difference.isNegative && difference <= rapidRepeatWindow;
  }

  bool _isSameAmount(double first, double second) {
    return (first - second).abs() < 0.0001;
  }
}
