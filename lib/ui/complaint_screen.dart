import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'services/auth_service.dart';
import 'services/camera_service.dart';
import 'services/email_service.dart';
import 'services/gemini_service.dart';
import 'services/gemini_usage_service.dart';
import 'services/ward_service.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  int _geminiUsageCount = 0;
  int _geminiRemaining = GeminiUsageService.dailyLimit;

  final AuthService _authService = AuthService();
  final GeminiUsageService _geminiUsageService = GeminiUsageService();

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

  int get _remainingGeminiUses =>
      _geminiRemaining < 0 ? 0 : _geminiRemaining;

  @override
  void initState() {
    super.initState();
    _loadGeminiUsage();
  }

  Future<void> _loadGeminiUsage() async {
    try {
      final usageInfo = await _geminiUsageService.getTodayUsage();
      if (!mounted) {
        return;
      }

      setState(() {
        _geminiUsageCount = usageInfo.usage;
        _geminiRemaining = usageInfo.remaining;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _geminiUsageCount = 0;
        _geminiRemaining = GeminiUsageService.dailyLimit;
      });
    }
  }

  Future<int?> _getUserId() async {
    final userId = await _authService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in again to continue.")),
      );
      return null;
    }
    return userId;
  }

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
        'Location permission permanently denied. Enable it in settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _captureImage() async {
    final image = await CameraService().capturePhoto();
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _uploadMedia() async {
    final image = await CameraService().pickFromGallery();
    if (image != null && mounted) {
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

    final userId = await _getUserId();
    if (userId == null) {
      return;
    }

    if (useGemini && _remainingGeminiUses == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gemini email generation is limited to 2 times per day."),
        ),
      );
      await _loadGeminiUsage();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final position = await _determinePosition();
      final wardName = await WardService().getWardFromLocation(position);

      if (wardName == null) {
        throw Exception("Ward not found for this location");
      }

      final officerEmail = emailMap[wardName];
      if (officerEmail == null || officerEmail.isEmpty) {
        throw Exception("No email mapped for $wardName");
      }

      String emailContent;

      if (useGemini) {
        final result = await GeminiService.generateEmailFromImage(
          _selectedImage!,
          position: position,
          ward: wardName,
          prompt: "Write a polite garbage complaint email for Ward $wardName.",
          userId: userId,
        );
        emailContent = result.email;

        if (mounted) {
          setState(() {
            _geminiUsageCount = result.usage;
            _geminiRemaining = result.remaining;
          });
        }
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
        SnackBar(
          content: Text(
            useGemini
                ? "AI complaint draft opened. $_remainingGeminiUses Gemini attempts left today."
                : "Email draft opened",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);
  }

  Widget _usageCard() {
    final usageProgress = _geminiUsageCount / GeminiUsageService.dailyLimit;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDDF5D8), Color(0xFFF7FFF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB7DEB0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "AI Report Assistant",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F4D24),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _remainingGeminiUses == 0
                      ? const Color(0xFFFFE2E0)
                      : const Color(0xFFE9F7E6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "$_remainingGeminiUses left today",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _remainingGeminiUses == 0
                        ? const Color(0xFFB3261E)
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "Upload or capture a garbage photo, then open a ward complaint draft with either a template or Gemini-generated wording.",
            style: TextStyle(
              height: 1.4,
              color: Color(0xFF355B38),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: usageProgress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: const Color(0xFFCFE8C9),
              valueColor: AlwaysStoppedAnimation<Color>(
                _remainingGeminiUses == 0
                    ? const Color(0xFFB3261E)
                    : const Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Gemini can generate complaint text only twice per day to reduce misuse.",
            style: TextStyle(
              color: _remainingGeminiUses == 0
                  ? const Color(0xFF8D2A1D)
                  : const Color(0xFF47664A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePreview() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _selectedImage != null
          ? Container(
              key: const ValueKey("image"),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFC4E4BE), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 12),
                    color: Color(0x16000000),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  _selectedImage!,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Container(
              key: const ValueKey("placeholder"),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFFFA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFCAE7C4)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.photo_camera_back, size: 48, color: Color(0xFF4CAF50)),
                  SizedBox(height: 12),
                  Text(
                    "No image selected",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF295B31),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Capture or upload a clear photo of the garbage spot to prepare your complaint.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF59715C),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _loadingState() {
    return const Column(
      children: [
        SizedBox(
          height: 44,
          width: 44,
          child: CircularProgressIndicator(strokeWidth: 4),
        ),
        SizedBox(height: 14),
        Text(
          "Preparing your complaint draft...",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buttons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton(
                onPressed: _captureImage,
                icon: Icons.camera_alt,
                label: "Capture",
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                onPressed: _uploadMedia,
                icon: Icons.upload_file,
                label: "Upload",
                backgroundColor: const Color(0xFFE5F6E1),
                foregroundColor: const Color(0xFF245328),
              ),
            ),
          ],
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 18),
          _actionButton(
            onPressed: () => _submitComplaint(useGemini: false),
            icon: Icons.email_outlined,
            label: "Open Template Complaint",
            backgroundColor: const Color(0xFF1F7A6C),
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          _actionButton(
            onPressed: _remainingGeminiUses == 0
                ? null
                : () => _submitComplaint(useGemini: true),
            icon: Icons.smart_toy_outlined,
            label: "Open Gemini Complaint",
            backgroundColor: _remainingGeminiUses == 0
                ? const Color(0xFFB8C6B5)
                : const Color(0xFF295F2D),
            foregroundColor: Colors.white,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FAF0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Report Waste",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF214F28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Turn a waste hotspot into a ready-to-send ward complaint in just a few steps.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Color(0xFF567259),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _usageCard(),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFEFB),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFD6ECCE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 24,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.image_search, color: Color(0xFF4CAF50)),
                            SizedBox(width: 8),
                            Text(
                              "Evidence Preview",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D5C33),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _imagePreview(),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _isLoading ? _loadingState() : _buttons(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
