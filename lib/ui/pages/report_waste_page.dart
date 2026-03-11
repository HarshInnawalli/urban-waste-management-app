import 'package:flutter/material.dart';

class ReportWastePage extends StatelessWidget {
  const ReportWastePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Garbage"),
      ),

      body: const Center(
        child: Text(
          "Report Waste Page\n(Complaint AI coming here)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}