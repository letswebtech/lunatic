import 'dart:async';

import 'package:chat/src/models/user.dart';
import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/services/receipt/receipt_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class ReceiptService implements IReceiptService {
  RethinkDb _r;
  Connection _connection;
  late StreamSubscription _changefeed;

  final _controller = StreamController<Receipt>.broadcast();

  ReceiptService(this._r, this._connection);

  @override
  void dispose() {
    _controller.close();
  }

  @override
  Stream<Receipt> receipts(User user) {
    _startRecevingReceipt(user);
    return _controller.stream;
  }

  @override
  Future<bool> send(Receipt receipt) async {
    var data = receipt.toJson();
    final record = await _r.table('receipts').insert(data).run(_connection);
    return record['inserted'] == 1;
  }

  _startRecevingReceipt(User activeUser) {
    _changefeed = _r
        .table('receipts')
        .filter({
          'receiptient': activeUser.id,
        })
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event.forEach((feedData) {
            if (feedData['new_val'] == null) return;
            Receipt receipt = _receiptFromFeed(feedData);
            _controller.sink.add(receipt);
          });
        });
  }

  _receiptFromFeed(feedData) {
    return Receipt.fromJson(feedData['new_val']);
  }
}
