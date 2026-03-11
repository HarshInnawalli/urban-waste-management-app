import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final DashboardService dashboardService = DashboardService();

  int points = 0;
  int streak = 0;
  Map<String, dynamic>? challenge;
  List badges = [];

  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {

    try {

      final data = await dashboardService.getDashboard();

      setState(() {

        points = data["points"] ?? 0;
        streak = data["streak"] ?? 0;
        challenge = data["challenge"];
        badges = data["badges"] ?? [];

        loading = false;
        error = false;

      });

    } catch (e) {

      print("Dashboard load error: $e");

      setState(() {
        loading = false;
        error = true;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Failed to load dashboard",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  loading = true;
                });
                loadDashboard();
              },
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),

      child: ListView(
        children: [

          const Text(
            "Your Eco Dashboard",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text("Points"),
              trailing: Text(points.toString()),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.local_fire_department,
                color: Colors.red,
              ),
              title: const Text("Streak"),
              trailing: Text("$streak days"),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Current Challenge",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),

          const SizedBox(height: 10),

          challenge == null
              ? const Text("No active challenge")
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(challenge!["challenge_text"] ?? ""),
                  ),
                ),

          const SizedBox(height: 20),

          const Text(
            "Badges",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),

          const SizedBox(height: 10),

          badges.isEmpty
              ? const Text("No badges earned yet")
              : Wrap(
                  spacing: 10,
                  children: badges.map((badge) {

                    return Chip(
                      label: Text(badge["badge_name"]),
                      avatar: const Icon(Icons.emoji_events),
                    );

                  }).toList(),
                )

        ],
      ),
    );
  }
}