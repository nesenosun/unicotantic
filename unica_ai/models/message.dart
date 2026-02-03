class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? thought;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.thought,
  });

  factory Message.fromJson(Map<String, dynamic> json, bool isUser) {
    return Message(
      text: isUser ? json['user'] : json['ai'],
      isUser: isUser,
      timestamp: DateTime.parse(
        json['time'] ?? DateTime.now().toIso8601String(),
      ),
      thought: isUser ? null : json['thought'],
    );
  }
}
