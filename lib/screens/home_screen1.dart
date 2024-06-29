import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/contact.dart';
import '../services/group_service.dart';
import '../services/csv_service.dart';
import '../screens/new_message_screen.dart';
import '../screens/message_history_screen.dart';
import '../screens/group_screen.dart';
import '../screens/tutorial_screen.dart';

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

  // LOAD GROUPS Function
  Future<void> _loadGroups() async {
    final groups = await loadGroups();
    setState(() {
      _groups = groups;
    });
  }

  //RESET DATA function
  Future<void> _resetData() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text('Are you sure you want to delete ALL data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await _resetData();
      _loadGroups(); // Reload groups after resetting
    }
  }

  //CREATE NEW GROUP Function
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

  //IMPORT CSV Function
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

//App Bar buttons
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //App Bar Title - MessageWave
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text('Message Wave'),
        ),
        actions: [
          //TUTORIAL BUTTON
          TextButton.icon(
            icon: const Icon(Icons.help),
            label: const Text('HELP'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TutorialScreen()),
              );
            },
          ),

          //HISTORY BUTTON
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

          //RESET BUTTON
          TextButton.icon(
            onPressed: () {
              _resetData();
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('RESET DATA'),
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
                    //CREATE NEW GROUP Button
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

          //GROUP ROWS/BUTTONS
          Expanded(
            child: ListView.builder(
              itemCount: _groups.keys.length,
              itemBuilder: (context, index) {
                String groupName = _groups.keys.elementAt(index);
                return ListTile(
                  title:
                      Text('$groupName (${_groups[groupName]?.length ?? 0})'),

                  //Send New Message Buttons
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Send New Message'),
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

                  //GROUP Buttons
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
