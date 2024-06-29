import 'dart:convert';

class Contact {
  final String name;
  final String phoneNumber;
  final String memberType;

  Contact({
    required this.name,
    required this.phoneNumber,
    required this.memberType,
  });

  // Factory constructor for creating a new Contact instance from a map.
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      memberType: json['memberType'],
    );
  }

  // Method for converting a Contact instance to a map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'memberType': memberType,
    };
  }

  // Decode a list of contacts from a JSON string
  static List<Contact> decode(String contactsJson) {
    return (json.decode(contactsJson) as List<dynamic>)
        .map<Contact>((item) => Contact.fromJson(item))
        .toList();
  }

  // Encode a list of contacts to a JSON string
  static String encode(List<Contact> contacts) {
    return json.encode(contacts
        .map<Map<String, dynamic>>((contact) => contact.toJson())
        .toList());
  }

  @override
  String toString() {
    return 'Contact{name: $name, phoneNumber: $phoneNumber, memberType: $memberType}';
  }
}
