import 'dart:async';

import 'package:chat/src/models/user.dart';

import 'package:chat/src/models/typing_event.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'typing_notification_service_contract.dart';

class TypingNotification implements ITypingNotification {
  RethinkDb _r;
  Connection _connection;
  late StreamSubscription _changefeed;

  final _controller = StreamController<TypingEvent>.broadcast();

  TypingNotification(this._r, this._connection);

  @override
  Future<bool> send(
      {required TypingEvent typingEvent, required User to}) async {
    if (to.active != true) return false;
    final record = await _r
        .table('typing_events')
        .insert(typingEvent.toJson())
        .run(_connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<TypingEvent> subscribe(User user, List<String> usersIds) {
    _startRecevingTypingEvents(user, usersIds);
    return _controller.stream;
  }

  _startRecevingTypingEvents(User user, List<String> usersIds) {
    _changefeed = _r
        .table('typing_events')
        .filter((event) {
          return event('to')
              .eq(user.id)
              .and(_r.expr(usersIds).contains(event('from')));
        })
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;
                final typingEvent = _eventFromFeed(feedData);
                _controller.sink.add(typingEvent);
                _removeEvent(typingEvent);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  TypingEvent _eventFromFeed(feedData) {
    return TypingEvent.fromJson(feedData['new_val']);
  }

  _removeEvent(TypingEvent typingEvent) {
    _r
        .table('typing_events')
        .get(typingEvent.id)
        .delete({'return_changes': false}).run(_connection);
  }

  @override
  void dispose() {
    _changefeed.cancel();
    _controller.close();
  }
}
