import 'package:call_me/core/enums/message_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/messages_reply.dart';

class MessageReplyPreview extends ConsumerWidget {
  MessagesReply messageReply;
  MessageReplyPreview({super.key, required this.messageReply});

  void closeReply(WidgetRef ref) {
    ref.watch(messageReplyProvider.notifier).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;

    return Container(
        width: size.width * 0.8,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(messageReply.isMe ? "Me" : "Opposite"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      messageReply.messageType == MessageEnum.image
                          ? "Your Image"
                          : messageReply.messageType == MessageEnum.image
                              ? "Your Video"
                              :  messageReply.messageType == MessageEnum.audio ? "Voice" : messageReply.message,
                    ),
                  ],
                ),
                IconButton.filled(
                    onPressed: () => closeReply(ref), icon: Icon(Icons.close))
              ],
            )
          ],
        ));
  }
}
