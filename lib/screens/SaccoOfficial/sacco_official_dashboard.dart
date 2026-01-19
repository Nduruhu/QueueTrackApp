import 'package:flutter/material.dart';

import 'package:queuetrack/Database/stage_marshal.dart';
import 'package:queuetrack/pdf_logs/get_pdf_data.dart';
import 'package:queuetrack/screens/SaccoOfficial/register_stage_marshal.dart';
import 'package:queuetrack/screens/SaccoOfficial/view_departed_logs.dart';
import '../dashboard_helper.dart';

class SaccoOfficialDashboard extends StatelessWidget {
  const SaccoOfficialDashboard({super.key});

  final String stageId = 'main_stage';

  // -------------------- UTILITIES --------------------

  // -------------------- ACTIVE QUEUE --------------------
  void _viewActiveQueue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Active Queue")),
          body: StreamBuilder(
            stream: StageMarshal().fetchApprovedQueue(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: Text("No active vehicles in queue"));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error : ${snapshot.error.toString()}'),
                );
              }

              final docs = snapshot.data! as List;
              if (docs.isEmpty) {
                return Center(child: Text('No queue data'));
              }
              print('docs is :$docs');
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(index.toString()),
                      ),
                      title: Text(
                        data['vehicleId'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "date : ${data['queue_date'].toString().split('T')[0]}\ntime : ${data['queue_date'].toString().split('T')[1].split('.')[0]}",
                      ),
                      trailing: Icon(Icons.person),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // -------------------- DASHBOARD --------------------
  @override
  Widget build(BuildContext context) =>
      buildDashboard('Sacco Official Dashboard', [
        {
          'title': 'View Active Queue',
          'icon': Icons.queue,
          'color': Colors.teal,
          'onTap': (ctx) => _viewActiveQueue(ctx),
        },
        {
          'title': 'View Departed Logs',
          'icon': Icons.history,
          'color': Colors.blue,
          'onTap': (ctx) => Navigator.push(
            ctx,
            MaterialPageRoute(builder: (ctx) => ViewDepartedLogs()),
          ),
        },
        {
          'title': 'Download / Email PDF Report',
          'icon': Icons.picture_as_pdf,
          'color': Colors.redAccent,
          'onTap': (ctx) => GetPdfData().createPdfDocument(
            pdfName: 'QueueTrackReport',
            context: ctx,
          ),
        },
        {
          'title': 'Register Stage Marshal',
          'icon': Icons.directions_car,
          'color': Colors.purple,
          'onTap': (ctx) => Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => RegisterStageMarshal()),
          ),
        },
      ], context);
}
