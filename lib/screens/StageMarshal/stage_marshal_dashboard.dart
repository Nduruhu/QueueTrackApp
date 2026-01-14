import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:queuetrack/Database/stage_marshal.dart';

class StageMarshalDashboard extends StatefulWidget {
  const StageMarshalDashboard({super.key});

  @override
  State<StageMarshalDashboard> createState() => _StageMarshalDashboardState();
}

class _StageMarshalDashboardState extends State<StageMarshalDashboard> {
  int currentIndex = 0;
  final List<BottomNavigationBarItem> navigationButtons = [
    BottomNavigationBarItem(icon: Icon(Icons.view_agenda), label: 'view queue'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'A'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'B'),
  ];
  late List<Widget> pages = [
    buildQueue(context),
    Center(child: Text("A")),
    Center(child: Text("B")),
  ];

  Widget buildQueue(BuildContext context) {
    return StreamBuilder(
      stream: StageMarshal().fetchQueue(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return (doc['departed'] == true)
                ? null
                : Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Text(doc['queueId'].toString()),
                          title: Text(' Car No: ${doc['vehicleId']}'),
                          subtitle: Text('Approved : ${doc['approved']}'),
                          trailing: Text(
                            ' Request date :\n${doc['queue_date'].toString()}',
                          ),
                        ),
                        ListTile(
                          leading: Text('Departed : ${doc['departed']}'),
                          trailing: TextButton(
                            onPressed: () async {
                              try {
                                await StageMarshal().approveDriver(
                                  vehicleNumber: doc['vehicleId'],
                                );
                              } catch (err) {
                                Fluttertoast.showToast(msg: err.toString());
                              }
                            },
                            child: Text('Approve'),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await StageMarshal().departDriver(
                              vehicleNumber: doc['vehicleId'],
                            );
                          },
                          child: Text('Depart'),
                        ),
                      ],
                    ),
                  );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    pages;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Stage Marshal Dashboard")),
        body: pages[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: navigationButtons,
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
