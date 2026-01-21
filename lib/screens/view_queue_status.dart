import 'package:flutter/material.dart';
import 'package:queuetrack/Database/stage_marshal.dart';

class ViewQueueStatus extends StatelessWidget {
  const ViewQueueStatus({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Queue Status")),
      body: StreamBuilder(
        stream: StageMarshal().fetchApprovedQueue(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("🚐 No drivers in the queue yet"));
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final drivers = snapshot.data! as List;
          if (drivers.isEmpty) {
            return Center(child: Text('No Approved Vehicles'));
          }
          print('Drivers: $drivers');
          return ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Text(
                        driver['queueId'].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      title: Text(
                        "${driver['vehicleId']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'date : ${driver['queue_date'].toString().split('.')[0]}',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        ' Approved : ${driver['approved'].toString()}',
                      ),
                      subtitle: Text('Departed : ${driver['departed']}'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
