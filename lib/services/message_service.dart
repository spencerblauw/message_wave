import 'dart:convert';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

class MessageService {
  // Method to send SMS to a list of recipients and store the message history
  Future<void> sendMessage(String messageTemplate, String groupName,
      String nameType, String customPrefix, List<Contact> recipients) async {
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
        await sendSMS(
          message: personalizedMessage,
          recipients: [contact.phoneNumber],
        );
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
