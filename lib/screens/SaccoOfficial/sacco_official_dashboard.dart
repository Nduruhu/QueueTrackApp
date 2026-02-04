import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queuetrack/AI/queue_analysis.dart';

import 'package:queuetrack/Database/stage_marshal.dart';
import 'package:queuetrack/pdf_logs/preview_pdf.dart';
import 'package:queuetrack/screens/SaccoOfficial/register_stage_marshal.dart';
import 'package:queuetrack/screens/SaccoOfficial/view_departed_logs.dart';
import '../dashboard_helper.dart';

class SaccoOfficialDashboard extends StatelessWidget {
  const SaccoOfficialDashboard({super.key});

  // -------------------- ACTIVE QUEUE (Modernized UI) --------------------
  void _viewActiveQueue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text("Active Queue", style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue.shade900,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: StreamBuilder(
            stream: StageMarshal().fetchApprovedQueue(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.queue_music, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text("No active vehicles in queue", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final docs = snapshot.data! as List;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index];
                  // Modern Card Design for Queue Items
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            color: Colors.teal.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(
                        data['vehicleId'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          _formatDate(data['queue_date']),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper to format date safely
  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "Unknown Date";
    try {
      final parts = dateStr.toString().split('T');
      final date = parts[0];
      final time = parts.length > 1 ? parts[1].split('.')[0] : '';
      return "$date • $time";
    } catch (e) {
      return dateStr.toString();
    }
  }

  // -------------------- MENU ITEM WIDGET --------------------
  Widget _buildDashboardCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- DASHBOARD BUILD --------------------
  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // 1. Header Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.3, // 30% Height
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sacco Official ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Sacco Official Dashboard",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // Top Right Action Buttons
                        Row(
                          children: [

                            // Log Out Button with Text Below
                            InkWell(
                              onTap: () => Navigator.popUntil(context, ModalRoute.withName('/roleselection')),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Adjusted padding
                                decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withValues(alpha: 0.5))
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Takes only minimum space needed
                                  children: const [
                                    Icon(
                                        Icons.logout_rounded,
                                        color: Colors.white,
                                        size: 20 // Slightly smaller to make room for text
                                    ),
                                    SizedBox(height: 2), // Small gap
                                    Text(
                                      "Log Out",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10, // Small font to fit the header style
                                          fontWeight: FontWeight.w600
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. White Content Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.22,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA), // Very light grey background
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
                child: GridView.count(
                  padding: const EdgeInsets.all(24),
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildDashboardCard(
                      context,
                      title: 'Queue Status',
                      icon: Icons.queue_rounded,
                      color: Colors.blueAccent,
                      onTap: () => _viewActiveQueue(context),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Departed Logs',
                      icon: Icons.history_rounded,
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => ViewDepartedLogs()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Register Marshal',
                      icon: Icons.person_add_alt_1_rounded,
                      color: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => RegisterStageMarshal()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Analytics',
                      icon: Icons.insights_rounded,
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => QueueAnalysis()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Reports (PDF)',
                      icon: Icons.picture_as_pdf_rounded,
                      color: Colors.redAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => CreatePdf()),
                      ),
                    ),
                    // Removed Log Out card from here
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}