import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/encryption/encryption_service_impl.dart';
import 'package:chat/src/services/message/message_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late MessageService sut;
  late EncryptionService encryptionService;

  User user1 = User.fromJson({
    'id': '1111',
    'active': true,
    'last_seen': DateTime.now(),
  });

  User user2 = User.fromJson({
    'id': '2222',
    'active': true,
    'last_seen': DateTime.now(),
  });

  setUp(() async {
    final encypter = Encrypter(AES(Key.fromLength(32)));
    encryptionService = EncryptionService(encypter);
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    sut = MessageService(r, connection, encryptionService);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  test('send message to a user', () async {
    Message message = Message(
      from: user1.id,
      to: user2.id,
      contents: 'this is a message',
      timestamp: DateTime.now(),
    );

    bool res = await sut.send(message);
    expect(res, true);
  });

  test('successful suscribe and receive messages', () async {
    sut.messages(activeUser: user2).listen(
          expectAsync1(
            (mesage) {
              expect(mesage.to, user2.id);
              expect(mesage.id, isNotEmpty);
            },
            count: 2,
          ),
        );

    Message message1 = Message(
      from: user1.id,
      to: user2.id,
      contents: 'this is a message 1',
      timestamp: DateTime.now(),
    );

    Message message2 = Message(
      from: user1.id,
      to: user2.id,
      contents: 'this is a message 2',
      timestamp: DateTime.now(),
    );

    await sut.send(message1);
    await sut.send(message2);
  });

  test('successful suscribe and receive new messages', () async {
    Message message1 = Message(
      from: user1.id,
      to: user2.id,
      contents: 'this is a message 1',
      timestamp: DateTime.now(),
    );

    Message message2 = Message(
      from: user1.id,
      to: user2.id,
      contents: 'this is a message 2',
      timestamp: DateTime.now(),
    );

    await sut.send(message1);
    await sut.send(message2).whenComplete(
          () => sut.messages(activeUser: user2).listen(
                expectAsync1((message) {
                  expect(message.to, user2.id);
                }, count: 2),
              ),
        );
  });
}
