import 'package:chat/src/models/typing_event.dart';

import '../../models/user.dart';

abstract class ITypingNotification {
  Future<bool> send({required TypingEvent typingEvent, required User to});
  Stream<TypingEvent> subscribe(User user, List<String> usersIds);
  void dispose();
}
