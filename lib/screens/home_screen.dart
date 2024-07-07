import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/contact.dart';
// ignore: library_prefixes
import '../services/group_service.dart' as groupService;
// ignore: library_prefixes
import '../services/csv_service.dart' as csvService;
import '../screens/new_message_screen.dart';
import '../screens/message_history_screen.dart';
import '../screens/group_screen.dart';
import '../screens/tutorial_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create the Home Screen class
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

// Create the Home Screen state
class HomeScreenState extends State<HomeScreen> {
  List<Contact> _contacts = [];
  Map<String, List<Contact>> _groups = {};
  String _currentGroupName = '';

  //Method to initialize the HomeScreen
  @override
  void initState() {
    super.initState();
    //Load groups that were previously saved
    _loadGroups();
  }

  //Method to Load Groups
  Future<void> _loadGroups() async {
    final groups = await groupService.loadGroups();
    if (mounted) {
      setState(() {
        _groups = groups;
      });
    }
  }

  Future<void> _resetData() async {
    //Create option flags
    bool deleteGroups = false;
    bool deleteMessages = false;
    bool deleteLogs = false;

    //Create dialogue box with options on what to delete
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm Reset'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select the data you want to delete:'),
                  //Group data
                  CheckboxListTile(
                    title: const Text('Delete Group Data'),
                    value: deleteGroups,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteGroups = value ?? false;
                      });
                    },
                  ),
                  //Log data
                  CheckboxListTile(
                    title:
                        const Text('Would you like to delete all log history?'),
                    value: deleteLogs,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteLogs = value ?? false;
                      });
                    },
                  ),
                  //Message history data
                  CheckboxListTile(
                    title: const Text('Would you like to delete all messages?'),
                    value: deleteMessages,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteMessages = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              //Buttons to confirm or cancel
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
      },
    );
    //Execute based on selection after confirmation
    if (result == true) {
      if (deleteGroups) {
        await resetGroups();
      }
      if (deleteMessages) {
        await resetMessages();
      }
      if (deleteLogs) {
        await resetLogs();
      }
      // Reload groups after resetting
      _loadGroups();
    }
  }

  //Method to reset groups
  Future<void> resetGroups() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('groups'); // Assuming 'groups' is the key for storing groups
  }

  //Method to reset messages
  Future<void> resetMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
        'messages'); // Assuming 'messages' is the key for storing message history
  }

  //Method to reset logs
  Future<void> resetLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logs'); // Assuming 'logs' is the key for storing logs
  }

  //Method to create New Group
  Future<void> _createGroup() async {
    if (_currentGroupName.isNotEmpty) {
      await groupService.saveGroup(_currentGroupName, _contacts);
      if (mounted) {
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
  }

  //Import CSV Function
  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null) {
      File file = File(result.files.single.path!);
      final contacts = await csvService.importContactsFromCSV(file);
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts imported successfully!')),
      );
    }
  }

  //Create Top App Bar buttons and Group display panel
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Main Title
        title: const Align(
            alignment: Alignment.centerLeft, child: Text('Message Wave')),
        actions: [
          //Tutorial button
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
          //Message history button
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
          //Reset data button
          TextButton.icon(
            onPressed: () {
              _resetData();
            },
            icon: const Icon(Icons.restore),
            label: const Text('RESET DATA'),
          ),
        ],
      ),
      //Logo
      body: Column(
        children: [
          Center(
            child: Image.asset(
              'logo.png',
              height: 100,
              width: 100,
            ),
          ),
          //Create New Group Button
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

          //Group display Panel
          Expanded(
            child: ListView.builder(
              itemCount: _groups.keys.length,
              itemBuilder: (context, index) {
                String groupName = _groups.keys.elementAt(index);
                return ListTile(
                  title:
                      Text('$groupName (${_groups[groupName]?.length ?? 0})'),

                  //Per Group (horizontal rows)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //Send a new message button
                      TextButton.icon(
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
                      //Delete group button
                      TextButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Group'),
                        onPressed: () async {
                          await groupService.deleteGroup(groupName);
                          _loadGroups();
                        },
                      ),
                    ],
                  ),
                  //Group horizontal row itself (button)
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
