import 'dart:async';

import 'package:chat/src/models/user.dart';
import 'package:chat/src/models/message.dart';
import 'package:chat/src/services/encryption/encryption_service_impl.dart';
import 'package:chat/src/services/message/message_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class MessageService implements IMessageService {
  RethinkDb _r;
  Connection _connection;
  late StreamSubscription _changefeed;
  late EncryptionService _encryptionService;

  final _controller = StreamController<Message>.broadcast();
  MessageService(this._r, this._connection, this._encryptionService);

  @override
  dispose() {
    _changefeed.cancel();
    _controller.close();
  }

  @override
  Stream<Message> messages({required User activeUser}) {
    _startRecevingMessages(activeUser);
    return _controller.stream;
  }

  @override
  Future<bool> send(Message message) async {
    var data = message.toJson();
    data['contents'] = _encryptionService.encrypt(data['contents']);

    final record = await _r.table('messages').insert(data).run(_connection);
    return record['inserted'] == 1;
  }

  _startRecevingMessages(User user) {
    _changefeed = _r
        .table('messages')
        .filter({'to': user.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;
                final message = _messageFromFeed(feedData);
                _controller.sink.add(message);
                _removeDeliveredMessage(message);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Message _messageFromFeed(feedData) {
    var data = feedData['new_val'];
    data['contents'] = _encryptionService.decrypt(data['contents']);
    return Message.fromJson(data);
  }

  _removeDeliveredMessage(Message message) {
    _r
        .table('messages')
        .get(message.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
