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
  final List<String> rangeOptions = [
    'Present Day',
    'This Week',
    'This Month',
    'All Time',
  ];

  String selectedRange = 'All Time';
  List<Map<String, dynamic>> wasteLogs = [];
  Map<String, double> categoryTotals = {};
  Map<DateTime, double> trendTotals = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final logs = await analyticsService.getWasteLogs();
      setState(() {
        wasteLogs = logs;
        loading = false;
      });
      updateAnalytics();
    } catch (e) {
      print("Analytics error: $e");
      setState(() {
        loading = false;
      });
    }
  }

  void updateAnalytics() {
    final filteredLogs = _filterLogs();
    final totals = <String, double>{};
    final trendMap = <DateTime, double>{};

    for (var log in filteredLogs) {
      final timestamp = _parseTimestamp(log);
      final amount = _parseAmount(log);

      if (timestamp == null || amount <= 0) {
        continue;
      }

      final category =
          log['category']?.toString() ??
          log['wasteType']?.toString() ??
          'Unknown';

      totals[category] = (totals[category] ?? 0) + amount;

      final dayKey = DateTime(timestamp.year, timestamp.month, timestamp.day);
      trendMap[dayKey] = (trendMap[dayKey] ?? 0) + amount;
    }

    final sortedTrendEntries = trendMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    setState(() {
      categoryTotals = totals;
      trendTotals = Map.fromEntries(sortedTrendEntries);
    });
  }

  List<Map<String, dynamic>> _filterLogs() {
    final now = DateTime.now();

    return wasteLogs.where((log) {
      final timestamp = _parseTimestamp(log);
      if (timestamp == null) return false;

      switch (selectedRange) {
        case 'Present Day':
          return timestamp.year == now.year &&
              timestamp.month == now.month &&
              timestamp.day == now.day;
        case 'This Week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          return !timestamp.isBefore(
                DateTime(weekStart.year, weekStart.month, weekStart.day),
              ) &&
              !timestamp.isAfter(
                DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59),
              );
        case 'This Month':
          return timestamp.year == now.year && timestamp.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  DateTime? _parseTimestamp(Map<String, dynamic> log) {
    final value = log['timestamp'] ?? log['created_at'] ?? log['date'];
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  double _parseAmount(Map<String, dynamic> log) {
    final amountValue = log['amount'] ?? log['value'] ?? log['weight'];
    if (amountValue is num) return amountValue.toDouble();
    if (amountValue is String) {
      return double.tryParse(amountValue) ?? 0;
    }
    return 0;
  }

  List<BarChartGroupData> buildTrendBars(List<DateTime> dates) {
    return List.generate(dates.length, (index) {
      final date = dates[index];
      final value = trendTotals[date] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: Colors.teal,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget buildTrendChart() {
    final dates = trendTotals.keys.toList();
    if (dates.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No trend data for this range')),
      );
    }

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: buildTrendBars(dates),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: const Text(
                  'Date',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
              axisNameSize: 24,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dates.length) {
                    return const SizedBox.shrink();
                  }
                  final date = dates[index];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${date.month}/${date.day}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: const Text(
                  'Waste (kg)',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
              axisNameSize: 28,
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  List<PieChartSectionData> buildSections() {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
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
          fontWeight: FontWeight.bold,
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

    if (wasteLogs.isEmpty) {
      return const Center(child: Text("No waste data yet"));
    }

    // Calculate total waste and motivational metrics
    double totalWaste = categoryTotals.values.fold(0, (sum, amount) => sum + amount);
    double carbonOffset = totalWaste * 2.5; // Example: 2.5 kg CO2 per kg waste recycled
    int treesEquivalent = (carbonOffset / 20).round(); // Example: 20 kg CO2 per tree

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Waste Analytics",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  value: selectedRange,
                  items: rangeOptions.map((range) {
                    return DropdownMenuItem(
                      value: range,
                      child: Text(range),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRange = value!;
                    });
                    updateAnalytics();
                  },
                  decoration: const InputDecoration(
                    labelText: 'View Range',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Track your progress and see the impact!",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Motivational Summary Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFFE8F5E8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.insights, size: 48, color: Color(0xFF4CAF50)),
                  const SizedBox(height: 8),
                  Text(
                    "You've logged ${totalWaste.toStringAsFixed(1)} kg of waste!",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "That's equivalent to offsetting ${carbonOffset.toStringAsFixed(1)} kg of CO₂, saving $treesEquivalent trees.",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Trend',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 10),
          buildTrendChart(),
          const SizedBox(height: 20),
          const Text(
            "Waste Breakdown",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),

          const SizedBox(height: 10),
          ...categoryTotals.entries.map((entry) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFF4CAF50)),
                title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: Text(
                  entry.value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
