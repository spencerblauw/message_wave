import 'package:flutter/material.dart';
import '../models/contact.dart';
import 'new_message_screen.dart';
import 'message_history_screen.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _memberTypeController.dispose();
    super.dispose();
  }

// TODO: Change to call the addNewContactToGroup function
  void _addContact() {
    setState(() {
      widget.contacts.add(Contact(
        name: _nameController.text,
        phoneNumber: _phoneNumberController.text,
        memberType: _memberTypeController.text,
      ));
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
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
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Contacts', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.contacts.length,
                          itemBuilder: (context, index) {
                            final contact = widget.contacts[index];
                            return ListTile(
                              title: Text(
                                  '${contact.name} (${contact.memberType})'),
                              subtitle: Text(contact.phoneNumber),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: Column(
                    children: [
                      Text('Message History', style: TextStyle(fontSize: 18)),
                      // Add message history widget here
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewMessageScreen(
                    groupName: widget.groupName,
                    contacts: widget.contacts,
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
