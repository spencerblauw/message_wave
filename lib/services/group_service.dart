import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

Future<Map<String, List<Contact>>> loadGroups() async {
  final prefs = await SharedPreferences.getInstance();
  final Map<String, List<Contact>> groups = {};

  for (String key in prefs.getKeys()) {
    final String? groupContactsJson = prefs.getString(key);
    if (groupContactsJson != null) {
      final List<Contact> groupContacts = Contact.decode(groupContactsJson);
      groups[key] = groupContacts;
    }
  }

  return groups;
}

Future<void> saveGroup(String groupName, List<Contact> contacts) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(groupName, Contact.encode(contacts));
}

Future<void> deleteGroup(String groupName) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(groupName);
}

Future<void> resetData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
