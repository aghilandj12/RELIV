import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart'; // <-- for status bar style

class AdminInsightsPage extends StatefulWidget {
  const AdminInsightsPage({super.key});

  @override
  State<AdminInsightsPage> createState() => _AdminInsightsPageState();
}

class _AdminInsightsPageState extends State<AdminInsightsPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ Make status bar teal
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.teal,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Goods Dashboard"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('goods').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final goodsDocs = snapshot.data!.docs;

          Map<String, int> itemAvailableMap = {};
          List<String> lowStockItems = [];

          for (var doc in goodsDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Unnamed';
            final available = (data['available'] ?? 0).toInt();
            final needed = (data['needed'] ?? 0).toInt();

            itemAvailableMap[name] = available;

            if (needed > 0 && ((needed - available) / needed) > 0.4) {
              lowStockItems.add("$name (Available: $available, Needed: $needed)");
            }
          }

          final barWidth = 30.0;
          final spacing = 20.0;
          final totalBarWidth = itemAvailableMap.length * (barWidth + spacing);
          final chartWidth = totalBarWidth < screenWidth ? screenWidth : totalBarWidth;

          final barChartData = itemAvailableMap.entries.map((entry) {
            return BarChartGroupData(
              x: itemAvailableMap.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: entry.value < 3 ? Colors.red : Colors.teal,
                  width: barWidth,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLowStockAlert(lowStockItems),
                const SizedBox(height: 24),
                const Text("📦 Item Stock Levels", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth,
                      child: BarChart(
                        BarChartData(
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  final keys = itemAvailableMap.keys.toList();
                                  if (index >= 0 && index < keys.length) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Transform.rotate(
                                        angle: -0.6,
                                        child: Text(keys[index], style: const TextStyle(fontSize: 11)),
                                      ),
                                    );
                                  }
                                  return const Text("");
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: true),
                          barGroups: barChartData,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLowStockAlert(List<String> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal),
        ),
        child: const Text("✅ All goods have sufficient stock."),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("⚠️ Needed Items (More than 40% shortage)",
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          for (var item in items) Text("• $item"),
        ],
      ),
    );
  }
}
