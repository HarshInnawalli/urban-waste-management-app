import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/camera_service.dart';
import '../services/waste_service.dart';
import '../services/waste_classification_service.dart';

class WasteTrackingPage extends StatefulWidget {
  const WasteTrackingPage({super.key});

  @override
  State<WasteTrackingPage> createState() => _WasteTrackingPageState();
}

class _WasteTrackingPageState extends State<WasteTrackingPage> {
  final WasteService wasteService = WasteService();
  final CameraService _cameraService = CameraService();
  final WasteClassificationService _classificationService =
      WasteClassificationService();

  final TextEditingController amountController = TextEditingController();

  String category = "plastic";
  bool recycled = false;
  bool loading = false;
  bool classifying = false;
  WasteClassificationResult? classificationResult;

  final List<String> categories = WasteClassificationService.categories;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> submitWaste() async {
    if (amountController.text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      await wasteService.addWaste(
        category: category,
        amount: double.parse(amountController.text),
        recycled: recycled,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Waste logged successfully")),
      );

      amountController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _captureAndClassify() async {
    setState(() => classifying = true);

    try {
      final image = await _cameraService.capturePhoto();
      if (image == null) {
        return;
      }

      final result = await _classificationService.classify(image);
      if (!mounted) {
        return;
      }
      setState(() => classificationResult = result);
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      final denied = error.code.contains('denied') ||
          error.message?.toLowerCase().contains('permission') == true;
      _showMessage(
        denied
            ? 'Camera permission was denied. Enable it in device settings to classify waste.'
            : 'Unable to open the camera. Please try again.',
      );
    } on StateError catch (error) {
      if (mounted) {
        _showMessage(error.message?.toString() ?? 'Unable to classify this image.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to classify this image. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => classifying = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _categoryLabel(String value) {
    return value
        .split('_')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  Widget _classificationCard() {
    final result = classificationResult;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB7DEB0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Use ML Model for Classification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: classifying ? null : _captureAndClassify,
              icon: classifying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt_outlined),
              label: Text(classifying ? 'Classifying image...' : 'Capture and classify'),
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 12),
            Text(
              'Predicted category: ${_categoryLabel(result.category)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => setState(() => category = result.category),
              icon: const Icon(Icons.check),
              label: Text('Use ${_categoryLabel(result.category)}'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Text(
            "Log Your Waste",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Every log helps reduce waste and save the planet!",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.recycling, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text(
                        "Waste Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: category,
                    items: categories.map((c) {
                      IconData icon;
                      switch (c) {
                        case "plastic":
                          icon = Icons.local_drink;
                          break;
                        case "organic_compost":
                          icon = Icons.grass;
                          break;
                        case "paper_cardboard":
                          icon = Icons.description;
                          break;
                        case "glass":
                          icon = Icons.wine_bar_outlined;
                          break;
                        case "metal":
                          icon = Icons.hardware;
                          break;
                        case "ewaste":
                          icon = Icons.devices;
                          break;
                        default:
                          icon = Icons.delete;
                      }
                      return DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(icon, color: const Color(0xFF4CAF50)),
                            const SizedBox(width: 8),
                            Text(_categoryLabel(c)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Waste Category",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount (kg)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale, color: Color(0xFF4CAF50)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _classificationCard(),

                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text("Was this recycled?", style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: const Text("Help us track your eco-friendly actions!"),
                    value: recycled,
                    activeColor: const Color(0xFF4CAF50),
                    onChanged: (value) {
                      setState(() {
                        recycled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Motivational Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFFE8F5E8),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.eco, size: 48, color: Color(0xFF4CAF50)),
                  SizedBox(height: 8),
                  Text(
                    "Did you know?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Recycling 1 kg of plastic saves enough energy to power a 60W light bulb for 6 hours. Keep up the great work!",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : submitWaste,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle),
                        SizedBox(width: 8),
                        Text("Submit Waste", style: TextStyle(fontSize: 16)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
