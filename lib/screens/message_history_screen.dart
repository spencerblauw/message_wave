import 'package:flutter/material.dart';
import '../services/message_service.dart' as messageService;

class MessageHistoryScreen extends StatefulWidget {
  const MessageHistoryScreen({Key? key}) : super(key: key);

  @override
  _MessageHistoryScreenState createState() => _MessageHistoryScreenState();
}

class _MessageHistoryScreenState extends State<MessageHistoryScreen> {
  List<Map<String, dynamic>> _messageHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];
  String? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _loadMessageHistory();
  }

  // Function to load message history from shared preferences
  Future<void> _loadMessageHistory() async {
    final history = await messageService.MessageService().loadMessageHistory();
    setState(() {
      _messageHistory = history;
      _filteredHistory = history;
    });
  }

  // Function to filter message history based on selected group
  void _filterMessageHistory(String? groupName) {
    setState(() {
      if (groupName == null || groupName == 'All') {
        _filteredHistory = _messageHistory;
      } else {
        _filteredHistory = _messageHistory
            .where((history) => history['groupName'] == groupName)
            .toList();
      }
      _selectedGroup = groupName;
    });
  }

  // Function to build a list of unique group names from the message history
  List<String> _getUniqueGroupNames() {
    final groupNames =
        _messageHistory.map((e) => e['groupName'] as String).toSet().toList();
    groupNames.sort();
    groupNames.insert(0, 'All');
    return groupNames;
  }

  // Function to show error message dialog for failed recipients
  void _showErrorMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error Message'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message History'),
      ),
      body: Column(
        children: [
          // Dropdown to select group for filtering message history
          DropdownButton<String>(
            hint: const Text('Select Group'),
            value: _selectedGroup,
            onChanged: (String? newValue) {
              _filterMessageHistory(newValue);
            },
            items: _getUniqueGroupNames()
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            // List view to display filtered message history
            child: ListView.builder(
              itemCount: _filteredHistory.length,
              itemBuilder: (context, index) {
                final history = _filteredHistory[index];
                return ExpansionTile(
                  title: Text(
                    '${history['groupName']} - ${history['dateTime']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      'Recipients: ${history['recipients'].length}, Failed: ${history['failedRecipients'].length}\nMessage: ${history['personalizedMessages'].isNotEmpty ? history['personalizedMessages'].first : ""}'),
                  children: [
                    ListTile(
                      title: Text(history['messageTemplate']),
                    ),
                    ...history['recipients']
                        .map<Widget>((recipient) => ListTile(
                              title: Text(recipient['name']),
                              subtitle: Text(recipient['phoneNumber']),
                              trailing: Icon(
                                history['failedRecipients'].any((failed) =>
                                        failed['contact']['phoneNumber'] ==
                                        recipient['phoneNumber'])
                                    ? Icons.error
                                    : Icons.check,
                                color: history['failedRecipients'].any(
                                        (failed) =>
                                            failed['contact']['phoneNumber'] ==
                                            recipient['phoneNumber'])
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              onTap: () {
                                if (history['failedRecipients'].any((failed) =>
                                    failed['contact']['phoneNumber'] ==
                                    recipient['phoneNumber'])) {
                                  final errorMessage = history[
                                          'failedRecipients']
                                      .firstWhere((failed) =>
                                          failed['contact']['phoneNumber'] ==
                                          recipient['phoneNumber'])['error'];
                                  _showErrorMessage(errorMessage);
                                }
                              },
                            ))
                        .toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
