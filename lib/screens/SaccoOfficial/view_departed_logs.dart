import 'package:flutter/material.dart';
import 'package:queuetrack/Database/sacco_official.dart';

class ViewDepartedLogs extends StatefulWidget {
  const ViewDepartedLogs({super.key});

  @override
  State<ViewDepartedLogs> createState() => _ViewDepartedLogsState();
}

class _ViewDepartedLogsState extends State<ViewDepartedLogs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Departed Vehicles Log")),
      body: StreamBuilder(
        stream: SaccoOfficial().viewDepartedLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading departed logs."));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No departed records yet"));
          }

          final docs = snapshot.data! as List;
          if (docs.isEmpty) {
            return Center(child: Text('No departed logs '));
          }
          print("departed data : ${docs}");
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              print("departed data : $data");

              return Card(
                margin: const EdgeInsets.all(8),
                color: Colors.blueGrey.shade50,
                child: Column(
                  children: [
                    ListTile(
                      leading: Text(index.toString()),
                      title: Text(data['vehicleId']),
                      subtitle: Text(data['queue_date']),
                      trailing: Icon(Icons.person),
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
