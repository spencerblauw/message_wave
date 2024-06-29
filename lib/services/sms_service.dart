import 'package:flutter_sms/flutter_sms.dart';
import '../models/contact.dart';

Future<void> sendPersonalizedMessages(List<Contact> contacts) async {
  for (var contact in contacts) {
    final message = 'Hello ${contact.name}, your personalized message here.';
    String result = await sendSMSFunction(message, [contact.phoneNumber]);
    print(result); // Use a proper logging framework in production
  }
}

Future<String> sendSMSFunction(String message, List<String> recipients) async {
  String result = await sendSMS(
    message: message,
    recipients: recipients,
  ).catchError((onError) {
    print(onError); // Use a proper logging framework in production
    return 'Failed to send SMS.';
  });

  return result;
}
