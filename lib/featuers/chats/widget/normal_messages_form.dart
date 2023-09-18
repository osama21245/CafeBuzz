import 'package:call_me/core/enums/message_enum.dart';
import 'package:call_me/featuers/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/message_model.dart';
import 'text_image_gif_video.dart';

class NormalMessagesForm extends ConsumerWidget {
  Message messages;
  String timesent;
  NormalMessagesForm(
      {super.key, required this.messages, required this.timesent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(usersProvider);
    Size size = MediaQuery.of(context).size;
    return Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: size.width * 0.66),
        decoration: BoxDecoration(
          border: Border.all(
              color: messages.type == MessageEnum.image &&
                      messages.senderId != user!.uid
                  ? Color.fromARGB(158, 14, 168, 155)
                  : messages.type == MessageEnum.video &&
                          messages.senderId != user!.uid
                      ? Color.fromARGB(158, 14, 168, 155)
                      : Color.fromARGB(158, 14, 99, 168)),
          borderRadius: BorderRadius.circular(20),
          color: messages.senderId == user!.uid
              ? null
              : messages.type == MessageEnum.image
                  ? Color.fromARGB(26, 61, 130, 187)
                  : messages.type == MessageEnum.video
                      ? Color.fromARGB(26, 61, 130, 187)
                      : Color.fromARGB(158, 61, 130, 187),
        ),
        child: Text_Image_Video_Gif(
          messages: messages,
          timesent: timesent,
        ));
  }
}
