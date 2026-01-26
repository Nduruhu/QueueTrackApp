import 'package:supabase_flutter/supabase_flutter.dart';

class DataCalculations {
  final supabase = Supabase.instance.client;

  /// Returns: {hour (0–23) : count}
  Future<Map<int, int>> graphData() async {
    try {
      final List queue = await supabase
          .from('QUEUE')
          .select('departed_date')
          .eq('departed', true);

      final Map<int, int> hourCounts = {};

      for (final row in queue) {
        final departedDate = row['departed_date'];
        if (departedDate == null) continue;

        // Parse to DateTime safely
        final dateTime = DateTime.parse(departedDate).toLocal();
        final hour = dateTime.hour;

        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }

      return hourCounts;
    } catch (e) {
      return {};
    }
  }
}
