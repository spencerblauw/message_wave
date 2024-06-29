import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

Future<void> saveGroup(String groupName, List<Contact> contacts) async {
  final prefs = await SharedPreferences.getInstance();
  final contactList = contacts
      .map((contact) => '${contact.name},${contact.phoneNumber}')
      .toList();
  await prefs.setStringList(groupName, contactList);
}

Future<Map<String, List<Contact>>> loadGroups() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  final Map<String, List<Contact>> groups = {};

  for (var key in keys) {
    final contactList = prefs.getStringList(key) ?? [];
    groups[key] = contactList.map((contactStr) {
      final parts = contactStr.split(',');
      return Contact(name: parts[0], phoneNumber: parts[1]);
    }).toList();
  }

  return groups;
}
