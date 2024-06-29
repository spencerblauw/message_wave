import 'package:flutter_sms/flutter_sms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../models/contact.dart';

final Logger _logger = Logger('SMSService');

Future<void> sendPersonalizedMessages(
    List<Contact> contacts, String baseMessage) async {
  for (Contact contact in contacts) {
    String message = 'Hello ${contact.name.split(' ').first}, $baseMessage';
    List<String> recipients = [contact.phoneNumber];

    try {
      String result = await sendSMS(message: message, recipients: recipients);
      print('SMS sent: $result');
      _saveMessageHistory('Sent to ${contact.name}: $message');
    } catch (error) {
      print('Failed to send SMS to ${contact.name}: $error');
      _saveFailedMessage('Failed to send to ${contact.name}');
    }
  }
}

Future<void> _saveMessageHistory(String message) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> sentMessages = prefs.getStringList('sentMessages') ?? [];
  sentMessages.add(message);
  await prefs.setStringList('sentMessages', sentMessages);
}

Future<void> _saveFailedMessage(String message) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> failedMessages = prefs.getStringList('failedMessages') ?? [];
  failedMessages.add(message);
  await prefs.setStringList('failedMessages', failedMessages);
}
