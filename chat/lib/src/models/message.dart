class Message {
  String? get id => _id;
  String? _id;
  String? from;
  String? to;
  String? contents;
  DateTime? timestamp;

  Message({
    required this.from,
    required this.to,
    required this.contents,
    required this.timestamp,
  });

  toJson() => {
        'from': from,
        'to': to,
        'contents': contents,
        'timestamp': timestamp,
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    final message = Message(
      from: json['from'],
      to: json['to'],
      contents: json['contents'],
      timestamp: json['timestamp'],
    );
    message._id = json['id'];
    return message;
  }
}
