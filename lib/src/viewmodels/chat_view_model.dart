import 'package:chat/chat.dart';
import 'package:lunatic/src/data/datasource/datasource_contract.dart';
import 'package:lunatic/src/models/local_message.dart';
import 'package:lunatic/src/viewmodels/base_view_model.dart';

class ChatViewModel extends BaseViewModel {
  IDataSource _dataSource;
  String _chatId = '';
  int otherMessages = 0;

  ChatViewModel(this._dataSource) : super(_dataSource);

  Future<List<LocalMessage>> getMessages(String chatId) async {
    final message = await _dataSource.findMessages(chatId);
    if (message.isNotEmpty) _chatId = chatId;
    return message;
  }

  Future<void> sendMessage(Message message) async {
    final localMessage = LocalMessage(message.to, message, ReceiptStatus.sent);
    await addMessage(localMessage);
    if (_chatId.isEmpty) _chatId = localMessage.chatId!;
  }

  Future<void> receivedMessage(Message message) async {
    final localMessage = LocalMessage(message.to, message, ReceiptStatus.sent);
    await addMessage(localMessage);
    if (localMessage.chatId != _chatId) otherMessages++;
  }
}
