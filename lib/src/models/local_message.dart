import 'package:chat/chat.dart';

class LocalMessage {
  String? get id => _id;
  String? _id;
  String? chatId;
  Message? message;
  ReceiptStatus? receipt;

  LocalMessage(this.chatId, this.message, this.receipt);

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'id': message!.id,
        ...message!.toJson(),
        'receipt': receipt!.value()
      };

  factory LocalMessage.fromJson(Map<String, dynamic> json) {
    final message = Message(
      from: json['from'],
      to: json['to'],
      contents: json['contents'],
      timestamp: json['timestamp'],
    );

    final localMessage = LocalMessage(
      json['chat_id'],
      message,
      ReceiptStatusParsing.fromString(json['receipt']),
    );
    localMessage._id = json['id'];

    return localMessage;
  }
}
