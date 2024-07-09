import 'package:flutter/material.dart';
import '../models/contact.dart';
import 'new_message_screen.dart';
import 'message_history_screen.dart';
import '../services/group_service.dart' as groupService;

class GroupScreen extends StatefulWidget {
  final String groupName;
  final List<Contact> contacts;

  const GroupScreen({Key? key, required this.groupName, required this.contacts})
      : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _memberTypeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _memberTypeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    setState(() {
      _filteredContacts = widget.contacts
          .where((contact) =>
              contact.name
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              contact.phoneNumber.contains(_searchController.text))
          .toList();
    });
  }

  // Method to add contact
  void _addContact() async {
    Contact newContact = Contact(
      name: _nameController.text,
      phoneNumber: _phoneNumberController.text,
      memberType: _memberTypeController.text,
    );

    // Add the new contact to persistent storage
    await groupService.addNewContactToGroup(widget.groupName, [newContact]);

    // Refresh the contacts from persistent storage
    await groupService.loadContacts(widget.groupName);

    // Directly update the state with the new contact
    setState(() {
      widget.contacts.add(newContact);
      _filterContacts(); // Reapply the search filter if any
    });

    Navigator.pop(context);
  }

  // Method to delete contact
  void _deleteContact(int index) {
    setState(() {
      Contact contact = _filteredContacts[index];
      widget.contacts.remove(contact);
      _filterContacts();
    });

    // Update the persistent storage
    groupService.saveGroup(widget.groupName, widget.contacts);
  }

  // Method to edit contact
  void _editContact(int index) {
    Contact contact = _filteredContacts[index];
    _nameController.text = contact.name;
    _phoneNumberController.text = contact.phoneNumber;
    _memberTypeController.text = contact.memberType;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _memberTypeController,
              decoration: const InputDecoration(labelText: 'Member Type'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                Contact updatedContact = Contact(
                  name: _nameController.text,
                  phoneNumber: _phoneNumberController.text,
                  memberType: _memberTypeController.text,
                );
                int originalIndex = widget.contacts.indexOf(contact);
                widget.contacts[originalIndex] = updatedContact;
                _filterContacts();
              });

              // Update the persistent storage
              groupService.saveGroup(widget.groupName, widget.contacts);

              Navigator.pop(context); // Close the dialog only
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.groupName} (${widget.contacts.length})'),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Members',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                return ListTile(
                  title: Text('${contact.name} (${contact.memberType})'),
                  subtitle: Text(contact.phoneNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editContact(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteContact(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewMessageScreen(
                    groupName: widget.groupName,
                    contacts: _filteredContacts,
                  ),
                ),
              );
            },
            child: const Text('New Message'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Contact'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _phoneNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                  ),
                  TextField(
                    controller: _memberTypeController,
                    decoration: const InputDecoration(labelText: 'Member Type'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _addContact,
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
