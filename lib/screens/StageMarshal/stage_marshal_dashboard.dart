import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:queuetrack/AI/queue_analysis.dart';
import 'package:queuetrack/Database/stage_marshal.dart';

class StageMarshalDashboard extends StatefulWidget {
  const StageMarshalDashboard({super.key});

  @override
  State<StageMarshalDashboard> createState() => _StageMarshalDashboardState();
}

class _StageMarshalDashboardState extends State<StageMarshalDashboard> {
  int currentIndex = 0;
  final List<BottomNavigationBarItem> navigationButtons = [
    BottomNavigationBarItem(icon: Icon(Icons.view_agenda), label: 'Raw Queue'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Approved Queue'),
    BottomNavigationBarItem(icon: Icon(Icons.data_exploration),label: 'Queue Analysis'),
    BottomNavigationBarItem(icon: Icon(Icons.logout),label: 'Log Out')
  ];
  late List<Widget> pages = [
    buildRawQueue(context),
    buildApprovedQueue(context),
    QueueAnalysis(),
    signOut(context)
  ];

  Widget buildRawQueue(BuildContext context) {
    return StreamBuilder(
      stream: StageMarshal().fetchRawQueue(),
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
                          subtitle: Text(
                            ' Request date : ${doc['queue_date'].toString().split('.')[0]}',
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Departed : ${doc['departed'].toString()}',
                          ),
                          subtitle: Text(
                            'Approved : ${doc['approved'].toString()}',
                          ),
                        ),

                        Row(
                          children: [
                            TextButton(
                              onPressed: doc['approved'] == false
                                  ? () async {
                                      try {
                                        await StageMarshal().approveDriver(
                                          index: int.tryParse(
                                            doc['queueId'].toString(),
                                          )!,
                                          vehicleNumber: doc['vehicleId'],
                                          time: doc['queue_date'].toString(),
                                        );
                                        setState(() {
                                          docs.removeAt(index);
                                        });
                                      } catch (err) {
                                        Fluttertoast.showToast(
                                          msg: err.toString(),
                                        );
                                      }
                                    }
                                  : null,
                              child: Text('Approve'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
          },
        );
      },
    );
  }

  Widget buildApprovedQueue(BuildContext context) {
    return StreamBuilder(
      stream: StageMarshal().fetchApprovedQueue(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Loading...'),
            ),
          );
        }
        if (snapshot.data!.isEmpty) {
          return Center(child: Text('No data for queue'));
        }
        final data = snapshot.data!;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final row = data[index];
            return (row['approved'] == true)
                ? ListTile(
                    leading: Text(row['queueId'].toString()),
                    title: Text(row['vehicleId']),
                    subtitle: Text('Departed :${row['departed'].toString()}'),
                    trailing: TextButton(
                      onPressed: (row['departed'] == false)
                          ? () {
                              StageMarshal().departDriver(
                                vehicleNumber: row['vehicleId'],
                                index: row['queueId'],
                                time: row['queue_date'].toString(),
                              );
                              setState(() {
                                data.removeAt(index);
                              });
                            }
                          : null,
                      child: Text('Depart'),
                    ),
                  )
                : null;
          },
        );
      },
    );
  }


  Widget signOut(BuildContext context){
    return Center(child:ElevatedButton(onPressed: (){
      Navigator.popUntil(context, ModalRoute.withName('/roleselection'));
    }, child: Text('Log Out')));
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
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.orange,
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
