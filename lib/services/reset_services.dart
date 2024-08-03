import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Method to reset ALL data
Future<void> resetAllData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

// Method to reset message data
Future<void> resetMessages() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('messageHistory');
}

// Method to reset group data
Future<void> resetGroups() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  for (String key in keys) {
    if (key.startsWith('group_')) {
      await prefs.remove(key);
    }
  }
}

// Method to reset selected data types
Future<void> resetData({
  required bool deleteGroups,
  required bool deleteMessages,
  required bool deleteAll,
}) async {
  if (deleteAll) {
    await resetAllData();
  } else {
    if (deleteGroups) {
      await resetGroups();
    }
    if (deleteMessages) {
      await resetMessages();
    }
  }
}

class ResetScreen extends StatefulWidget {
  const ResetScreen({Key? key}) : super(key: key); // Add key parameter

  @override
  State<ResetScreen> createState() => ResetScreenState(); // Remove underscore
}

class ResetScreenState extends State<ResetScreen> {
  bool deleteGroups = false;
  bool deleteMessages = false;
  bool deleteAll = false;

  @override
  Widget build(BuildContext context) {
    // Get the media query for the device to make the text responsive.
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Data'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instruction text for resetting data
              Text(
                'Choose data to reset:',
                style: TextStyle(
                  fontSize:
                      screenWidth * 0.035, // Smaller, responsive font size
                ),
              ),
              const SizedBox(height: 16.0),
              // List of checkbox options
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: Text(
                      'Group Data',
                      style: TextStyle(fontSize: screenWidth * 0.03),
                    ),
                    value: deleteGroups,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteGroups = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Message History',
                      style: TextStyle(fontSize: screenWidth * 0.03),
                    ),
                    value: deleteMessages,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteMessages = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'All Data',
                      style: TextStyle(fontSize: screenWidth * 0.03),
                    ),
                    value: deleteAll,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteAll = value ?? false;
                        deleteGroups = value ?? false;
                        deleteMessages = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // Button to confirm reset
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Check if widget is still mounted
                    if (!mounted) return;

                    await resetData(
                      deleteGroups: deleteGroups,
                      deleteMessages: deleteMessages,
                      deleteAll: deleteAll,
                    );

                    if (!mounted) return;

                    // Display a snackbar notification when reset is complete
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data reset complete!')),
                    );
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
