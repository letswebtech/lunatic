import 'package:lunatic/src/models/local_message.dart';

import '../../models/chat.dart';

abstract class IDataSource {
  Future<void> addChat(Chat chat);
  Future<void> addMessage(LocalMessage localMessage);

  Future<Chat?> findChat(String chatId);
  Future<List<Chat>> findAllChats();

  Future<List<LocalMessage>> findMessages(String chatId);
  Future<void> updateMessage(LocalMessage localMessage);

  Future<void> deleteChat(String chatId);
}
