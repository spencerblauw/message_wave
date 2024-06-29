import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:logging/logging.dart';

void _setupLogging() {
  Logger.root.level = Level.ALL; // Set to the desired level
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

void main() {
  _setupLogging();
  runApp(const MessageWaveApp());
}

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
