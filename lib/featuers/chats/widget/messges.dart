import 'package:call_me/featuers/chats/controller/chat_controller.dart';
import 'package:call_me/featuers/chats/repositories/messages_reply.dart';
import 'package:call_me/featuers/chats/widget/replayed_message_form.dart';
import 'package:call_me/featuers/chats/widget/text_image_gif_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/enums/message_enum.dart';
import '../../auth/controller/auth_controller.dart';
import '../../user_profile/controller/user_profile_controller.dart';
import 'normal_messages_form.dart';

class MessageBubble extends ConsumerWidget {
  final String uid;
  ScrollController scrollController;
  MessageBubble({super.key, required this.uid, required this.scrollController});

  void replayonMessage(WidgetRef ref, String message, MessageEnum messageEnum) {
    ref
        .watch(messageReplyProvider.notifier)
        .update((state) => MessagesReply(message, false, messageEnum));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(usersProvider)!;
    Size size = MediaQuery.of(context).size;

    return Expanded(
      child: ref.watch(getUserMessagesProviderr(uid)).when(
          data: (data) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    reverse: true,
                    controller: scrollController,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final messages = data[index];
                      final timesent =
                          DateFormat.Hm().format(messages.timeSent);
                      if (!messages.isSeen && messages.recieverid == user.uid) {
                        ref
                            .watch(ChatControllerProider.notifier)
                            .updateSeen(uid, messages.messageId);
                      }
                      return SwipeTo(
                        onRightSwipe: () {
                          if (user.uid != messages.senderId)
                            replayonMessage(ref, messages.text, messages.type);
                        },
                        child: Align(
                            alignment: messages.senderId == user.uid
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: messages.repliedMessage != ""
                                ? ReplayedMessageForm(
                                    messages: messages,
                                    timesent: timesent,
                                  )
                                : NormalMessagesForm(
                                    messages: messages,
                                    timesent: timesent,
                                  )),
                      );
                    }));
          },
          error: (error, StackTrace) {
            print(error);
            ;
            return ErrorText(error: error.toString());
          },
          loading: () => const Loader()),
    );
  }
}
