import 'package:chat/chat.dart';
import 'package:lunatic/src/data/datasource/datasource_contract.dart';
import 'package:lunatic/src/models/local_message.dart';
import 'package:lunatic/src/viewmodels/base_view_model.dart';

class ChatsViewModel extends BaseViewModel {
  IDataSource _dataSource;

  ChatsViewModel(this._dataSource) : super(_dataSource);

  Future<void> receivedMessage(Message message) async {
    final localMessage =
        LocalMessage(message.from, message, ReceiptStatus.delivered);
    await _dataSource.addMessage(localMessage);
    return;
  }
}
