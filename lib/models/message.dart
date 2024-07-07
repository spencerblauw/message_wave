// Create a model class for Message attempts
class Message {
  final String content;
  final String groupName;
  final String memberType;
  final DateTime dateTime;
  final int successfulSends;
  final int totalRecipients;
  final List<String> failedRecipients;

  Message(
      {required this.content,
      required this.groupName,
      required this.dateTime,
      required this.successfulSends,
      required this.totalRecipients,
      this.failedRecipients = const [],
      this.memberType = ''});

  Map<String, dynamic> toJson() => {
        'content': content,
        'groupName': groupName,
        'memberType': memberType,
        'dateTime': dateTime.toIso8601String(),
        'successfulSends': successfulSends,
        'totalRecipients': totalRecipients,
        'failedRecipients': failedRecipients,
      };

//Get info from JSON about prior message attempts
  static Message fromJson(Map<String, dynamic> json) => Message(
        content: json['content'],
        groupName: json['groupName'],
        memberType: json['memberType'],
        dateTime: DateTime.parse(json['dateTime']),
        successfulSends: json['successfulSends'],
        totalRecipients: json['totalRecipients'],
        failedRecipients: List<String>.from(json['failedRecipients']),
      );
}
