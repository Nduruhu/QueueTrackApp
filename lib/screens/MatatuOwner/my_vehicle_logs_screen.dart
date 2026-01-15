import 'package:flutter/material.dart';
import 'package:queuetrack/Database/matatu_owner.dart';

class MyVehicleLogsScreen extends StatelessWidget {
  const MyVehicleLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicle Logs'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: MatatuOwner().getVehicleLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No logs found.'));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error : ${snapshot.error}'));
          }

          final logs = snapshot.data!;
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Vehicle : ${log['vehicleId']} '),
                  subtitle: Text('Driver name : ${log['name']}'),
                  trailing: Text('Driver Id : ${log['nationalId']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
