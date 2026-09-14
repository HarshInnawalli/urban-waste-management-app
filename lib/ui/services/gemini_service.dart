import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class GeminiGenerationResult {
  const GeminiGenerationResult({
    required this.email,
    required this.usage,
    required this.remaining,
  });

  final String email;
  final int usage;
  final int remaining;
}

class GeminiService {
  static const String workerUrl =
      "https://complaint-worker.innawalliharsh.workers.dev/generate-complaint";
  static const int maxPayloadBytes = 20000;

  static Future<File> compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      return imageFile;
    }

    const width = 200;
    var quality = 30;

    final resized = img.copyResize(image, width: width);
    var jpgBytes = img.encodeJpg(resized, quality: quality);

    while (base64Encode(jpgBytes).length > maxPayloadBytes && quality > 5) {
      quality -= 5;
      jpgBytes = img.encodeJpg(resized, quality: quality);
    }

    final tempFile = File('${imageFile.path}_compressed.jpg');
    await tempFile.writeAsBytes(jpgBytes);
    return tempFile;
  }

  static Future<GeminiGenerationResult> generateEmailFromImage(
    File imageFile, {
    required Position position,
    required String ward,
    String? prompt,
    int? userId,
  }) async {
    final compressedFile = await compressImage(imageFile);
    final bytes = await compressedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final payload = {
      "image": base64Image,
      "prompt":
          prompt ?? "Write a polite garbage complaint email based on this image.",
      "latitude": position.latitude,
      "longitude": position.longitude,
      "ward": ward,
      if (userId != null) "user_id": userId,
    };

    final response = await http.post(
      Uri.parse(workerUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        data["error"]?.toString() ?? "Gemini worker failed: ${response.body}",
      );
    }

    return GeminiGenerationResult(
      email: data["email"]?.toString() ?? "",
      usage: (data["todays_usage"] as num?)?.toInt() ?? 0,
      remaining: (data["remaining"] as num?)?.toInt() ?? 0,
    );
  }

  static Future<String> generateTemplateEmail({
    required String wardName,
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();

    return """
To,
Ward Officer,
$wardName Ward

Subject: Garbage accumulation complaint

Respected Sir/Madam,

I would like to report improper garbage accumulation at the following location:

Ward: $wardName
Latitude: $latitude
Longitude: $longitude
Time: $now

Kindly take necessary action at the earliest.

Thanking you,
A concerned citizen
""";
  }
}
