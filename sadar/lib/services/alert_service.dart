import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

Future<void> sendEmergencySMS(
  List<String> contacts,
  String location,
  String videoUrl,
) async {

  String message = '''
🚨 ACCIDENT ALERT

Possible accident detected.

Location:
$location

Video:
$videoUrl
''';

  try {
    await sendSMS(
      message: message,
      recipients: contacts,
    );
  } catch (e) {
    debugPrint("SMS failed: $e");
  }
}