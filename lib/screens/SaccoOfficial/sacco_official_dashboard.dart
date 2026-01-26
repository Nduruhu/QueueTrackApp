import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queuetrack/AI/queue_analysis.dart';

import 'package:queuetrack/Database/stage_marshal.dart';
import 'package:queuetrack/pdf_logs/preview_pdf.dart';
import 'package:queuetrack/screens/SaccoOfficial/register_stage_marshal.dart';
import 'package:queuetrack/screens/SaccoOfficial/view_departed_logs.dart';
import '../dashboard_helper.dart';

class SaccoOfficialDashboard extends StatelessWidget {
  const SaccoOfficialDashboard({super.key});

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
  Widget build(BuildContext context) =>buildDashboard(
    'Sacco Official Dashboard'
  , [
    {
      'title': 'View Queue Status ',
      'icon': Icons.queue,
      'color': Colors.lightBlue,
      'onTap': (ctx) => _viewActiveQueue(ctx),
    },
    {
      'title': 'View Departed Queue ',
      'icon': Icons.arrow_circle_left,
      'color': Colors.orange,
      'onTap': (ctx) => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx)=>ViewDepartedLogs() ),
      ),
    },{
      'title': 'Register Stage Marshal',
      'icon': Icons.app_registration_outlined,
      'color': Colors.lightBlue,
      'onTap': (ctx) => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx)=> RegisterStageMarshal()),
      ),
    },{
      'title': 'Queue Analysis ',
      'icon': Icons.data_exploration,
      'color': Colors.orange[300],
      'onTap': (ctx) => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx)=>QueueAnalysis()),
      ),
    },{
      'title': 'Generate and Download Pdf ',
      'icon': Icons.picture_as_pdf,
      'color': Colors.lightBlue,
      'onTap': (ctx) => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx)=> CreatePdf()),
      ),
    },
    {
      'title':'Log Out',
      'icon':Icons.logout,
      'color':Colors.red,
      'onTap':(ctx) => Navigator.popUntil(context,ModalRoute.withName('/roleselection'))
    }
  ], context);
      
}
