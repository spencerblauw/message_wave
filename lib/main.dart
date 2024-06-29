import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MessageWaveApp());
}

class MessageWaveApp extends StatelessWidget {
  const MessageWaveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}
