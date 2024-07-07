import 'package:logging/logging.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/message.dart';
import '../models/contact.dart';

// Message service Logger
final Logger _logger = Logger('MessageService');

// Method to send an individual message to each recipient,
// and keep track of failed/successful messages
Future<void> sendMessage(String content, String groupName, String memberType,
    List<Contact> contacts) async {
  int successCount = 0;
  List<String> failedRecipients = [];
  List<String> failedRecipientsNames = [];

  //Create personal message for recipient
  for (Contact contact in contacts) {
    String message = 'Hello ${contact.name.split(' ').first}, $content';

    //Send SMS of personal message to recipient
    try {
      bool success = await _sendSms(message, contact.phoneNumber, contact.name);

      if (success) {
        //Incriment counter and log the individual message history
        successCount++;
        _logger.info(
            'Message sent to $groupName member type ${contact.memberType}: ${contact.name} (${contact.phoneNumber}): $content');
      } else {
        //Add member to failed message list and log the individual message history
        failedRecipients.add(contact.phoneNumber);
        failedRecipientsNames.add(contact.name);
        _logger.warning(
            'FAILED to send message to $groupName member type ${contact.memberType}: ${contact.name} (${contact.phoneNumber}): $content');
      }

      //Catch and log error for failed SMS attempt
    } catch (e) {
      failedRecipients.add(contact.phoneNumber);
      failedRecipientsNames.add(contact.name);
      _logger.severe(
          'Error sending message to ${contact.name} (${contact.phoneNumber}): $content',
          e);
    }
  }

  //Create group message summary
  final message = Message(
    content: content,
    groupName: groupName,
    memberType: memberType,
    successfulSends: successCount,
    totalRecipients: contacts.length,
    dateTime: DateTime.now(),
    failedRecipients: failedRecipients,
  );

  //Save group message summary
  await _saveMessage(message);
  _logger.info(
      'Messages sent to $groupName member type $memberType ($successCount/${contacts.length}) with content: $content. Failed recipients: ${failedRecipientsNames.join(', ')}');
}

// Method to send SMS from local device
Future<bool> _sendSms(String message, String phoneNumber, String name) async {
  try {
    //Attempt to send SMS
    String result = await sendSMS(message: message, recipients: [phoneNumber]);
    //Get Result
    _logger.info('Result from sendSMS: $result');
    return result ==
        'SMS Sent to $phoneNumber!'; //Return True or False based on result
    //Catch IF error
  } catch (e) {
    //Log error message
    _logger.severe('Error sending SMS to $name $phoneNumber: $message', e);
    return false;
  }
}

// Update/save message history
Future<void> _saveMessage(Message message) async {
  final prefs = await SharedPreferences.getInstance();
  //get old message history from json
  final messages = await getMessages();
  //add new message to history
  messages.add(message);
  //format to json
  final messagesJson = messages.map((msg) => msg.toJson()).toList();
  //save messages with the updated json additions
  await prefs.setString('messages', jsonEncode(messagesJson));
}

// Get old message history from json
Future<List<Message>> getMessages() async {
  final prefs = await SharedPreferences.getInstance();
  //get 'messages' json
  final messagesJson = prefs.getString('messages');
  //return empty if empty
  if (messagesJson == null) {
    return [];
  }
  //Create list of prior messages from the json
  final List<dynamic> messagesList = jsonDecode(messagesJson);
  //Return list of prior messages
  return messagesList.map((json) => Message.fromJson(json)).toList();
}
