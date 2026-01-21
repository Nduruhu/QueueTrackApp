import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Driver extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  late final int currentUserId;

  Future signInDriver({required String vehicleId, required int id}) async {
    try {
      final response = await supabase
          .from('DRIVER')
          .select('*')
          .eq('nationalId', id)
          .eq('vehicleId', vehicleId)
          .maybeSingle();
      if (response == null) {
        Fluttertoast.showToast(msg: 'Login Failed');
        return false;
      }
      if (response['vehicleId'] == vehicleId && response['nationalId'] == id) {
        currentUserId = response['nationalId'];
        Fluttertoast.showToast(msg: 'Login Success');
        notifyListeners();
        return true;
      }
    } on PostgrestException catch (dbError) {
      Fluttertoast.showToast(msg: dbError.message);
    } catch (err) {
      Fluttertoast.showToast(msg: 'Error occured');
    }
  }

  Future driverCheckIn({required String vehicleNumber}) async {
    try {
      await supabase.from('QUEUE').insert({'vehicleId': vehicleNumber});
      Fluttertoast.showToast(msg: 'Check in Success');
    } on PostgrestException catch (dbError) {
      if (dbError.message.contains('violates')) {
        Fluttertoast.showToast(msg: 'Unregistered vehicle or Already Exists.');
      } else {
        Fluttertoast.showToast(msg: dbError.message);
      }
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  Future getDriverInfo() async {
    Fluttertoast.showToast(msg: 'current id : $currentUserId');
    final info = supabase
        .from('DRIVER')
        .select('*')
        .eq('nationalId', currentUserId)
        .maybeSingle();
    return info;
  }
}
