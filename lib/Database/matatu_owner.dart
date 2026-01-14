import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatatuOwner {
  final supabase = Supabase.instance.client;

  Future signUp({
    required String fullName,
    required int id,
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signUp(email: email, password: password);
      await supabase.from('MATATU-OWNER').insert({
        'userId': supabase.auth.currentUser!.id,
        'nationalId': id,
        'name': fullName,
        'email': email,
      });
      Fluttertoast.showToast(msg: 'Successful');
    } on AuthApiException catch (authError) {
      Fluttertoast.showToast(
        msg: 'Authentication Error : ${authError.message}',
      );
    } catch (anyOtherError) {
      Fluttertoast.showToast(msg: anyOtherError.toString());
    }
  }

  Future signIn({required String email, required String password}) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      Fluttertoast.showToast(msg: 'Login Success ');
      return true;
    } on AuthApiException catch (authError) {
      Fluttertoast.showToast(msg: authError.message);
      return false;
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
      return false;
    }
  }
}
