import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StageMarshal {
  final supabase = Supabase.instance.client;
  Future signIn({required String email, required int id}) async {
    try {
      final response = await supabase
          .from('STAGE-MARSHAL')
          .select('*')
          .eq('nationalId', id)
          .maybeSingle();
      if (response != null && response.containsKey('nationalId')) {
        return true;
      } else {
        return false;
      }
    } on PostgrestException catch (dbError) {
      Fluttertoast.showToast(msg: dbError.message);
      return false;
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
      return false;
    }
  }

  //fetch data ya queue
  Stream<List<Map<String, dynamic>>> fetchQueue() {
    return supabase
        .from('QUEUE')
        .stream(primaryKey: ['queueId'])
        .order('queue_date', ascending: true)
        .map((rows) => rows);
  }

  //approve driver in queue
  Future approveDriver({required String vehicleNumber}) async {
    print('Vehicle number : $vehicleNumber');
    try {
      await supabase
          .from('QUEUE')
          .update({'approved': true})
          .eq('vehicleId', vehicleNumber);
      Fluttertoast.showToast(msg: "Driver has been approved ");
    } on PostgrestException catch (fError) {
      Fluttertoast.showToast(msg: fError.message);
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  Future departDriver({required String vehicleNumber}) async {
    try {
      await supabase
          .from('QUEUE')
          .update({'departed': true})
          .eq('vehicleId', vehicleNumber);
      Fluttertoast.showToast(msg: "Driver has been departed ");
    } on PostgrestException catch (fError) {
      Fluttertoast.showToast(msg: fError.message);
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }
}
