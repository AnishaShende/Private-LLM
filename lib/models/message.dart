class Message {
  String content;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? relevantDocs;
  Duration? generationTime;
  List<String>? highlightedText;
  List<String>? links;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.highlightedText,
    this.links,
    this.relevantDocs,
    this.generationTime,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'links': links?.toList(), // Convert to List before encoding
        'highlightedText': highlightedText?.toList(),
        'relevantDocs': relevantDocs,
        'generationTime': generationTime?.inMicroseconds,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        content: json['content'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
        highlightedText: (json['highlightedText'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        links:
            (json['links'] as List<dynamic>?)?.map((e) => e as String).toList(),
        relevantDocs: (json['relevantDocs'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList(),
        generationTime: json['generationTime'] != null
            ? Duration(microseconds: json['generationTime'] as int)
            : null,
      );

  void updateContent(String newContent) {
    content = newContent;
  }
}
