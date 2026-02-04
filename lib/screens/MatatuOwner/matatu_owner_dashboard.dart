import 'package:flutter/material.dart';
import 'package:queuetrack/Database/matatu_owner.dart';
import 'assign_vehicle_screen.dart';

class MatatuOwnerDashboard extends StatelessWidget {
  const MatatuOwnerDashboard({super.key});

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No active vehicles found",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

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
            height: MediaQuery.of(context).size.height * 0.3,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Matatu Owner",
                              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Fleet Performance",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.popUntil(context, ModalRoute.withName('/roleselection')),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.5))
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                                SizedBox(height: 2),
                                Text("Log Out", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
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
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Vehicle Trip Summary",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                          ),
                          Icon(Icons.bar_chart_rounded, color: Colors.blue.shade900),
                        ],
                      ),
                    ),

                    // ----------------------------------------------------
                    // THE AGGREGATION LOGIC IS HERE
                    // ----------------------------------------------------
                    Expanded(
                      child: StreamBuilder(
                        stream: MatatuOwner().getVehicleLogs(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                            return _buildEmptyState();
                          }

                          final logs = snapshot.data as List;

                          // 1. Calculate Trips per Vehicle
                          Map<String, int> tripCounts = {};
                          Map<String, String> lastDriver = {};

                          for (var log in logs) {
                            String vId = log['vehicleId'] ?? 'Unknown';
                            String driverName = log['name'] ?? 'Unknown';

                            // Increment count
                            if (!tripCounts.containsKey(vId)) {
                              tripCounts[vId] = 0;
                            }
                            tripCounts[vId] = tripCounts[vId]! + 1;

                            // Store last known driver
                            lastDriver[vId] = driverName;
                          }

                          // Convert map keys to a list for the ListView
                          final uniqueVehicles = tripCounts.keys.toList();

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: uniqueVehicles.length,
                            itemBuilder: (context, index) {
                              String vehicleId = uniqueVehicles[index];
                              int count = tripCounts[vehicleId]!;
                              String driver = lastDriver[vehicleId]!;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Trip Count Badge (Left Side)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.blue.shade100),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              count.toString(),
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade900
                                              ),
                                            ),
                                            const Text(
                                              "Trips",
                                              style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Vehicle Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vehicleId,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Driver: $driver",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Arrow Icon
                                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating Button
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Material(
              color: Colors.transparent,
              elevation: 10,
              shadowColor: Colors.blue.shade900.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AssignVehicleScreen()),
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        "Register / Assign Vehicle",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}