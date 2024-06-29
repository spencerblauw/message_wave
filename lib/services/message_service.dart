import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/message.dart';

Future<void> saveMessage(Message message) async {
  final prefs = await SharedPreferences.getInstance();
  final messages = prefs.getStringList('messages') ?? [];
  messages.add(jsonEncode(message.toJson()));
  await prefs.setStringList('messages', messages);
}

Future<List<Message>> loadMessages() async {
  final prefs = await SharedPreferences.getInstance();
  final messages = prefs.getStringList('messages') ?? [];
  return messages.map((msg) => Message.fromJson(jsonDecode(msg))).toList();
}

extension MessageSerialization on Message {
  Map<String, dynamic> toJson() => {
        'content': content,
        'groupName': groupName,
        'dateTime': dateTime.toIso8601String(),
        'failedRecipients': failedRecipients,
      };

  static Message fromJson(Map<String, dynamic> json) => Message(
        content: json['content'],
        groupName: json['groupName'],
        dateTime: DateTime.parse(json['dateTime']),
        failedRecipients: List<String>.from(json['failedRecipients']),
      );
}
