import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:queuetrack/AI/data_calculations.dart';

class QueueAnalysis extends StatefulWidget {
  const QueueAnalysis({super.key});

  @override
  State<QueueAnalysis> createState() => _QueueAnalysisState();
}

class _QueueAnalysisState extends State<QueueAnalysis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Analysis'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<int, int>>(
        future: DataCalculations().graphData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final Map<int, int> hourCounts = snapshot.data!;

          if (hourCounts.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final sortedHours = hourCounts.keys.toList()..sort();

          final List<FlSpot> spots = sortedHours
              .map((hour) =>
              FlSpot(hour.toDouble(), hourCounts[hour]!.toDouble()))
              .toList();

          final maxY =
          spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 🔹 TOP TITLE (OPTIONAL)
                const Text(
                  'Departures Per Hour',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: Row(
                    children: [
                      // 🔹 Y AXIS LABEL
                      RotatedBox(
                        quarterTurns: 3,
                        child: const Text(
                          'Number of Departures',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 🔹 CHART
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            minX: sortedHours.first.toDouble(),
                            maxX: sortedHours.last.toDouble(),
                            minY: 0,
                            maxY: maxY + 1,
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final hour = value.toInt();
                                    return Padding(
                                      padding:
                                      const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        (int.tryParse(hour.toString().padLeft(2, '0'))!-3).toString(),
                                        style:
                                        const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 30,
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles:
                                SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles:
                                SideTitles(showTitles: false),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                belowBarData:
                                BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 🔹 X AXIS LABEL
                const Text(
                  'Departure Time (24-Hour-Clock)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
