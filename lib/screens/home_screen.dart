import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/contact.dart';
import '../services/csv_service.dart';
import '../services/group_service.dart';
import 'group_screen.dart';
import 'new_message_screen.dart';
import 'message_history_screen.dart';

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

  Future<void> _importCSV(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null) {
      File file = File(result.files.single.path!);
      final contacts = await importContactsFromCSV(file);
      setState(() {
        _contacts = contacts;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts imported successfully!')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Message Wave')),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MessageHistoryScreen()),
              );
            },
            icon: const Icon(Icons.history),
            label: const Text('History'),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Image.asset(
              'logo.png',
              height: 100,
              width: 100,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentGroupName = '';
                _contacts = [];
              });
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create New Group'),
                  content: TextField(
                    decoration: const InputDecoration(labelText: 'Group Name'),
                    onChanged: (value) {
                      setState(() {
                        _currentGroupName = value;
                      });
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _createGroup();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Create New Group'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _groups.keys.length,
              itemBuilder: (context, index) {
                String groupName = _groups.keys.elementAt(index);
                return ListTile(
                  title:
                      Text('$groupName (${_groups[groupName]?.length ?? 0})'),
                  trailing: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewMessageScreen(
                            groupName: groupName,
                            contacts: _groups[groupName]!,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupScreen(
                          groupName: groupName,
                          contacts: _groups[groupName]!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
