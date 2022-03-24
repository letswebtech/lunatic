import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/typing/typing_notification_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late TypingNotification sut;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    sut = TypingNotification(r, connection);
    await createDb(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  test('send typing notification succefully', () async {
    User from = User.fromJson({
      'id': '2222',
      'active': true,
      'last_seen': DateTime.now(),
    });

    User to = User.fromJson({
      'id': '1111',
      'active': true,
      'last_seen': DateTime.now(),
    });

    TypingEvent typingEvent = TypingEvent(
      from: from.id,
      to: to.id,
      event: Typing.start,
    );

    final resp = await sut.send(
      typingEvent: typingEvent,
      to: to,
    );

    expect(resp, true);
  });

  test('send and subscribe the typing notification', () async {
    User from = User.fromJson({
      'id': '2222',
      'active': true,
      'last_seen': DateTime.now(),
    });

    User to = User.fromJson({
      'id': '1111',
      'active': true,
      'last_seen': DateTime.now(),
    });

    TypingEvent typingEvent = TypingEvent(
      from: from.id,
      to: to.id,
      event: Typing.start,
    );

    TypingEvent typingEvent1 = TypingEvent(
      from: from.id,
      to: to.id,
      event: Typing.stop,
    );

    sut.subscribe(to, [from.id!]).listen(expectAsync1((event) {
      expect(event.from, from.id);
      expect(event.to, to.id);
    }, count: 2));

    await sut.send(
      typingEvent: typingEvent,
      to: to,
    );

    await sut.send(
      typingEvent: typingEvent1,
      to: to,
    );
  });
}
