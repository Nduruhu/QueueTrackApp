import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:queuetrack/AI/queue_analysis.dart';
import 'package:queuetrack/Database/driver.dart';
import 'package:queuetrack/screens/Driver/maps_view.dart';
import '../dashboard_helper.dart';
import '../view_queue_status.dart';

class DriverDashboard extends StatelessWidget {
  DriverDashboard({super.key});

  late final double latt,long;
  final TextEditingController vehicleNumberController = TextEditingController();

  Future _checkInUi(BuildContext context) {
    return showDialog(context: context,
        builder:(context){
      return AlertDialog(
        content: TextFormField(
          textCapitalization: TextCapitalization.characters,
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
        ),
      );
        }
    );
  }


  Future openGoogleMaps() async {
    try {
      final LocationPermission hasPermission =
      await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied ||
          hasPermission == LocationPermission.deniedForever) {
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: 'Cant Proceed without permission');
          return null;
        }
        return null;
      }
      //position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
      );
      latt = position.latitude;
      long = position.longitude;
      return [latt,long];
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
      return null;
    }
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
      'title': 'Queue Analysis',
      'icon': Icons.data_exploration,
      'color': Colors.blue,
      'onTap': (ctx) {
        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => QueueAnalysis()),
        );
      },
    },
    {
      'title': 'Maps View',
      'icon': Icons.map_outlined,
      'color': Colors.yellow[700],
      'onTap': (ctx)async {
        final List coordinates=await openGoogleMaps();
        if(coordinates.isEmpty){
          Fluttertoast.showToast(msg: 'Could not fetch location.Enable permissions');
          return;
        }else{
        Navigator.push(ctx,MaterialPageRoute(builder: (ctx)=>MapsView(lat:coordinates[0] ,lng: coordinates[1], )));
        }
      },
    },
    {
      'title': 'Log Out',
      'icon': Icons.logout,
      'color': Colors.red,
      'onTap': (ctx) async {
        await OneSignal.logout();
        Navigator.popUntil(context, ModalRoute.withName('/roleselection'));
      },
    },
  ], context);
}
