import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../services/challenge_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService dashboardService = DashboardService();
  final ChallengeService challengeService = ChallengeService();

  int points = 0;
  int streak = 0;
  Map<String, dynamic>? challenge;
  String? activeChallengeText;
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
      final savedChallenge = await challengeService.getSavedChallenge();
      final savedChallengeText = savedChallenge == ChallengeService.defaultChallengeText
          ? null
          : savedChallenge;
      final dashboardChallengeText = data["challenge"]?["challenge_text"]
          ?.toString();

      setState(() {
        points = data["points"] ?? 0;
        streak = data["streak"] ?? 0;
        challenge = data["challenge"];
        activeChallengeText = savedChallengeText ?? dashboardChallengeText;
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

    // Calculate motivational metrics
    double carbonOffset = points * 0.5; // Example: 0.5 kg CO2 per point
    int treesSaved = (points / 10).round(); // Example: 1 tree per 10 points

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Every action counts towards a greener planet!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),

          // Motivational Cards
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.eco, size: 48, color: Color(0xFF4CAF50)),
                  const SizedBox(height: 8),
                  Text(
                    "You've offset ${carbonOffset.toStringAsFixed(1)} kg of CO₂!",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "That's equivalent to planting $treesSaved trees.",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber, size: 32),
                    title: const Text("Points", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("$points earned"),
                    trailing: Text(
                      points.toString(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 32,
                    ),
                    title: const Text("Streak", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Keep it up!"),
                    trailing: Text(
                      "$streak days",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Current Challenge",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),

          const SizedBox(height: 10),

          activeChallengeText == null || activeChallengeText!.isEmpty
              ? Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "No active challenge",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Complete waste logging to unlock challenges!",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.flag, size: 48, color: Color(0xFF4CAF50)),
                        const SizedBox(height: 8),
                        Text(
                          activeChallengeText!,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

          const SizedBox(height: 30),

          const Text(
            "Badges Earned",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),

          const SizedBox(height: 10),

          badges.isEmpty
              ? Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "No badges earned yet",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Log waste and complete challenges to earn badges!",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: badges.map((badge) {
                    return Chip(
                      label: Text(badge["badge_name"]),
                      avatar: const Icon(Icons.emoji_events, color: Colors.amber),
                      backgroundColor: const Color(0xFFE8F5E8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    );
                  }).toList(),
                )
        ],
      ),
    );
  }
}
