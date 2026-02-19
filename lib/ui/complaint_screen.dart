import 'dart:io';
import 'package:flutter/material.dart';
import './services/camera_service.dart';
import './services/gemini_service.dart';
import './services/email_service.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final CameraService cameraService = CameraService();
  final GeminiService geminiService = GeminiService();
  final EmailService emailService = EmailService();

  File? imageFile;
  bool isLoading = false;

  Future<void> handleComplaintFlow() async {
    final photo = await cameraService.capturePhoto();
    if (photo == null) return;

    setState(() {
      imageFile = photo;
      isLoading = true;
    });

    try {
      final complaintText =
          await geminiService.generateComplaint(photo);

      await emailService.openEmail(
        "Complaint Regarding Issue",
        complaintText,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating complaint")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complaint Generator")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (imageFile != null)
                    Image.file(imageFile!, height: 200),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: handleComplaintFlow,
                    child: Text("Capture & Generate Complaint"),
                  ),
                ],
              ),
      ),
    );
  }
}

