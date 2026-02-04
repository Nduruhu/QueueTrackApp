import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:queuetrack/AI/data_calculations.dart';

class QueueAnalysis extends StatefulWidget {
  const QueueAnalysis({super.key});

  @override
  State<QueueAnalysis> createState() => _QueueAnalysisState();
}

class _QueueAnalysisState extends State<QueueAnalysis> {
  final List<Color> gradientColors = [
    Colors.blue.shade800,
    Colors.blue.shade400,
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Live Queue Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: FutureBuilder<Map<int, int>>(
                  future: DataCalculations().graphData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 1. PROCESS DATA
                    final Map<int, int> rawData = snapshot.data!;
                    final Map<int, int> fullDayData = {};
                    int maxCount = 0;
                    int peakHour = 0;
                    int totalDepartures = 0;

                    for (int i = 0; i < 24; i++) {
                      int count = rawData[i] ?? 0;
                      fullDayData[i] = count;
                      totalDepartures += count;
                      if (count > maxCount) {
                        maxCount = count;
                        peakHour = i;
                      }
                    }

                    final List<FlSpot> spots = [];
                    fullDayData.forEach((hour, count) {
                      spots.add(FlSpot(hour.toDouble(), count.toDouble()));
                    });

                    // 2. GENERATE INSIGHTS
                    final insights = _generateRuleBasedInsights(fullDayData, peakHour, maxCount);

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            _buildSummaryCard(totalDepartures, peakHour, maxCount),
                            const SizedBox(height: 20),
                            _buildInsightsCard(insights),
                            const SizedBox(height: 20),

                            // 🔹 GRAPH CARD
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "24-Hour Departures",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 20),

                                  // 🔹 CHART LAYOUT
                                  SizedBox(
                                    height: 350,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // A. FIXED Y-AXIS LABEL & NUMBERS
                                        // A. FIXED Y-AXIS LABEL & NUMBERS
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(bottom: 8.0),
                                              child: Text(
                                                "Departures (Count)",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: List.generate(6, (index) {
                                                  final value = (maxCount + 2) * (5 - index) / 5;
                                                  return Text(
                                                    value.toInt().toString(),
                                                    style: TextStyle(
                                                        color: Colors.grey.shade500,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),


                                        // B. SCROLLABLE CHART AREA
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: SizedBox(
                                              width: 1000,
                                              child: LineChart(
                                                LineChartData(
                                                  minX: 0,
                                                  maxX: 23,
                                                  minY: 0,
                                                  maxY: (maxCount + 2).toDouble(),
                                                  gridData: FlGridData(
                                                    show: true,
                                                    drawVerticalLine: true,
                                                    horizontalInterval: 1,
                                                    getDrawingHorizontalLine: (value) => FlLine(
                                                      color: Colors.grey.shade100,
                                                      strokeWidth: 1,
                                                    ),
                                                    getDrawingVerticalLine: (value) => FlLine(
                                                      color: Colors.grey.shade100,
                                                      strokeWidth: 1,
                                                    ),
                                                  ),
                                                  borderData: FlBorderData(show: false),
                                                  titlesData: FlTitlesData(
                                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                    bottomTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        interval: 1,
                                                        getTitlesWidget: (value, meta) {
                                                          return Padding(
                                                            padding: const EdgeInsets.only(top: 8.0),
                                                            child: Text(
                                                              "${value.toInt().toString().padLeft(2, '0')}:00",
                                                              style: TextStyle(
                                                                  color: Colors.grey.shade600,
                                                                  fontSize: 10,
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  lineBarsData: [
                                                    LineChartBarData(
                                                      spots: spots,
                                                      isCurved: true,
                                                      preventCurveOverShooting: true,
                                                      gradient: LinearGradient(colors: gradientColors),
                                                      barWidth: 3,
                                                      isStrokeCapRound: true,
                                                      dotData: FlDotData(
                                                        show: true,
                                                        getDotPainter: (spot, percent, bar, index) {
                                                          if (spot.x == peakHour && maxCount > 0) {
                                                            return FlDotCirclePainter(
                                                              radius: 6,
                                                              color: Colors.orange,
                                                              strokeWidth: 2,
                                                              strokeColor: Colors.white,
                                                            );
                                                          }
                                                          return FlDotCirclePainter(
                                                            radius: 3,
                                                            color: Colors.blueAccent,
                                                            strokeWidth: 0,
                                                          );
                                                        },
                                                      ),
                                                      belowBarData: BarAreaData(
                                                        show: true,
                                                        gradient: LinearGradient(
                                                          colors: gradientColors.map((c) => c.withOpacity(0.3)).toList(),
                                                          begin: Alignment.topCenter,
                                                          end: Alignment.bottomCenter,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  lineTouchData: LineTouchData(
                                                    touchTooltipData: LineTouchTooltipData(
                                                      getTooltipColor: (spot) => Colors.blueAccent,
                                                      tooltipPadding: const EdgeInsets.all(8),
                                                      tooltipMargin: 10,
                                                      getTooltipItems: (touchedSpots) {
                                                        return touchedSpots.map((spot) {
                                                          return LineTooltipItem(
                                                            '${spot.y.toInt()} Trips',
                                                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                          );
                                                        }).toList();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Time of Day (24h)",
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC HELPERS ---
  String _generateRuleBasedInsights(Map<int, int> data, int peakHour, int peakCount) {
    int total = data.values.fold(0, (a, b) => a + b);
    double avg = data.isEmpty ? 0 : total / 24;

    if (peakCount > avg * 2.0) {
      return "Significant traffic spike at ${peakHour.toString().padLeft(2, '0')}:00.";
    } else if (peakCount > avg * 1.2) {
      return "Traffic shows a mild peak at ${peakHour.toString().padLeft(2, '0')}:00.";
    } else {
      return "Traffic is consistent throughout the day.";
    }
  }

  // --- UI WIDGETS ---
  Widget _buildInsightsCard(String insights) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, size: 18, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text("System Insights", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 10),
          Text(insights, style: const TextStyle(fontSize: 14, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int total, int peakHour, int peakCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Departures", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(total.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Peak Time", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("${peakHour.toString().padLeft(2, '0')}:00", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
