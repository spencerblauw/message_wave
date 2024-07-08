import 'contact.dart';
//import 'message.dart'; //For message History

class Group {
  String groupName;
  List<Contact> members;
  List<String> messageHistory;
  DateTime createdAt;
  DateTime updatedAt;

  Group({
    required this.groupName,
    this.members = const [],
    this.messageHistory = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Add member to the group
  void addMember(Contact member) {
    members.add(member);
    updatedAt = DateTime.now();
  }

  // Add message to the group's message history
  void addMessage(String message) {
    messageHistory.add(message);
    updatedAt = DateTime.now();
  }

  // Convert Group object to JSON
  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'members': members.map((e) => e.toJson()).toList(),
      'messageHistory': messageHistory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Group object from JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupName: json['groupName'],
      members: (json['members'] as List<dynamic>)
          .map((e) => Contact.fromJson(e as Map<String, dynamic>))
          .toList(),
      messageHistory: (json['messageHistory'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
