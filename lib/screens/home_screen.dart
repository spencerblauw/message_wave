// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:message_wave/main.dart';
import '../models/contact.dart';
import '../services/group_service.dart' as groupService;
import '../services/csv_service.dart' as csvService;
import '../services/reset_services.dart' as resetServices;
import '../screens/new_message_screen.dart';
import '../screens/message_history_screen.dart';
import '../screens/group_screen.dart';
import '../screens/tutorial_screen.dart';

// Create the Home Screen class
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

// Create the Home Screen state
class HomeScreenState extends State<HomeScreen> {
  // Create state variables
  String _currentGroupName = '';
  List<Contact> _newContacts = [];
  Map<String, List<Contact>> _groups = {};

  //Method to request permissions for files and sms
  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var smsStatus = await Permission.sms.status;
    if (!smsStatus.isGranted) {
      await Permission.sms.request();
    }
  }

  // Method to initialize the HomeScreen
  @override
  void initState() {
    super.initState();
    _loadGroups();
    _requestPermissions(); // Request permissions
  }

  // Internal method to load previous group data from the groupContactsJson
  Future<void> _loadGroups() async {
    final groups = await groupService.loadGroups();
    setState(() {
      _groups = groups;
      print("Groups loaded in _loadGroups: $_groups");
    });
  }

  // Method to create New Group
  Future<void> _createGroup() async {
    if (_currentGroupName.isNotEmpty) {
      print("Creating group: $_currentGroupName with contacts: $_newContacts");
      // Save Group
      await groupService.saveGroup(_currentGroupName, _newContacts);
      // Reset Variables and Reload Groups
      await _loadGroups();
      setState(() {
        _currentGroupName = '';
        _newContacts = [];
      });
      // Display success Message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully!')),
        );
      }
    } else {
      print("Group name is empty.");
    }
  }

  // Method to display contacts and allow saving to a group
  void _showContactsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<bool> selectedContacts =
            List<bool>.filled(_newContacts.length, false);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Contacts to Save'),
              content: SingleChildScrollView(
                child: Column(
                  children: List.generate(_newContacts.length, (index) {
                    return CheckboxListTile(
                      title: Text(_newContacts[index].name),
                      value: selectedContacts[index],
                      onChanged: (bool? value) {
                        setState(() {
                          selectedContacts[index] = value ?? false;
                        });
                      },
                    );
                  }),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    List<Contact> selected = [];
                    for (int i = 0; i < selectedContacts.length; i++) {
                      if (selectedContacts[i]) {
                        selected.add(_newContacts[i]);
                      }
                    }
                    groupService.addNewContactToGroup(
                        _currentGroupName, selected);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Method to import contacts via CSV
  Future<void> _importCSV() async {
    try {
      print("CSV import button clicked"); // Debugging statement

      // Select File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      print("File picker triggered"); // Debugging statement

      // Process File
      if (result != null && result.files.isNotEmpty) {
        PlatformFile platformFile = result.files.first;
        String? filePath = platformFile.path;

        if (filePath != null) {
          File file = File(filePath);
          print("Selected file path: ${file.path}"); // Debugging statement
          _newContacts = await csvService.importContactsFromCSV(file);

          // Stage new contacts
          if (_newContacts.isNotEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New contacts staged from file!')),
              );
            }
          }

          // Display dialog to select and save contacts to a group
          _showContactsDialog();

          // Reset Variables and Reload Groups
          await _loadGroups();
          setState(() {
            _currentGroupName = '';
            _newContacts = [];
          });
        } else {
          print("No file path found."); // Debugging statement
        }
      } else {
        print("No file selected."); // Debugging statement
      }
    } catch (e) {
      print("Error importing CSV: $e"); // Debugging statement
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing CSV: $e')),
        );
      }
    }
  }

  //Method when Reset Data button is clicked
  Future<void> _resetData() async {
    //Create option flags
    bool deleteGroups = false;
    bool deleteMessages = false;
    bool deleteLogs = false;
    bool deleteAll = false;

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
                  CheckboxListTile(
                    title: const Text('Reset ALL data?'),
                    value: deleteAll,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteAll = value ?? false;
                        deleteMessages = value ?? false;
                        deleteLogs = value ?? false;
                        deleteGroups = value ?? false;
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
      await resetServices.resetData(
          deleteGroups: deleteGroups,
          deleteMessages: deleteMessages,
          deleteLogs: deleteLogs,
          deleteAll: deleteAll);
      await _loadGroups();
      //Notify User data has been deleted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data has been erased!')),
        );
      }
    }
  }

  //Create Top App Bar buttons and Group display panel
  @override
  Widget build(BuildContext context) {
    print("Building HomeScreen with groups: $_groups");
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
                _newContacts = [];
              });
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create New Group'),
                  content: TextField(
                    decoration: const InputDecoration(labelText: 'Group Name'),
                    onChanged: (value) {
                      _currentGroupName = value;
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
                      //Add contacts to group via CSV button
                      TextButton.icon(
                        icon: const Icon(Icons.import_contacts),
                        label: const Text('Add new contacts via CSV'),
                        onPressed: () async {
                          print(
                              "CSV import button clicked"); // Debugging statement
                          await _importCSV();
                        },
                      ),
                      //Delete group button
                      TextButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Group'),
                        onPressed: () async {
                          if (await showConfirmationDialog(context, 'Confirm',
                              'Are you sure you want to delete $groupName?')) {
                            await groupService.deleteGroup(groupName);
                            await _loadGroups();
                          }
                        },
                      ),
                    ],
                  ),
                  //Group (button)
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
