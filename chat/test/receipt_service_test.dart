import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/receipt/receipt_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late ReceiptService sut;

  User user = User.fromJson({
    'id': '4444',
    'active': true,
    'last_seen': DateTime.now(),
  });

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    sut = ReceiptService(r, connection);
    await createDb(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection);
  });

  test('send receipt successfully', () async {
    Receipt receipt = Receipt(
      receiptient: '4444',
      messageId: '12345',
      status: ReceiptStatus.delivered,
      timestamp: DateTime.now(),
    );
    final resp = await sut.send(receipt);
    expect(resp, true);
  });

  test('suscribe and listern receipt successfully', () async {
    sut.receipts(user).listen(
          expectAsync1((receipt) {
            expect(receipt.receiptient, user.id);
            expect(receipt.receiptient, user.id);
          }, count: 2),
        );

    Receipt receipt = Receipt(
      receiptient: '4444',
      messageId: '12345',
      status: ReceiptStatus.sent,
      timestamp: DateTime.now(),
    );

    Receipt receipt1 = Receipt(
      receiptient: '4444',
      messageId: '12345',
      status: ReceiptStatus.delivered,
      timestamp: DateTime.now(),
    );

    await sut.send(receipt);
    await sut.send(receipt1);
  });
}
