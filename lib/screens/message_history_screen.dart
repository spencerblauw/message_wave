import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageHistoryScreen extends StatelessWidget {
  const MessageHistoryScreen({Key? key}) : super(key: key);

  Future<List<String>> _loadFailedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('failedMessages') ?? [];
  }

  Future<List<String>> _loadSentMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('sentMessages') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message History'),
      ),
      body: FutureBuilder<List<List<String>>>(
        future: Future.wait([_loadFailedMessages(), _loadSentMessages()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading history'));
          } else {
            final List<String> failedMessages = snapshot.data![0];
            final List<String> sentMessages = snapshot.data![1];
            return Column(
              children: [
                const Text('Failed Messages', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: ListView.builder(
                    itemCount: failedMessages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title:
                            Text('Failed to send to: ${failedMessages[index]}'),
                      );
                    },
                  ),
                ),
                const Text('Sent Messages', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: ListView.builder(
                    itemCount: sentMessages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Sent message: ${sentMessages[index]}'),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
