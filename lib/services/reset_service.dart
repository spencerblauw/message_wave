import 'package:shared_preferences/shared_preferences.dart';

Future<void> resetData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
