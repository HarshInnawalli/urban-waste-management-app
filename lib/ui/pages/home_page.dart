import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';

import 'dashboard_page.dart';
import 'waste_tracking_page.dart';
import 'analytics_page.dart';
import 'report_waste_page.dart';
import 'challenge_page.dart';
import 'recycling_tips_page.dart';
import 'segregation_page.dart';
import 'ewaste_map_page.dart';
import 'settings_page.dart';
import 'help_support_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _dashboardRefreshVersion = 0;

  final AuthService authService = AuthService();
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = _createPages();
  }

  List<Widget> _createPages() {
    return [
      DashboardPage(key: ValueKey(_dashboardRefreshVersion)),
      const WasteTrackingPage(),
      const AnalyticsPage(),
      const ReportWastePage(),
    ];
  }

  void _refreshDashboardPage() {
    _pages = _createPages();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout() async {
    await authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _openChallengePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChallengePage(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _dashboardRefreshVersion++;
      _refreshDashboardPage();
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EcoTrack",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Logout",
          ),
        ],
      ),

      // Drawer Menu
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.eco, size: 48, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      "EcoTrack",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Making the planet greener, one step at a time",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.white),
                title: const Text("Challenges", style: TextStyle(color: Colors.white)),
                onTap: () {
                  _openChallengePage();
                },
              ),

              ListTile(
                leading: const Icon(Icons.recycling, color: Colors.white),
                title: const Text("Recycling Tips", style: TextStyle(color: Colors.white)),
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
                leading: const Icon(Icons.category, color: Colors.white),
                title: const Text("Waste Segregation", style: TextStyle(color: Colors.white)),
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
                leading: const Icon(Icons.electrical_services, color: Colors.white),
                title: const Text("E-Waste Centers", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EwasteMapPage(),
                    ),
                  );
                },
              ),

              const Divider(color: Colors.white30),

              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text("Settings", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.help, color: Colors.white),
                title: const Text("Help & Support", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFE9F7E6),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            tooltip: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_outline),
            label: "Track",
            tooltip: "Log Waste",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
            tooltip: "View Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: "Report",
            tooltip: "Report Issues",
          ),
        ],
      ),
    );
  }
}

