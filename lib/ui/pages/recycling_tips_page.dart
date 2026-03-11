import 'package:flutter/material.dart';

class RecyclingTipsPage extends StatelessWidget {
  const RecyclingTipsPage({super.key});

  Widget tipCard({
    required String image,
    required String title,
    required List<String> tips,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: ExpansionTile(

        leading: Image.asset(
          image,
          width: 40,
          height: 40,
        ),

        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        children: tips
            .map(
              (tip) => ListTile(
                title: Text("• $tip"),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recycling Tips"),
        backgroundColor: Colors.green,
      ),

      backgroundColor: Colors.grey[100],

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          tipCard(
            image: "assets/recycling/plastic.png",
            title: "Plastic Recycling",
            color: Colors.blue,
            tips: [
              "Rinse plastic containers before recycling",
              "Avoid single-use plastic bottles",
              "Use reusable water bottles",
              "Separate soft plastic from hard plastic",
              "Carry cloth bags instead of plastic bags"
            ],
          ),

          tipCard(
            image: "assets/recycling/paper.png",
            title: "Paper Recycling",
            color: Colors.brown,
            tips: [
              "Reuse one-sided printed paper",
              "Recycle newspapers and magazines",
              "Avoid laminated paper",
              "Flatten cardboard boxes",
              "Use digital documents when possible"
            ],
          ),

          tipCard(
            image: "assets/recycling/compost.png",
            title: "Organic Waste Recycling",
            color: Colors.green,
            tips: [
              "Compost fruit and vegetable peels",
              "Use a home compost bin",
              "Turn food waste into plant compost",
              "Avoid mixing organic waste with plastic",
              "Use compost in gardens"
            ],
          ),

          tipCard(
            image: "assets/recycling/ewaste.png",
            title: "E-Waste Recycling",
            color: Colors.orange,
            tips: [
              "Do not throw electronics in regular trash",
              "Take devices to authorized recycling centers",
              "Donate working electronics",
              "Remove batteries before disposal",
              "Use manufacturer take-back programs"
            ],
          ),

          tipCard(
            image: "assets/recycling/reduce.png",
            title: "Reduce & Reuse",
            color: Colors.purple,
            tips: [
              "Carry reusable shopping bags",
              "Avoid over-packaged products",
              "Buy refillable items",
              "Repair instead of replacing",
              "Use reusable containers"
            ],
          ),

          const SizedBox(height: 20),

          Card(
            color: Colors.green[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Recycling reduces landfill waste, saves energy, and conserves natural resources. "
                "Even small daily habits can create a big environmental impact.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}