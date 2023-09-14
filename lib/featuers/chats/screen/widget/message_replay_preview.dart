import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/messages_reply.dart';

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
                    Text(messageReply.message, maxLines: 1),
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
