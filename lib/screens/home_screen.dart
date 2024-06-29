import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/contact.dart';
import '../services/csv_service.dart';
import '../services/group_service.dart';
import '../services/sms_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Contact> _contacts = [];
  Map<String, List<Contact>> _groups = {};
  String _currentGroupName = '';

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await loadGroups();
    setState(() {
      _groups = groups;
    });
  }

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null) {
      File file = File(result.files.single.path!);
      final contacts = await importContactsFromCSV(file);
      setState(() {
        _contacts = contacts;
      });
    }
  }

  Future<void> _createGroup() async {
    if (_currentGroupName.isNotEmpty) {
      await saveGroup(_currentGroupName, _contacts);
      _loadGroups();
      setState(() {
        _currentGroupName = '';
        _contacts = [];
      });
    }
  }

  Future<void> _sendMessages(String groupName) async {
    final contacts = _groups[groupName] ?? [];
    await sendPersonalizedMessages(contacts);
  }

  void _addContactManually(String name, String phoneNumber) {
    setState(() {
      _contacts.add(Contact(name: name, phoneNumber: phoneNumber));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Wave')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _importCSV,
            child: const Text('Import Contacts from CSV'),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Group Name'),
            onChanged: (value) {
              setState(() {
                _currentGroupName = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: _createGroup,
            child: const Text('Save Group'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _groups.keys.length,
              itemBuilder: (context, index) {
                String groupName = _groups.keys.elementAt(index);
                return ListTile(
                  title: Text(groupName),
                  trailing: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessages(groupName),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          const Text('Manually Add Contact'),
          TextField(
            decoration: const InputDecoration(labelText: 'Contact Name'),
            onSubmitted: (name) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Enter Phone Number'),
                    content: TextField(
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                      onSubmitted: (phoneNumber) {
                        _addContactManually(name, phoneNumber);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Open the new message screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewMessageScreen(groups: _groups)),
              );
            },
            child: const Text('New Message'),
          ),
        ],
      ),
    );
  }
}

class NewMessageScreen extends StatelessWidget {
  final Map<String, List<Contact>> groups;

  const NewMessageScreen({Key? key, required this.groups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String message = '';
    String selectedGroup = '';
    return Scaffold(
      appBar: AppBar(title: const Text('New Message')),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Message'),
            onChanged: (value) {
              message = value;
            },
          ),
          DropdownButton<String>(
            hint: const Text('Select Group'),
            value: selectedGroup.isEmpty ? null : selectedGroup,
            onChanged: (String? newValue) {
              if (newValue != null) {
                selectedGroup = newValue;
              }
            },
            items: groups.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedGroup.isNotEmpty && message.isNotEmpty) {
                await sendPersonalizedMessages(groups[selectedGroup]!);
                Navigator.pop(context);
              }
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }
}
