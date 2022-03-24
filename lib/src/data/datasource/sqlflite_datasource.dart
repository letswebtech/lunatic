import 'package:lunatic/src/data/datasource/datasource_contract.dart';
import 'package:lunatic/src/models/local_message.dart';
import 'package:lunatic/src/models/chat.dart';
import 'package:sqflite/sqflite.dart';

class SqlfliteDataSource implements IDataSource {
  Database _db;

  SqlfliteDataSource(this._db);

  @override
  Future<void> addChat(Chat chat) async {
    _db.insert(
      'chats',
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return;
  }

  @override
  Future<void> addMessage(LocalMessage localMessage) async {
    await _db.insert(
      'messages',
      localMessage.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final batch = _db.batch();
    batch.delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);
    batch.delete('chats', where: 'id = ?', whereArgs: [chatId]);
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Chat>> findAllChats() async {
    return await _db.transaction((txn) async {
      //chats with latest message
      final chatsWithLatestMessage = await txn.rawQuery('''
    SELECT messages.* 
    FROM 
      (SELECT
      chat_id, MAX(created_at) as created_at
      FROM messages
      GROUP BY chat_id
      ) AS latest_messages
      ON messages.chat_id = latest_messages.chat_id
      AND messages.created_at = latest_messages.created_at
    ''');

      if (chatsWithLatestMessage.isEmpty) return [];

      final chatsWithUnreadMessages = await txn.rawQuery('''
  SELECT chat_id, count(*) as unread
  FROM messages
  WHERE receipt = ?
  GROUP BY chat_id 
''', ['delivered']);

      return chatsWithLatestMessage.map<Chat>((row) {
        final int unread = int.parse(chatsWithUnreadMessages
            .firstWhere((element) => row['chat_id'] == element['chat_id'],
                orElse: () => {'unread': 0})['unread']
            .toString());
        final chat = Chat.fromJson(row);
        chat.unread = unread;
        chat.mostRecent = LocalMessage.fromJson(row);
        return chat;
      }).toList();
    });
  }

  @override
  Future<Chat?> findChat(String chatId) async {
    return await _db.transaction((txn) async {
      //chats with latest message
      final listOfChatMaps = await txn.query(
        'chats',
        where: 'id = ?',
        whereArgs: [chatId],
      );

      if (listOfChatMaps.isEmpty) return null;

      final unread = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT COUNT(*) FROM messages WHERE chat_id = ? AND receipt = ?',
          [chatId, 'delivered'],
        ),
      );
      final mostRecentMessage = await txn.query(
        'messages',
        where: 'chat_id = ?',
        whereArgs: [chatId],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      final chat = Chat.fromJson(listOfChatMaps.first);
      chat.unread = unread!;
      chat.mostRecent = LocalMessage.fromJson(mostRecentMessage.first);
      return chat;
    });
  }

  @override
  Future<List<LocalMessage>> findMessages(String chatId) async {
    final messages =
        await _db.query('messages', where: 'chat_id = ?', whereArgs: [chatId]);

    return messages
        .map<LocalMessage>((message) => LocalMessage.fromJson(message))
        .toList();
  }

  @override
  Future<void> updateMessage(LocalMessage localMessage) async {
    await _db.update(
      'messages',
      localMessage.toJson(),
      where: 'id = ?',
      whereArgs: [localMessage.message!.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
