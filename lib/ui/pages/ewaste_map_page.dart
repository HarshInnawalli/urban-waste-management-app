import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EwasteMapPage extends StatelessWidget {
  const EwasteMapPage({super.key});

  Future<void> openMaps() async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/e-waste+recycling+near+me+mumbai",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby E-Waste Centers"),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(
                    Icons.electrical_services,
                    size: 60,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Find Nearby E-Waste Collection Centers",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Use Google Maps to locate authorized e-waste recycling centers near you in Mumbai.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: 240,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text("Open in Google Maps"),
                      onPressed: openMaps,
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