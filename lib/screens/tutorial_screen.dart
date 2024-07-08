import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Welcome to Message Wave!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Step 1: Create a New Group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'To create a new group, go to the home screen and click on the "Create New Group" button. Enter a name for your group and click "Save".',
            ),
            const SizedBox(height: 16),
            const Text(
              'Step 2: Add Contacts to Group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'After creating a group, you can add contacts by clicking on the group name. You will be taken to the group screen where you can manually add contacts or import them from a CSV file.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Step 3: Send a New Message',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'To send a new message, click on the "New Message" button on the group screen. You can compose your message and it will be sent to all the contacts in the group.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Step 4: View Message History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'To view the message history, click on the "History" button in the top right corner of the screen. You can see the list of sent and failed messages here.',
            ),
            const SizedBox(height: 16),
            const Text(
              'That\'s it! You are ready to use Message Wave.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
