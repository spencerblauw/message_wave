# Message Wave
Message Wave is a Flutter application designed to facilitate easy and efficient messaging. The app allows users to send SMS messages, manage message history, and organize contacts into groups. This README provides an overview of the project, how to get started, and other relevant information.


## Features
- Create and manage groups of contacts
- Send messages to groups or individual contacts
- Import contacts from CSV files
- View message history and logs
- Floating log notifications

## TODO List
### 1. Create New Group Button
**Issue**: Figure out why the number of members in a group is not displayed right away and why sometimes new groups do not show up.
**Implementation**:
- Ensure `_loadGroups` is called after creating a new group and resetting the form.
- Add debug statements to identify why new groups might not be showing up.
- Verify that the `_groups` variable is being updated correctly.

### 2. Delete Group Data Button
**Issue**: Change the button to delete all groups or members.
**Implementation**:
- Update the `_resetData` method to handle deleting all groups.
- Change the label of the delete button to reflect this action.

### 3. Send New Message Screen
**Issue**: Make the group selection default to the group in the panel if present, otherwise leave it blank. Allow deselection of members by scrolling or searching.
**Implementation**:
- Modify the `NewMessageScreen` to include a dropdown or selection box for groups.
- Implement member deselection functionality using checkboxes or a searchable list.

### 4. Message History Display
**Issue**: Display message history on the overall history page and each group page. Show recent messages on top and failed messages at the bottom.
**Implementation**:
- Update `MessageHistoryScreen` to fetch and display messages sorted by status.
- Implement a method to filter messages by group and display them on the respective group pages.

### 5. History Page Split
**Issue**: Split the history page to show logs on one half and message history on the other half.
**Implementation**:
- Update `MessageHistoryScreen` to include a split view.
- Fetch and display logs on one side and message history on the other.

### 6. Change "Add a Member" Button Text
**Issue**: Change the text to "Add a Member Manually".
**Implementation**:
- Update the button label in the UI code.

### 7. Add "Import Contacts via CSV" Button
**Issue**: Add this button on the main page, group pages, and group panels.
**Implementation**:
- Add the button and its functionality to the relevant pages and panels.

### 8. Floating Log Notification Box
**Issue**: Implement a floating log notification box.
**Implementation**:
- Use a `SnackBar` or a custom floating widget to show logs.
- Ensure the log notification is triggered whenever a new log is written.

## Detailed Description of Each Function

### contact.dart
- **Contact Class**:
  - **name**: The name of the contact.
  - **phoneNumber**: The phone number of the contact.
  - **memberType**: Optional member type attribute for the contact.
  - **toJson**: Converts the contact object to a JSON map.
  - **fromJson**: Creates a contact object from a JSON map.

### message.dart
- **Message Class**:
  - **content**: The content of the message.
  - **groupName**: The name of the group to which the message was sent.
  - **dateTime**: The time when the message was sent.
  - **failedRecipients**: A list of recipients who failed to receive the message.
  - **toJson**: Converts the message object to a JSON map.
  - **fromJson**: Creates a message object from a JSON map.

### csv_service.dart
- **CsvService Class**:
  - **importContactsFromCSV**: Imports contacts from a CSV file and returns a list of Contact objects.

### group_service.dart
- **GroupService Class**:
  - **saveGroup**: Saves a group with a specified name and a list of contacts.
  - **deleteGroup**: Deletes a group by its name.
  - **getGroups**: Retrieves all groups.

### message_service.dart
- **MessageService Class**:
  - **sendMessage**: Sends a message to a list of contacts.
  - **_sendSms**: Helper method to send an SMS message.
  - **_saveMessage**: Saves a message to shared preferences.
  - **getMessages**: Retrieves all messages from shared preferences.

### home_screen.dart
- **_HomeScreenState Class**:
  - **_loadGroups**: Loads all groups.
  - **_createGroup**: Creates a new group.
  - **_resetData**: Resets data based on user selection.
  - **_importCSV**: Imports contacts from a CSV file.
  - **build**: Builds the home screen UI.

### group_screen.dart
- **GroupScreen Class**:
  - **build**: Builds the group screen UI, displaying contacts of a specific group and providing options to send messages or delete the group.

### message_history_screen.dart
- **MessageHistoryScreen Class**:
  - **build**: Builds the message history screen UI, displaying the history of sent and failed messages.

### new_message_screen.dart
- **NewMessageScreen Class**:
  - **build**: Builds the new message screen UI, allowing users to send messages to a selected group or specific contacts within a group.

## Setup and Installation

1. Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` to start the application.

## Usage

1. Create a new group by clicking the "Create New Group" button.
2. Add contacts to the group manually or import them via a CSV file.
3. Send messages to the group or specific members.
4. View message history and logs to track sent and failed messages.