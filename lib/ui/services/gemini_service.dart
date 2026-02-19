import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // <-- import image package

class GeminiService {
  final String workerUrl =
      "https://complaint-worker.innawalliharsh.workers.dev";

  Future<String> generateComplaint(File imageFile, {String? prompt}) async {
    final bytes = await imageFile.readAsBytes();

    // --- Compress / resize image ---
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception("Failed to decode image");
    }
    final resized = img.copyResize(decoded, width: 800); // resize to max width 800px
    final base64Image = base64Encode(img.encodeJpg(resized));
    // --- End of compression ---

    final response = await http.post(
      Uri.parse(workerUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"image": base64Image, "prompt": prompt ?? ""}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to generate complaint: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data["complaint"];
  }
}


