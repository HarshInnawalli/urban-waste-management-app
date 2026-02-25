import 'dart:io';
import 'package:flutter/services.dart';

class EmailService {
  static const MethodChannel _channel =
      MethodChannel('com.harsh.garbage/email');

  static Future<void> sendComplaintEmail({
    required String to,
    required String subject,
    required String body,
    required File imageFile,
  }) async {
    try {
      await _channel.invokeMethod('sendEmail', {
        'to': to,
        'subject': subject,
        'body': body,
        'imagePath': imageFile.path,
      });
    } catch (e) {
      throw Exception("Failed to open Gmail: $e");
    }
  }
}
