import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart'; // Ensure this path is correct
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter_sms/flutter_sms.dart';

// Request SMS permissions
Future<void> _requestSmsPermission() async {
  var status = await Permission.sms.status;
  if (!status.isGranted) {
    await Permission.sms.request();
  }
}

class SmsSender {
  static const platform = MethodChannel('com.example.message_wave/sms');

  Future<void> sendSms(String phoneNumber, String message) async {
    if (Platform.isAndroid) {
      await _sendSmsAndroid(phoneNumber, message);
    } else if (Platform.isIOS) {
      await _sendSmsIOS(phoneNumber, message);
    }
  }

  Future<void> _sendSmsAndroid(String phoneNumber, String message) async {
    try {
      var status = await Permission.sms.status;
      if (!status.isGranted) {
        await Permission.sms.request();
      }

      await platform.invokeMethod('sendSms', <String, dynamic>{
        'phoneNumber': phoneNumber,
        'message': message,
      });
    } on PlatformException catch (e) {
      print("Failed to send SMS: '${e.message}'.");
    }
  }

  Future<void> _sendSmsIOS(String phoneNumber, String message) async {
    try {
      String result = await sendSMS(
        message: message,
        recipients: [phoneNumber],
      );
      print(result);
    } catch (e) {
      print("Failed to send SMS on iOS: ${e.toString()}");
    }
  }
}

class MessageService {
  final SmsSender _smsSender = SmsSender();

  // Method to send SMS to a list of recipients and store the message history
  Future<void> sendMessage(String messageTemplate, String groupName,
      String nameType, String customPrefix, List<Contact> recipients) async {
    //Need to comment the following line out when testing on a deviceless emulator
    await _requestSmsPermission(); // Ensure permissions are granted

    List<Map<String, dynamic>> failedRecipients = [];
    List<String> sentMessages = [];

    // Iterate through the list of recipients and send SMS to each
    for (var contact in recipients) {
      String personalizedMessage = _personalizeMessage(
        messageTemplate,
        contact,
        nameType,
        customPrefix,
      );

      sentMessages.add(personalizedMessage);

      try {
        await _smsSender.sendSms(contact.phoneNumber, personalizedMessage);
      } catch (e) {
        // If sending SMS fails, add the contact and error message to failedRecipients list
        failedRecipients.add({
          'contact': contact.toJson(),
          'error': e.toString(),
        });
      }
    }

    // Store the message history after sending SMS
    await _storeMessageHistory(
      groupName: groupName,
      messageTemplate: messageTemplate,
      personalizedMessages: sentMessages,
      nameType: nameType,
      customPrefix: customPrefix,
      recipients: recipients,
      failedRecipients: failedRecipients,
    );
  }

  // Private method to personalize the message for each contact
  String _personalizeMessage(
    String messageTemplate,
    Contact contact,
    String nameType,
    String customPrefix,
  ) {
    String name;
    switch (nameType) {
      case 'First Name':
        name = contact.name.split(' ').first;
        break;
      case 'Full Name':
        name = contact.name;
        break;
      case 'Custom':
        name = customPrefix;
        break;
      case 'None':
        name = '';
        break;
      default:
        name = '';
    }

    return messageTemplate.replaceAll('<name>', name);
  }

  // Private method to store message history in shared preferences
  Future<void> _storeMessageHistory({
    required String groupName,
    required String messageTemplate,
    required List<String> personalizedMessages,
    required String nameType,
    required String customPrefix,
    required List<Contact> recipients,
    required List<Map<String, dynamic>> failedRecipients,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> histories = prefs.getStringList('messageHistory') ?? [];

    // Create a map for the new message history entry
    final newHistoryEntry = {
      'groupName': groupName,
      'messageTemplate': messageTemplate,
      'personalizedMessages': personalizedMessages,
      'nameType': nameType,
      'customPrefix': customPrefix,
      'dateTime': DateTime.now().toIso8601String(),
      'recipients': recipients.map((e) => e.toJson()).toList(),
      'failedRecipients': failedRecipients,
    };

    // Convert the map to a JSON string and add it to the histories list
    histories.add(jsonEncode(newHistoryEntry));

    // Save the updated list back to shared preferences
    await prefs.setStringList('messageHistory', histories);
  }

  // Method to load message history from shared preferences
  Future<List<Map<String, dynamic>>> loadMessageHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> histories = prefs.getStringList('messageHistory') ?? [];
    // Decode each JSON string into a Map and return the list
    return histories.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}
