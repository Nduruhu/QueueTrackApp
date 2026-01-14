import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Queue {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> getQueue() async {
    try {
      final response = await supabase
          .from('QUEUE')
          .select('*')
          .order('queue_date', ascending: true);

      print('Fetched queue: $response');

      return response as List<dynamic>;
    } on PostgrestException catch (dbError) {
      Fluttertoast.showToast(msg: dbError.message);
      return [];
    } on TypeError catch (tError) {
      print("Type Error: ${tError.toString()}");
      Fluttertoast.showToast(msg: tError.toString());
      return [];
    } catch (e) {
      print("Unexpected error: $e");
      Fluttertoast.showToast(msg: 'Unexpected error occurred');
      return [];
    }
  }
}
