import 'package:supabase_flutter/supabase_flutter.dart';

class LogService {
  static final _client = Supabase.instance.client;

  /// Save workout to Supabase
  static Future<void> logWorkout({
    required String exercise,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final duration = endTime.difference(startTime);
    final formattedDuration =
        '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:00';

    await _client.from('workout_logs').insert({
      'user_id': userId,
      'detail': exercise,
      'created_at': startTime.toIso8601String(),
      'duration': formattedDuration,
    });
  }

  /// Get workout logs
  static Future<List<Map<String, dynamic>>> getUserLogs() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('workout_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (response is List) {
      return response.map<Map<String, dynamic>>((entry) {
        return {
          'exercise': entry['detail'] ?? '',
          'created_at': entry['created_at'],
          'duration_minutes': _parseTimeToMinutes(entry['duration']),
        };
      }).toList();
    }

    return [];
  }

  static int _parseTimeToMinutes(String? timeString) {
    if (timeString == null || !timeString.contains(':')) return 0;
    final parts = timeString.split(':').map(int.parse).toList();
    return parts[0] * 60 + parts[1];
  }

  /// Delete workout log by created_at
  static Future<void> deleteLog(String createdAt) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('workout_logs')
        .delete()
        .eq('user_id', userId)
        .eq('created_at', createdAt);
  }
}
