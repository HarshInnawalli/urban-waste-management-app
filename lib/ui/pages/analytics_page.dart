import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {

  final AnalyticsService analyticsService = AnalyticsService();

  Map<String,double> categoryTotals = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    try {

      final logs = await analyticsService.getWasteLogs();

      Map<String,double> totals = {};

      for (var log in logs) {

        String category = log["category"];
        double amount = (log["amount"] as num).toDouble();

        totals[category] = (totals[category] ?? 0) + amount;
      }

      setState(() {
        categoryTotals = totals;
        loading = false;
      });

    } catch (e) {

      print("Analytics error: $e");

      setState(() {
        loading = false;
      });
    }
  }

  List<PieChartSectionData> buildSections() {

    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple
    ];

    int i = 0;

    return categoryTotals.entries.map((entry) {

      final section = PieChartSectionData(
        color: colors[i % colors.length],
        value: entry.value,
        title: entry.key,
        radius: 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      );

      i++;
      return section;

    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categoryTotals.isEmpty) {
      return const Center(child: Text("No waste data yet"));
    }

    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [

          const Text(
            "Waste Breakdown",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: buildSections(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Category Totals",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              children: categoryTotals.entries.map((entry) {

                return ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(entry.key),
                  trailing: Text(entry.value.toString()),
                );

              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}