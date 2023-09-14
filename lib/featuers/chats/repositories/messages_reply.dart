import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/message_enum.dart';

class MessagesReply {
  final String message;
  final bool isMe;
  final MessageEnum messageType;

  MessagesReply(this.message, this.isMe, this.messageType);
}

final messageReplyProvider = StateProvider<MessagesReply?>((ref) => null);
