import 'package:flutter/material.dart';
import 'package:queuetrack/Database/stage_marshal.dart';

class ViewQueueStatus extends StatelessWidget {
  const ViewQueueStatus({super.key});

  @override
  Widget build(BuildContext context) {
    // Match the primary color used in other screens
    final primaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Queue Status",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // White Content Sheet
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA), // Light grey background
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
                child: StreamBuilder(
                  stream: StageMarshal().fetchApprovedQueue(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return _buildEmptyState("🚐 No drivers in the queue yet");
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    // 1. FILTER FIRST: Get only approved drivers
                    final allDrivers = snapshot.data! as List;
                    final approvedDrivers = allDrivers.where((d) => d['approved'] == true).toList();

                    if (approvedDrivers.isEmpty) {
                      return _buildEmptyState("No Approved Vehicles");
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      // 2. Use the filtered list count
                      itemCount: approvedDrivers.length,
                      itemBuilder: (context, index) {
                        final driver = approvedDrivers[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.08),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Queue ID and Vehicle ID
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      // 3. LOGIC CHANGE: Use (index + 1) for sequential numbering
                                      child: Text(
                                        "#${index + 1}",
                                        style: TextStyle(
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "${driver['vehicleId']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Divider(height: 1),
                                ),

                                // Details: Date
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade500),
                                    const SizedBox(width: 8),
                                    Text(
                                      // Simple split logic from your code
                                      'Date: ${driver['queue_date'].toString().split('.')[0]}',
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Status Chips
                                Row(
                                  children: [
                                    // Approved Status
                                    _buildStatusChip(
                                      label: 'Approved',
                                      isActive: driver['approved'] == true,
                                      activeColor: Colors.green,
                                      icon: Icons.check_circle_outline,
                                    ),
                                    const SizedBox(width: 10),
                                    // Departed Status
                                    _buildStatusChip(
                                      label: 'Departed',
                                      isActive: driver['departed'] == true, // Assuming true/false logic
                                      activeColor: Colors.orange,
                                      icon: Icons.exit_to_app_rounded,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
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

  // --- UI Helpers ---

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool isActive,
    required Color activeColor,
    required IconData icon,
  }) {
    // If status is false, show a greyed out version or different text
    final color = isActive ? activeColor : Colors.grey;
    final text = isActive ? label : "Not $label";
    final bg = isActive ? activeColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}