import 'package:flutter/material.dart';
import 'package:queuetrack/screens/MatatuOwner/my_vehicle_logs_screen.dart';
import 'package:queuetrack/screens/MatatuOwner/track_trip_frequency.dart';
import '../dashboard_helper.dart';
import 'assign_vehicle_screen.dart';

class MatatuOwnerDashboard extends StatelessWidget {
  const MatatuOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) =>
      buildDashboard('Matatu Owner Dashboard', [
        {
          'title': 'View Logs',
          'icon': Icons.history,
          'color': Colors.orange,
          'onTap': (ctx) => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => MyVehicleLogsScreen()),
          ),
        },

        {
          'title': 'Register / Assign Vehicle',
          'icon': Icons.directions_bus,
          'color': Colors.teal,
          'onTap': (ctx) => Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => const AssignVehicleScreen()),
          ),
        },
      ], context);
}
