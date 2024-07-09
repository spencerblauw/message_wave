import 'package:shared_preferences/shared_preferences.dart';

//Method to reset ALL data
Future<void> resetAllData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

//Method to reset message data
Future<void> resetMessages() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('messageHistory');
}

//Method to reset log data
Future<void> resetLogs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('logs');
}

//Method to reset group data
Future<void> resetGroups() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  for (String key in keys) {
    if (key.startsWith('group_')) {
      await prefs.remove(key);
    }
  }
}

//Method to reset selected data types
Future<void> resetData(
    {required bool deleteGroups,
    required bool deleteMessages,
    required bool deleteLogs,
    required bool deleteAll}) async {
  if (deleteAll) {
    await resetAllData();
  } else {
    if (deleteGroups) {
      await resetGroups();
    }
    if (deleteMessages) {
      await resetMessages();
    }
    if (deleteLogs) {
      await resetLogs();
    }
  }
}
