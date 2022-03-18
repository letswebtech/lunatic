import 'package:rethink_db_ns/rethink_db_ns.dart';

Future<void> createDb(RethinkDb r, Connection connection) async {
  await r.dbCreate('test').run(connection).onError((error, stackTrace) => {});
  await r
      .tableCreate('users')
      .run(connection)
      .onError((error, stackTrace) => {});
  await r
      .tableCreate('messages')
      .run(connection)
      .onError((error, stackTrace) => {});
}

Future<void> cleanDb(RethinkDb r, Connection connection) async {
  await r
      .table('users')
      .delete()
      .run(connection)
      .onError((error, stackTrace) => {});
  await r
      .table('messages')
      .delete()
      .run(connection)
      .onError((error, stackTrace) => {});
}
