import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/message_service.dart' as messageService;
import '../services/group_service.dart' as groupService;

class NewMessageScreen extends StatefulWidget {
  final String groupName;
  final List<Contact> contacts;

  const NewMessageScreen(
      {Key? key, required this.groupName, required this.contacts})
      : super(key: key);

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController prefixController =
      TextEditingController(text: 'Hey, ');
  final TextEditingController suffixController = TextEditingController();
  final TextEditingController customPrefixController =
      TextEditingController(text: 'fellas, ');

  String? selectedMemberType;
  String? selectedNameType;
  List<Contact> filteredContacts = [];
  List<Contact> selectedContacts = [];
  List<String> memberTypes = [];

  @override
  void initState() {
    super.initState();
    filteredContacts = widget.contacts;
    memberTypes = _getUniqueMemberTypes(widget.contacts);
    _loadLastSelections(widget.groupName);
  }

  // Function to extract unique member types from the contacts
  List<String> _getUniqueMemberTypes(List<Contact> contacts) {
    final memberTypeSet = <String>{};
    for (var contact in contacts) {
      memberTypeSet.add(contact.memberType);
    }
    return memberTypeSet.toList();
  }

  // Function to filter contacts based on search query and member type
  void filterContacts() {
    setState(() {
      filteredContacts = widget.contacts.where((contact) {
        final matchesName = contact.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        final matchesMemberType = selectedMemberType == null ||
            contact.memberType == selectedMemberType;
        return matchesName && matchesMemberType;
      }).toList();
    });
  }

  // Function to select all contacts
  void selectAllContacts() {
    setState(() {
      selectedContacts.addAll(filteredContacts
          .where((contact) => !selectedContacts.contains(contact)));
    });
  }

  // Function to get name based on the selected name type
  String getContactName(Contact contact) {
    switch (selectedNameType) {
      case 'First Name':
        return contact.name.split(' ').first;
      case 'Full Name':
        return contact.name;
      case 'Custom':
        return customPrefixController.text;
      default:
        return '';
    }
  }

  // Function to build the complete message for preview
  String buildCompleteMessage() {
    return '${prefixController.text} ${getContactName(filteredContacts.first)} ${messageController.text}\n${suffixController.text}';
  }

  // Function to show message preview dialog
  void showMessagePreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Ready'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(buildCompleteMessage()),
                const SizedBox(height: 20),
                Text('Recipients (${selectedContacts.length}):'),
                Column(
                  children: selectedContacts
                      .map((contact) => ListTile(
                            title: Text(contact.name),
                            subtitle: Text(
                                '${contact.memberType} - ${contact.phoneNumber}'),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Edit Message'),
            ),
            TextButton(
              onPressed: () async {
                await messageService.sendMessage(
                    buildCompleteMessage(),
                    widget.groupName,
                    selectedMemberType ?? '',
                    selectedContacts);
                Navigator.of(context).pop();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Send'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to save last selections for the group
  void _saveLastSelections() {
    groupService.saveLastSelections(
      widget.groupName,
      prefixController.text,
      selectedNameType,
      customPrefixController.text,
      suffixController.text,
    );
  }

  // Function to load last selections for a group
  Future<void> _loadLastSelections(String groupName) async {
    final selections = await groupService.loadLastSelections(groupName);
    setState(() {
      prefixController.text = selections['prefix'] ?? 'Hey, ';
      selectedNameType = selections['nameType'] ?? 'First Name';
      customPrefixController.text = selections['customPrefix'] ?? 'fellas, ';
      suffixController.text = selections['suffix'] ?? 'Thanks!';
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    searchController.dispose();
    prefixController.dispose();
    suffixController.dispose();
    customPrefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Message for ${widget.groupName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration:
                        const InputDecoration(labelText: 'Search Members'),
                    onChanged: (value) => filterContacts(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: selectAllContacts,
                ),
                const Text('Select All'),
              ],
            ),
            DropdownButton<String>(
              hint: const Text('Select Member Type'),
              value: selectedMemberType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedMemberType = newValue;
                  filterContacts();
                });
              },
              items: memberTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  final isSelected = selectedContacts.contains(contact);
                  return ListTile(
                    title: Text(contact.name),
                    subtitle: Text(contact.memberType),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedContacts.add(contact);
                          } else {
                            selectedContacts.remove(contact);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: prefixController,
                    decoration: const InputDecoration(labelText: 'Prefix'),
                  ),
                ),
                DropdownButton<String>(
                  hint: const Text('Select Name Type'),
                  value: selectedNameType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedNameType = newValue;
                    });
                  },
                  items: <String>['First Name', 'Full Name', 'None', 'Custom']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                if (selectedNameType == 'Custom')
                  Expanded(
                    child: TextField(
                      controller: customPrefixController,
                      decoration:
                          const InputDecoration(labelText: 'Custom Prefix'),
                    ),
                  ),
              ],
            ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter your message here',
              ),
              maxLines: 4,
            ),
            TextField(
              controller: suffixController,
              decoration: const InputDecoration(labelText: 'Suffix'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedContacts.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No contacts selected')));
                  return;
                }
                showMessagePreview();
                _saveLastSelections();
              },
              child: Text('Send (${selectedContacts.length})'),
            ),
          ],
        ),
      ),
    );
  }
}
