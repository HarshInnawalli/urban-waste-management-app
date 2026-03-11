import 'package:flutter/material.dart';

class SegregationPage extends StatelessWidget {
  const SegregationPage({super.key});

  Widget wasteCard({
    required String title,
    required String image,
    required Color color,
    required List<String> tips,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Image.asset(
              image,
              width: 80,
              height: 80,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ...tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text("• $tip"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Waste Segregation Guide"),
        backgroundColor: Colors.green,
      ),

      backgroundColor: Colors.grey[100],

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          wasteCard(
            title: "Wet Waste (Green Bin)",
            image: "assets/bins/green_bin.png",
            color: Colors.green,
            tips: [
              "Food scraps",
              "Vegetable peels",
              "Fruit waste",
              "Tea bags and coffee grounds",
              "Garden waste"
            ],
          ),

          wasteCard(
            title: "Dry Waste (Blue Bin)",
            image: "assets/bins/blue_bin.png",
            color: Colors.blue,
            tips: [
              "Paper and cardboard",
              "Plastic containers",
              "Metal cans",
              "Glass bottles",
              "Clean packaging materials"
            ],
          ),

          wasteCard(
            title: "Hazardous Waste (Red Bin)",
            image: "assets/bins/red_bin.png",
            color: Colors.red,
            tips: [
              "Batteries",
              "Expired medicines",
              "Sanitary waste",
              "Chemicals",
              "Broken glass"
            ],
          ),

          wasteCard(
            title: "E-Waste (Yellow Bin / Collection Centers)",
            image: "assets/bins/yellow_bin.png",
            color: Colors.orange,
            tips: [
              "Old mobile phones",
              "Chargers and cables",
              "Batteries",
              "Old computers",
              "Electronic appliances"
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
                "Tip: Always clean recyclable items before placing them in the dry waste bin. "
                "Proper segregation helps recycling plants process waste efficiently and reduces landfill waste.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}