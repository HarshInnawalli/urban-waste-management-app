import 'package:flutter/material.dart';
import '../services/waste_service.dart';

class WasteTrackingPage extends StatefulWidget {
  const WasteTrackingPage({super.key});

  @override
  State<WasteTrackingPage> createState() => _WasteTrackingPageState();
}

class _WasteTrackingPageState extends State<WasteTrackingPage> {
  final WasteService wasteService = WasteService();

  final TextEditingController amountController = TextEditingController();

  String category = "plastic";
  bool recycled = false;
  bool loading = false;

  final List<String> categories = ["plastic", "organic", "paper", "e-waste"];

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

    setState(() {
      loading = false;
    });
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
                        case "organic":
                          icon = Icons.grass;
                          break;
                        case "paper":
                          icon = Icons.description;
                          break;
                        case "e-waste":
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
                            Text(c),
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
                      labelText: "Category",
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
