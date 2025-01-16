class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? relevantDocs;
  final Duration? generationTime;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.relevantDocs,
    this.generationTime,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'relevantDocs': relevantDocs,
        'generationTime': generationTime?.inMicroseconds,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        content: json['content'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
        relevantDocs: json['relevantDocs'],
        generationTime: json['generationTime'] != null
            ? Duration(microseconds: json['generationTime'])
            : null,
      );
}
