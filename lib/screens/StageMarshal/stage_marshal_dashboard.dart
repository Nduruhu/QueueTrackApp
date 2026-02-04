import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:queuetrack/AI/queue_analysis.dart';
import 'package:queuetrack/Database/stage_marshal.dart';

class StageMarshalDashboard extends StatefulWidget {
  const StageMarshalDashboard({super.key});

  @override
  State<StageMarshalDashboard> createState() => _StageMarshalDashboardState();
}

class _StageMarshalDashboardState extends State<StageMarshalDashboard> {
  int currentIndex = 0;

  // --- 1. REQUESTS TAB (RAW QUEUE) ---
  Widget buildRawQueue(BuildContext context) {
    return StreamBuilder(
      stream: StageMarshal().fetchRawQueue(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter: Only show requests that haven't departed yet
        final allData = snapshot.data as List? ?? [];
        final docs = allData.where((doc) => doc['departed'] != true).toList();

        if (docs.isEmpty) {
          return _buildEmptyState("No pending requests", Icons.check_circle_outline);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      // Numbering starts from 1
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      '${doc['vehicleId']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Requested: ${doc['queue_date'].toString().split('.')[0]}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text("Approve Driver", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: doc['approved'] == false
                            ? () async {
                          try {
                            await StageMarshal().approveDriver(
                              index: int.tryParse(doc['queueId'].toString())!,
                              vehicleNumber: doc['vehicleId'],
                              time: doc['queue_date'].toString(),
                            );
                            setState(() {});
                          } catch (err) {
                            Fluttertoast.showToast(msg: err.toString());
                          }
                        }
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- 2. STATUS TAB (APPROVED QUEUE) ---
  Widget buildApprovedQueue(BuildContext context) {
    return StreamBuilder(
      stream: StageMarshal().fetchApprovedQueue(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allData = snapshot.data as List? ?? [];

        // -----------------------------------------------------------
        // FIX: Pre-filter the list so numbering is sequential (1, 2, 3...)
        // -----------------------------------------------------------
        final approvedDocs = allData.where((doc) => doc['approved'] == true).toList();

        if (approvedDocs.isEmpty) {
          return _buildEmptyState("No active queue", Icons.queue_music);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: approvedDocs.length,
          itemBuilder: (context, index) {
            final row = approvedDocs[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    spreadRadius: 2,
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
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  // Numbering now uses the index of the filtered list + 1
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                title: Text(
                  row['vehicleId'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: const Text("Status: In Queue (Approved)"),
                trailing: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: (row['departed'] == false)
                        ? () {
                      StageMarshal().departDriver(
                        vehicleNumber: row['vehicleId'],
                        index: row['queueId'],
                        time: row['queue_date'].toString(),
                      );
                      setState(() {});
                    }
                        : null,
                    child: const Text('Depart'),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 3. SIGN OUT TAB ---
  Widget signOut(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text(
            "Ready to leave?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/roleselection'));
              },
              child: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _buildStatusChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green.shade800 : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pageContent = [
      buildRawQueue(context),
      buildApprovedQueue(context),
      QueueAnalysis(),
      signOut(context)
    ];

    final List<String> titles = [
      "Marshal Requests",
      "Queue Status",
      "Analysis",
      "Sign Out"
    ];

    final primaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          titles[currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // White Sheet Container
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
                child: pageContent[currentIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in_rounded), label: 'Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Queue'),
            BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Analysis'),
            BottomNavigationBarItem(icon: Icon(Icons.logout_rounded), label: 'Log Out'),
          ],
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}