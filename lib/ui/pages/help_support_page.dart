import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'How to Use the App',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 12),
          const Text(
            'This guide helps you make the most of EcoTrack.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          _buildStepCard(
            icon: Icons.delete_outline,
            title: 'Log Waste',
            description: 'Select the waste type, enter the amount, and mark if it was recycled. The app tracks your eco impact automatically.',
          ),
          _buildStepCard(
            icon: Icons.bar_chart,
            title: 'View Analytics',
            description: 'Switch between day, week, month, and all time to see trends and progress over time.',
          ),
          _buildStepCard(
            icon: Icons.emoji_events,
            title: 'Complete Challenges',
            description: 'Finish eco-friendly tasks to earn points, badges, and carbon savings rewards.',
          ),
          _buildStepCard(
            icon: Icons.recycling,
            title: 'Use Tips',
            description: 'Explore recycling tips and segregation guidance to reduce waste in your daily routine.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Support',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 12),
          const Text(
            'If you need help, you can use this page as a quick reference. For additional assistance, contact the app support team from the settings menu.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  static Widget _buildStepCard({required IconData icon, required String title, required String description}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
