import 'package:flutter/material.dart';
import 'package:gmail_gemini_component/ui/complaint_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complaint App',
      debugShowCheckedModeBanner: false,
      home: ComplaintScreen(),
    );
  }
}
