import 'dart:convert';
import 'dart:io';

class ImageUtils {
  static Future<String> convertToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }
}
