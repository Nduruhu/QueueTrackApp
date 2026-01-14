import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Driver extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  late final int currentUserId;

  Future addDriver({
    required String name,
    required String email,
    required String vehicleId,
    required int nationalId,
  }) async {
    try {
      await supabase.from('DRIVER').insert({
        'nationalId': nationalId,
        'vehicleId': vehicleId,
        'email': email,
        'name': name,
      });
      Fluttertoast.showToast(msg: 'Driver assigned successfully');
    } on PostgrestException catch (dbError) {
      Fluttertoast.showToast(msg: 'Error : ${dbError.message}');
    } catch (anyOtherError) {
      Fluttertoast.showToast(msg: 'Type Error: ${anyOtherError.toString()}');
    }
  }

  Future signInDriver({required String email, required int id}) async {
    try {
      final response = await supabase
          .from('DRIVER')
          .select('*')
          .eq('nationalId', id)
          .eq('email', email)
          .maybeSingle();
      if (response!['nationalId'] != null && response['nationalId'] == id) {
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
    } on PostgrestException {
      Fluttertoast.showToast(msg: 'Vehicle already requested check in');
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  Future getDriverInfo() async {
    Fluttertoast.showToast(msg: 'current id : $currentUserId');
    return supabase
        .from('DRIVER')
        .select('*')
        .eq('nationalId', currentUserId)
        .maybeSingle();
  }
}
