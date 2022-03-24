import 'package:flutter/widgets.dart';
import 'package:lunatic/src/data/datasource/datasource_contract.dart';
import 'package:lunatic/src/models/chat.dart';
import 'package:lunatic/src/models/local_message.dart';

abstract class BaseViewModel {
  IDataSource dataSource;

  BaseViewModel(this.dataSource);

  @protected
  Future<void> addMessage(LocalMessage localMessage) async {
    if (!await _isExistingChat(localMessage.chatId!)) {
      await _crateNewChat(localMessage.chatId!);
    }
    await dataSource.addMessage(localMessage);
    return;
  }

  Future<bool> _isExistingChat(String charId) async {
    return await dataSource.findChat(charId) != null;
  }

  Future<void> _crateNewChat(String charId) async {
    final chat = Chat(charId);
    await dataSource.addChat(chat);
    return;
  }
}
