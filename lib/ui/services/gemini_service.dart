import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class GeminiService {
  static const workerUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";
  static const int maxPayloadBytes = 20000;

  static Future<File> compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return imageFile;

    int width = 200;
    int quality = 30;

    img.Image resized = img.copyResize(image, width: width);
    List<int> jpgBytes = img.encodeJpg(resized, quality: quality);

    while (base64Encode(jpgBytes).length > maxPayloadBytes &&
        quality > 5) {
      quality -= 5;
      jpgBytes = img.encodeJpg(resized, quality: quality);
    }

    final tempFile =
        File('${imageFile.path}_compressed.jpg');
    await tempFile.writeAsBytes(jpgBytes);
    return tempFile;
  }

  // ✅ LOCATION IS NOW PASSED FROM UI
  static Future<String> generateEmailFromImage(
    File imageFile, {
    required Position position,
    String? prompt,
  }) async {
    final compressedFile = await compressImage(imageFile);
    final bytes = await compressedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final payload = {
      "image": base64Image,
      "prompt": prompt ??
          "Write a polite garbage complaint email based on this image.",
      "latitude": position.latitude,
      "longitude": position.longitude,
    };

    final response = await http.post(
      Uri.parse(workerUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception("Gemini worker failed: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data["email"] ?? "";
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