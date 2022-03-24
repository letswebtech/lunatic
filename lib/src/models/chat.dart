import 'local_message.dart';

class Chat {
  String? id;
  int unread = 0;
  List<LocalMessage>? messages = [];
  LocalMessage? mostRecent;

  Chat(this.id, {this.messages, this.mostRecent});

  Map<String, dynamic> toJson() => {'id': id};

  factory Chat.fromJson(Map<String, dynamic> json) {
    final chat = Chat(json['id']);
    return chat;
  }
}
