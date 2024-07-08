import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/message_service.dart' as messageService;

class NewMessageScreen extends StatelessWidget {
  final String groupName;
  final List<Contact> contacts;

  const NewMessageScreen(
      {Key? key, required this.groupName, required this.contacts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final TextEditingController memberTypeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('New Message for $groupName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 4,
            ),
            TextField(
              controller: memberTypeController,
              decoration:
                  const InputDecoration(labelText: 'Member Type (Optional)'),
            ),
            ElevatedButton(
              onPressed: () async {
                String groupName = messageController.text;
                String message = messageController.text;
                String? memberType = memberTypeController.text.isNotEmpty
                    ? memberTypeController.text
                    : null;
                List<Contact> filteredContacts = memberType != null
                    ? contacts
                        .where((contact) => contact.memberType == memberType)
                        .toList()
                    : contacts;

                await messageService.sendMessage(
                    message, groupName, memberType!, filteredContacts);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}
