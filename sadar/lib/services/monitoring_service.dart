import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service responsible for communicating with the Flask backend
/// to start/stop accident monitoring.
class MonitoringService {
  MonitoringService._();

  /// Base URL of the Flask backend.
  ///
  /// - Android Emulator: 10.0.2.2 maps to the host machine's localhost.
  /// - Physical device on same WiFi: replace with your machine's local IP,
  ///   e.g. http://192.168.1.x:5000
  static const String _baseUrl = 'http://10.0.2.2:5000';

  /// Sends a POST request to the Flask `/start-monitoring` endpoint.
  ///
  /// [userId] is the Firebase UID of the current user, forwarded to the
  /// backend so it can fetch the correct emergency contact profile.
  ///
  /// Returns `true` on success. Throws a [MonitoringException] on failure.
  static Future<bool> startMonitoring(String userId) async {
    final uri = Uri.parse('$_baseUrl/start-monitoring');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw MonitoringException(
          body['error']?.toString() ?? 'Server returned ${response.statusCode}',
        );
      }
    } on MonitoringException {
      rethrow;
    } catch (e) {
      throw MonitoringException(
        'Could not reach the monitoring server. '
        'Make sure the Flask backend is running.\n($e)',
      );
    }
  }

  /// Sends a POST request to the Flask `/stop-monitoring` endpoint.
  ///
  /// Returns `true` on success. Throws a [MonitoringException] on failure.
  static Future<bool> stopMonitoring(String userId) async {
    final uri = Uri.parse('$_baseUrl/stop-monitoring');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw MonitoringException(
          body['error']?.toString() ?? 'Server returned ${response.statusCode}',
        );
      }
    } on MonitoringException {
      rethrow;
    } catch (e) {
      throw MonitoringException(
        'Could not reach the monitoring server. '
        'Make sure the Flask backend is running.\n($e)',
      );
    }
  }
}

/// Exception thrown when the monitoring API call fails.
class MonitoringException implements Exception {
  final String message;
  const MonitoringException(this.message);

  @override
  String toString() => 'MonitoringException: $message';
}
