import 'package:chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunatic/src/data/datasource/sqlflite_datasource.dart';
import 'package:lunatic/src/models/chat.dart';
import 'package:lunatic/src/models/local_message.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import 'sqlflite_datasource_test.mocks.dart';

//class MockSqlfliteDatabase extends Mock implements Database {}

//class MockBatch extends Mock implements Batch {}

@GenerateMocks([Database, Batch])
void main() {
  late SqlfliteDataSource sut;
  late MockDatabase database;
  late MockBatch batch;

  setUp(() {
    database = MockDatabase();
    batch = MockBatch();
    sut = SqlfliteDataSource(database);
  });

  final message = Message.fromJson({
    'from': '4444',
    'to': '1111',
    'contents': 'Heyyyyy',
    'timestamp': DateTime.parse('2021-04-01'),
    'id': '4444'
  });

  test('should perform insert of chat to the database', () async {
    //arrange
    final chat = Chat('1111');
    when(database.insert(
      'chats',
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).thenAnswer((realInvocation) async {
      return 1;
    });

    //act
    await sut.addChat(chat);

    //assets
    verify(database.insert(
      'chats',
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);
  });

  test('should perform insert of message to the database', () async {
    //arrange
    final localMessage = LocalMessage('1111', message, ReceiptStatus.sent);

    when(database.insert(
      'messages',
      localMessage.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).thenAnswer((realInvocation) async {
      return 1;
    });

    //act
    await sut.addMessage(localMessage);

    //assets
    verify(database.insert(
      'messages',
      localMessage.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);
  });
}
