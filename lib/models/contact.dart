class Contact {
  final String name;
  final String phoneNumber;
  final String memberType;

  Contact(
      {required this.name,
      required this.phoneNumber,
      required this.memberType});

  String get firstName => name.split(' ')[0];

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumber': phoneNumber,
        'memberType': memberType,
      };

  static Contact fromJson(Map<String, dynamic> json) => Contact(
        name: json['name'],
        phoneNumber: json['phoneNumber'],
        memberType: json['memberType'],
      );
}
