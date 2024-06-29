class Message {
  final String content;
  final String groupName;
  final DateTime dateTime;
  final List<String> failedRecipients;

  Message({
    required this.content,
    required this.groupName,
    required this.dateTime,
    this.failedRecipients = const [],
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'groupName': groupName,
        'dateTime': dateTime.toIso8601String(),
        'failedRecipients': failedRecipients,
      };

  static Message fromJson(Map<String, dynamic> json) => Message(
        content: json['content'],
        groupName: json['groupName'],
        dateTime: DateTime.parse(json['dateTime']),
        failedRecipients: List<String>.from(json['failedRecipients']),
      );
}
