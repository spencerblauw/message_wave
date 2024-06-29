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

  Future<void> _createGroup(String groupName) async {
    await saveGroup(groupName, _contacts);
    _loadGroups();
  }

  Future<void> _sendMessages(String groupName) async {
    final contacts = _groups[groupName] ?? [];
    await sendPersonalizedMessages(contacts);
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
            onSubmitted: _createGroup,
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
        ],
      ),
    );
  }
}
