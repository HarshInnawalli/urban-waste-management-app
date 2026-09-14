import 'package:flutter/material.dart';

import '../complaint_screen.dart';

class ReportWastePage extends StatefulWidget {
  const ReportWastePage({super.key});

  @override
  State<ReportWastePage> createState() => _ReportWastePageState();
}

class _ReportWastePageState extends State<ReportWastePage> {
  @override
  Widget build(BuildContext context) {
    return const ComplaintScreen();
  }
}
