// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

//Method to load groups from groupContactsJson from prefs.group_
Future<Map<String, List<Contact>>> loadGroups() async {
  final prefs = await SharedPreferences.getInstance();
  final Map<String, List<Contact>> groups = {};
  final keys = prefs.getKeys();
  print("SharedPreferences keys: $keys");

  for (String key in keys) {
    if (key.startsWith('group_')) {
      final String? groupContactsJson = prefs.getString(key);
      if (groupContactsJson != null) {
        final List<Contact> groupContacts = Contact.decode(groupContactsJson);
        groups[key.replaceFirst('group_', '')] = groupContacts;
      }
    }
  }

  print("Loaded groups: $groups");
  return groups;
}

//Method to save a new group
Future<void> saveGroup(String groupName, List<Contact> contacts) async {
  final prefs = await SharedPreferences.getInstance();
  final encodedContacts = Contact.encode(contacts);
  print("Saving group: group_$groupName with data: $encodedContacts");
  await prefs.setString('group_$groupName', encodedContacts);
}

//Method to delete a specific group
Future<void> deleteGroup(String groupName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('group_$groupName');
}

//Method to add new contact(s) to the group
Future<Map<String, int>> addNewContactToGroup(
    String groupName, List<Contact> contacts) async {
  int newContactsCount = 0;
  int duplicateContactsCount = 0;

  //Load the existing contacts from SharedPreferences.
  final prefs = await SharedPreferences.getInstance();
  final String key = 'group_$groupName';
  final String? groupContactsJson = prefs.getString(key);
  List<Contact> existingContacts =
      groupContactsJson != null ? Contact.decode(groupContactsJson) : [];

  //Compare the new contacts against the existing ones.
  for (var contact in contacts) {
    if (!existingContacts.contains(contact)) {
      //Append only the new contacts.
      existingContacts.add(contact);
      newContactsCount++;
    } else {
      duplicateContactsCount++;
    }
  }

  //Save the updated list back to SharedPreferences.
  final encodedContacts = Contact.encode(existingContacts);
  print("Saving contacts to group: '$key' with data: $encodedContacts");
  await prefs.setString(key, encodedContacts);

  //Show how many new were added and how many skipped
  print('Added $newContactsCount new contacts');
  print('Ignored $duplicateContactsCount duplicate contacts');

  //Return the counts of new and duplicate contacts.
  return {
    'newContacts': newContactsCount,
    'duplicateContacts': duplicateContactsCount,
  };
}
