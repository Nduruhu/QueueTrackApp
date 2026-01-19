import 'package:flutter/material.dart';
import 'package:queuetrack/Database/driver.dart';
import 'package:queuetrack/screens/Driver/maps_view.dart';
import '../dashboard_helper.dart';
import '../view_queue_status.dart';
import 'driver_profile_screen.dart';

class DriverDashboard extends StatelessWidget {
  DriverDashboard({super.key});
  final TextEditingController vehicleNumberController = TextEditingController();

  Future _checkInUi(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return TextFormField(
          controller: vehicleNumberController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            hintText: 'Enter vehicle number',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a vehicle number';
            }
            return null;
          },
          onFieldSubmitted: (value) {
            Driver().driverCheckIn(vehicleNumber: value);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => buildDashboard('Driver Dashboard', [
    {
      'title': 'Check-in Stage',
      'icon': Icons.check_circle,
      'color': Colors.blue,
      'onTap': (ctx) => _checkInUi(context),
    },
    {
      'title': 'View Queue Status',
      'icon': Icons.queue,
      'color': Colors.green,
      'onTap': (ctx) {
        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => ViewQueueStatus()),
        );
      },
    },
    {
      'title': 'My Trip History',
      'icon': Icons.history,
      'color': Colors.orange,
      'onTap': (ctx) => (ctx),
    },
    {
      'title': 'Profile',
      'icon': Icons.person,
      'color': Colors.purple,
      'onTap': (ctx) {
        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const DriverProfileScreen()),
        );
      },
    },
    {
      'title': 'Maps View',
      'icon': Icons.map_outlined,
      'color': Colors.lightBlue,
      'onTap': (ctx) {
        MapsViewState().openGoogleMaps();
      },
    },
  ], context);
}
