import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaccoOfficial {
  final supabase = Supabase.instance.client;

  Future signUp({
    required String email,
    required String password,
    required int id,
    required String name,
  }) async {
    try {
      await supabase.auth.signUp(email: email, password: password);
      await supabase.from('SACCO-OFFICIAL').insert({
        'nationalId': id,
        'name': name,
        'email': email,
      });
      Fluttertoast.showToast(msg: 'Success');
    } on AuthApiException catch (authError) {
      Fluttertoast.showToast(msg: 'Auth Error : ${authError.message}');
    } on PostgrestException catch (dbError) {
      Fluttertoast.showToast(msg: 'Access Denied: ${dbError.toString()}');
    }
  }

  Future signIn({required String email, required String password}) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return true;
      } else {
        return false;
      }
    } on AuthApiException catch (authError) {
      Fluttertoast.showToast(msg: authError.message);
      return false;
    }
  }

  Future addStageMarshal({
    required String name,
    required String email,
    required int nationalId,
  }) async {
    try {
      final response = await supabase.from('STAGE-MARSHAL').insert({
        'nationalId': nationalId,
        'name': name,
        'email': email,
      });
      Fluttertoast.showToast(msg: 'Success');
    } on PostgrestException catch (dbError) {
      Fluttertoast.showToast(msg: dbError.message);
    } catch (anyOtherError) {
      Fluttertoast.showToast(msg: anyOtherError.toString());
    }
  }

  Stream viewDepartedLogs() {
    return supabase
        .from('QUEUE')
        .stream(primaryKey: ['queueId'])
        .eq('departed', true)
        .order('queue_date', ascending: true);
  }
}
