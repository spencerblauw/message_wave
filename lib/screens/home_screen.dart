import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/contact.dart';
import '../services/group_service.dart' as groupService;
import '../services/csv_service.dart' as csvService;
import '../services/reset_services.dart' as resetServices;
import '../screens/new_message_screen.dart';
import '../screens/message_history_screen.dart';
import '../screens/tutorial_screen.dart';
import '../screens/group_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String _currentGroupName = '';
  List<Contact> _newContacts = [];
  Map<String, List<Contact>> _groups = {};

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

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _requestPermissions();
  }

  Future<void> _loadGroups() async {
    final groups = await groupService.loadGroups();
    setState(() {
      _groups = groups;
      print("Groups loaded in _loadGroups: $_groups");
    });
  }

  Future<void> _createGroup() async {
    if (_currentGroupName.isNotEmpty) {
      print("Creating group: $_currentGroupName with contacts: $_newContacts");
      await groupService.saveGroup(_currentGroupName, _newContacts);
      await _loadGroups();
      setState(() {
        _currentGroupName = '';
        _newContacts = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully!')),
        );
      }
    } else {
      print("Group name is empty.");
    }
  }

  void _showContactsDialog(String groupName) {
    showDialog(
      context: context,
      builder: (context) {
        List<bool> selectedContacts =
            List<bool>.filled(_newContacts.length, false);
        return StatefulBuilder(
          builder: (context, setState) {
            int totalContacts = _newContacts.length;
            int selectedCount = selectedContacts.where((c) => c).length;

            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Contacts to Save'),
                  Text('Total Contacts Loaded: $totalContacts'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              bool allSelected =
                                  selectedContacts.every((c) => c);
                              for (int i = 0;
                                  i < selectedContacts.length;
                                  i++) {
                                selectedContacts[i] = !allSelected;
                              }
                            });
                          },
                          child: const Text('Select All'),
                        ),
                      ],
                    ),
                    ...List.generate(_newContacts.length, (index) {
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
                  ],
                ),
              ),
              actions: [
                Text('Selected Contacts: $selectedCount'),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    List<Contact> selected = [];
                    for (int i = 0; i < selectedContacts.length; i++) {
                      if (selectedContacts[i]) {
                        selected.add(_newContacts[i]);
                      }
                    }
                    print(
                        "Saving contacts to group: '$groupName' with data: $selected");
                    await groupService.addNewContactToGroup(
                        groupName, selected);
                    await _loadGroups();
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

  Future<void> _importCSV(String groupName) async {
    try {
      print('groupname is $groupName in importcsv');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile platformFile = result.files.first;
        String? filePath = platformFile.path;

        File file = File(filePath!);
        print("Selected file path: ${file.path}");

        List<Contact> importedContacts =
            await csvService.importContactsFromCSV(file);
        print('Imported contacts: $importedContacts');
        List<Contact> uniqueContacts = importedContacts.where((newContact) {
          return !_groups[groupName]!.any((existingContact) =>
              existingContact.name == newContact.name &&
              existingContact.phoneNumber == newContact.phoneNumber);
        }).toList();
        if (uniqueContacts.isNotEmpty) {
          setState(() {
            _newContacts = uniqueContacts;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New contacts staged from file!')),
          );

          _showContactsDialog(groupName);
        } else {
          print('No unique contacts imported.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No unique contacts to import.')),
          );
        }
      } else {
        print("No file selected.");
      }
    } catch (e) {
      print("Error importing CSV: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing CSV: $e')),
      );
    }
  }

  Future<void> _resetData() async {
    bool deleteGroups = false;
    bool deleteMessages = false;
    bool deleteAll = false;

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
                  CheckboxListTile(
                    title: const Text('Delete Groups'),
                    value: deleteGroups,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteGroups = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Delete all msgs?'),
                    value: deleteMessages,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteMessages = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Reset data?'),
                    value: deleteAll,
                    onChanged: (bool? value) {
                      setState(() {
                        deleteAll = value ?? false;
                        deleteMessages = value ?? false;
                        deleteGroups = value ?? false;
                      });
                    },
                  ),
                ],
              ),
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
    if (result == true) {
      await resetServices.resetData(
          deleteGroups: deleteGroups,
          deleteMessages: deleteMessages,
          deleteAll: deleteAll);
      await _loadGroups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data has been erased!')),
        );
      }
    }
  }

  Future<bool> showConfirmationDialog(
      BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
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
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    print("Building HomeScreen with groups: $_groups");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 120.0,
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Message Wave',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              children: [
                IconButton(
                  icon: const Icon(Icons.help),
                  tooltip: 'Help',
                  color: Colors.purple,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TutorialScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'History',
                  color: Colors.purple,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MessageHistoryScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset Data',
                  color: Colors.purple,
                  onPressed: () {
                    _resetData();
                  },
                ),
              ],
            ),
          ],
        ),
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
          Expanded(
            child: ListView.builder(
              itemCount: _groups.keys.length,
              itemBuilder: (context, index) {
                String groupName = _groups.keys.elementAt(index);
                return Card(
                  color: Colors.purple[50], // Light purple color
                  margin: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupScreen(
                            groupName: groupName,
                            contacts: _groups[groupName]!,
                          ),
                        ),
                      ).then((_) {
                        _loadGroups();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$groupName (${_groups[groupName]?.length ?? 0})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.send,
                                    color: Colors.purple),
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
                              TextButton.icon(
                                icon: const Icon(Icons.import_contacts,
                                    color: Colors.purple),
                                label: const Text('Add Contacts via CSV'),
                                onPressed: () async {
                                  print(
                                      "CSV import button clicked for group: $groupName");
                                  await _importCSV(groupName);
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete,
                                    color: Colors.purple),
                                label: const Text('Delete Group'),
                                onPressed: () async {
                                  if (await showConfirmationDialog(
                                      context,
                                      'Confirm',
                                      'Are you sure you want to delete $groupName?')) {
                                    await groupService.deleteGroup(groupName);
                                    await _loadGroups();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> showConfirmationDialog(
    BuildContext context, String title, String content) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
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
  ).then((value) => value ?? false);
}
