import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:queuetrack/AI/queue_analysis.dart';
import 'package:queuetrack/Database/driver.dart';
import 'package:queuetrack/screens/Driver/maps_view.dart';
import '../dashboard_helper.dart';
import '../view_queue_status.dart';

class DriverDashboard extends StatelessWidget {
  DriverDashboard({super.key});

  // Logic variables
  late final double latt, long;
  final TextEditingController vehicleNumberController = TextEditingController();

  // -------------------- LOGIC METHODS (Unchanged) --------------------

  Future _checkInUi(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Driver Check-In"),
            content: TextFormField(
              textCapitalization: TextCapitalization.characters,
              controller: vehicleNumberController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Enter vehicle number',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.directions_bus),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a vehicle number';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                Driver().driverCheckIn(vehicleNumber: value.toString().trim());
                Navigator.pop(context);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (vehicleNumberController.text.isNotEmpty) {
                    Driver().driverCheckIn(vehicleNumber: vehicleNumberController.text.toString().trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text("Check In"),
              )
            ],
          );
        });
  }

  Future openGoogleMaps() async {
    try {
      final LocationPermission hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied ||
          hasPermission == LocationPermission.deniedForever) {
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: 'Cant Proceed without permission');
          return null;
        }
        return null;
      }
      //position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      latt = position.latitude;
      long = position.longitude;
      return [latt, long];
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
      return null;
    }
  }

  // -------------------- UI HELPER: DASHBOARD CARD --------------------
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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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

  // -------------------- MAIN BUILD METHOD --------------------
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Driver Panel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Welcome back, Driver",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                    // Log Out Button
                    InkWell(
                      onTap: () async {
                        await OneSignal.logout();
                        Navigator.popUntil(context, ModalRoute.withName('/roleselection'));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.5))
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                            SizedBox(height: 2),
                            Text("Log Out", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))
                          ],
                        ),
                      ),
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
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                  children: [
                    // A. Check-In
                    _buildDashboardCard(
                      context,
                      title: 'Check-in Stage',
                      icon: Icons.check_circle_rounded,
                      color: Colors.blue,
                      onTap: () => _checkInUi(context),
                    ),

                    // B. Queue Status
                    _buildDashboardCard(
                      context,
                      title: 'View Queue',
                      icon: Icons.list_alt_rounded,
                      color: Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ViewQueueStatus()),
                      ),
                    ),

                    // C. Analysis
                    _buildDashboardCard(
                      context,
                      title: 'Queue Analysis',
                      icon: Icons.insights_rounded,
                      color: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => QueueAnalysis()),
                      ),
                    ),

                    // D. Maps
                    _buildDashboardCard(
                      context,
                      title: 'Maps View',
                      icon: Icons.map_rounded,
                      color: Colors.orange,
                      onTap: () async {
                        final List? coordinates = await openGoogleMaps();
                        if (coordinates == null || coordinates.isEmpty) {
                          Fluttertoast.showToast(msg: 'Could not fetch location. Enable permissions');
                          return;
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => MapsView(
                                lat: coordinates[0],
                                lng: coordinates[1],
                              ),
                            ),
                          );
                        }
                      },
                    ),
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
