import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:call_me/core/enums/message_enum.dart';
import 'package:call_me/featuers/chats/repositories/messages_loading.dart';
import 'package:call_me/featuers/chats/widget/videoplayer.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/message_model.dart';
import '../repositories/messages_audio_loading.dart';

class Text_Image_Video_Gif extends ConsumerWidget {
  Message messages;
  String timesent;
  Text_Image_Video_Gif(
      {Key? key, required this.messages, required this.timesent})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(AudioloadingProvider);
    Size size = MediaQuery.of(context).size;
    bool isplayRecord = false;

    final playRecord = AudioPlayer();

    return messages.type == MessageEnum.image
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      top: size.height * 0.003,
                      left: size.height * 0.001,
                      right: size.height * 0.001,
                      bottom: size.height * 0.007),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      height: size.height * 0.3,
                      width: size.width * 0.5,
                      imageUrl: messages.text,
                      fit: BoxFit.contain,
                    ),
                  )),
              Text(
                timesent,
                style: TextStyle(
                    fontSize: 6, color: Color.fromARGB(218, 153, 182, 206)),
              )
            ],
          )
        : messages.type == MessageEnum.audio
            ? StatefulBuilder(builder: (context, setState) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(
                                "assets/images/coffeepic2-removebg-logo.png"),
                            radius: 25,
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () async {
                                if (loading == null) {
                                  ref
                                      .watch(AudioloadingProvider.notifier)
                                      .update((state) => Loading(true));
                                  playRecord.play(UrlSource(messages.text));
                                } else {
                                  ref
                                      .watch(AudioloadingProvider.notifier)
                                      .update((state) => null);
                                }
                              },
                              icon: loading != null
                                  ? Icon(Icons.pause)
                                  : Icon(Icons.play_arrow)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          messages.isSeen
                              ? Icon(
                                  Icons.done_all,
                                  size: 12,
                                )
                              : Icon(
                                  Icons.done,
                                  size: 12,
                                ),
                          Text(
                            timesent,
                            style: TextStyle(
                                fontSize: 6,
                                color: Color.fromARGB(218, 153, 182, 206)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              })
            : messages.type == MessageEnum.video
                ? MessageVideoPlayer(videoUrl: messages.text)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          messages.text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            messages.isSeen
                                ? Icon(
                                    Icons.done_all,
                                    size: 12,
                                  )
                                : Icon(
                                    Icons.done,
                                    size: 12,
                                  ),
                            Text(
                              timesent,
                              style: TextStyle(
                                  fontSize: 6,
                                  color: Color.fromARGB(218, 153, 182, 206)),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
  }
}
