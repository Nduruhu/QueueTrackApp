
import 'package:flutter/material.dart';
import 'package:queuetrack/Database/queue.dart';

class ViewQueueStatus extends StatelessWidget {
  const ViewQueueStatus({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Queue Status")),
      body: FutureBuilder(
        future: Queue().getQueue(),
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
          final drivers = snapshot.data!;

          return ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              print("Driver : $driver");
              return Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Text(index.toString()),
                      title: Text(
                        "${driver['vehicleId']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Departed : ${driver['departed']}'),
                      trailing: Text('date : ${driver['queue_date']}'),
                    ),
                    ListTile(
                      subtitle: Text(
                        ' Approved : ${driver['approved'].toString()}',
                      ),
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
