import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool compactModeEnabled = false;
  bool showUsageTips = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Activity reminders'),
            subtitle: const Text('Receive gentle prompts to log your waste regularly'),
            value: notificationsEnabled,
            activeColor: const Color(0xFF4CAF50),
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Compact layout'),
            subtitle: const Text('Use a tighter layout for faster browsing'),
            value: compactModeEnabled,
            activeColor: const Color(0xFF4CAF50),
            onChanged: (value) {
              setState(() {
                compactModeEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show usage tips'),
            subtitle: const Text('Display quick guidance throughout the app'),
            value: showUsageTips,
            activeColor: const Color(0xFF4CAF50),
            onChanged: (value) {
              setState(() {
                showUsageTips = value;
              });
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'About',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'EcoTrack',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Version 1.0 • A cleaner planet starts with your daily habits.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
