import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'screens/home_screen.dart';

// Main method
void main() {
  setupLogging(); // Set up Logging
  runApp(const MessageWaveApp()); // Run the App
}

//Method to establish the logger for all levels
void setupLogging() async {
  Logger.root.level = Level.ALL;
  //Get log file from local directory
  final logFile = await _getLogFile();
  //Listen to write a log when tasked
  Logger.root.onRecord.listen((LogRecord rec) {
    //Create log entry
    final log = '${rec.time}: ${rec.level.name}: ${rec.message}';
    //Write the entry to the log file
    _writeLog(logFile, log);
  });
}

//Method to get the logfile from local directory
Future<File> _getLogFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  return File('$path/message_wave.log');
}

//Method to append to logfile
void _writeLog(File file, String log) {
  file.writeAsStringSync('$log\n', mode: FileMode.append);
}

//Method to show an Alert Dialog to notify user
void showAlertDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );
}

// Method to display confirmation dialog yes or no
Future<bool> showConfirmationDialog(
    BuildContext context, String title, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // Dismiss the dialog and return false
                },
              ),
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  Navigator.of(context)
                      .pop(true); // Dismiss the dialog and return true
                },
              ),
            ],
          );
        },
      ) ??
      false; // Return false if dialog is dismissed
}

// App Class
class MessageWaveApp extends StatelessWidget {
  const MessageWaveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Wave',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
