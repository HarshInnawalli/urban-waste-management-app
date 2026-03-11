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
  final TextEditingController itemController = TextEditingController();
  final TextEditingController wardController = TextEditingController();

  String category = "plastic";
  bool recycled = false;
  bool loading = false;

  final List<String> categories = [
    "plastic",
    "organic",
    "paper",
    "e-waste"
  ];

  Future<void> submitWaste() async {

    if (amountController.text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {

      await wasteService.addWaste(
        category: category,
        amount: double.parse(amountController.text),
        itemName: itemController.text,
        ward: wardController.text,
        recycled: recycled,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Waste logged successfully"))
      );

      amountController.clear();
      itemController.clear();

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );

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
            "Log Waste",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField(
            value: category,
            items: categories.map((c) {

              return DropdownMenuItem(
                value: c,
                child: Text(c),
              );

            }).toList(),
            onChanged: (value) {
              setState(() {
                category = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: "Category"
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount (kg)"
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: itemController,
            decoration: const InputDecoration(
              labelText: "Item name (optional)"
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: wardController,
            decoration: const InputDecoration(
              labelText: "Ward / Area"
            ),
          ),

          const SizedBox(height: 15),

          SwitchListTile(
            title: const Text("Recycled"),
            value: recycled,
            onChanged: (value) {
              setState(() {
                recycled = value;
              });
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: loading ? null : submitWaste,
            child: loading
                ? const CircularProgressIndicator()
                : const Text("Submit Waste"),
          )

        ],
      ),
    );
  }
}