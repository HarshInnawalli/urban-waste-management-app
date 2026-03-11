import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../complaint_screen.dart';

import 'dashboard_page.dart';
import 'waste_tracking_page.dart';
import 'analytics_page.dart';
import 'challenge_page.dart';
import 'recycling_tips_page.dart';
import 'segregation_page.dart';
import 'ewaste_map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final AuthService authService = AuthService();

  // Bottom Navigation Pages
  final List<Widget> _pages = [
    const DashboardPage(),
    const WasteTrackingPage(),
    const AnalyticsPage(),
    ComplaintScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout() async {
    await authService.logout();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waste Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      // Drawer Menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                "Eco Waste App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text("Challenges"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChallengePage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.recycling),
              title: const Text("Recycling Tips"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecyclingTipsPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Waste Segregation"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SegregationPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.electrical_services),
              title: const Text("E-Waste Centers"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EwasteMapPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: "Track",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: "Report",
          ),
        ],
      ),
    );
  }
}

