import 'dart:convert';

//Create model class for an individual contact
class Contact {
  final String name;
  final String phoneNumber;
  final String memberType;

  Contact(
      {required this.name, required this.phoneNumber, this.memberType = ''});

  // Method to create new contact from Json
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      memberType: json['memberType'],
    );
  }

  // Method to convert a Contact to a json.
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

  // Method for returning a string of information about a contact
  @override
  String toString() {
    return 'Contact{name: $name, phoneNumber: $phoneNumber, memberType: $memberType}';
  }
}
