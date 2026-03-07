import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'services/ward_service.dart';
import 'services/email_service.dart';
import 'services/gemini_service.dart';
import 'services/camera_service.dart';
import 'services/auth_service.dart';
import 'login_page.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  File? _selectedImage;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  // 🏢 Ward → Email mapping
  final Map<String, String> emailMap = {
    "A": "wardA@mcgm.gov.in",
    "B": "wardB@mcgm.gov.in",
    "C": "wardC@mcgm.gov.in",
    "D": "wardD@mcgm.gov.in",
    "E": "wardE@mcgm.gov.in",
    "FN": "wardFN@mcgm.gov.in",
    "FS": "wardFS@mcgm.gov.in",
    "GN": "wardGN@mcgm.gov.in",
    "GS": "wardGS@mcgm.gov.in",
    "HE": "wardHE@mcgm.gov.in",
    "HW": "wardHW@mcgm.gov.in",
    "KE": "wardKE@mcgm.gov.in",
    "KW": "wardKW@mcgm.gov.in",
    "L": "wardL@mcgm.gov.in",
    "ME": "wardME@mcgm.gov.in",
    "MW": "wardMW@mcgm.gov.in",
    "N": "wardN@mcgm.gov.in",
    "PN": "wardPN@mcgm.gov.in",
    "PS": "wardPS@mcgm.gov.in",
    "RC": "wardRC@mcgm.gov.in",
    "RN": "wardRN@mcgm.gov.in",
    "RS": "wardRS@mcgm.gov.in",
    "S": "wardS@mcgm.gov.in",
    "T": "wardT@mcgm.gov.in",
  };

  // ✅ Location Permission Handler
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission permanently denied. Enable it in settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _captureImage() async {
    final image = await CameraService().capturePhoto();
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submitComplaint({required bool useGemini}) async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please capture an image first")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final position = await _determinePosition();

      final wardName =
          await WardService().getWardFromLocation(position);

      if (wardName == null) {
        throw Exception("Ward not found for this location");
      }

      final officerEmail = emailMap[wardName];
      if (officerEmail == null || officerEmail.isEmpty) {
        throw Exception("No email mapped for $wardName");
      }

      String emailContent;

      if (useGemini) {
        emailContent = await GeminiService.generateEmailFromImage(
          _selectedImage!,
          position: position,
          prompt:
              "Write a polite garbage complaint email for Ward $wardName.",
        );
      } else {
        emailContent = await GeminiService.generateTemplateEmail(
          wardName: wardName,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      await EmailService.sendComplaintEmail(
        to: officerEmail,
        subject: "Garbage Complaint - Ward $wardName",
        body: emailContent,
        imageFile: _selectedImage!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email draft opened")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await _authService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Garbage Complaint"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : const Text("No image selected"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _captureImage,
              child: const Text("Capture Image"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _submitComplaint(useGemini: false),
                        child: const Text(
                            "Submit Complaint (Template)"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () =>
                            _submitComplaint(useGemini: true),
                        child: const Text(
                            "Submit Complaint (Gemini AI)"),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}