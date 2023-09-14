import 'package:cached_network_image/cached_network_image.dart';
import 'package:call_me/core/enums/message_enum.dart';
import 'package:call_me/featuers/chats/screen/widget/videoplayer.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/models/message_model.dart';

class Text_Image_Video_Replay extends StatelessWidget {
  Message messages;
  Text_Image_Video_Replay({Key? key, required this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isplayRecord = false;
    final playRecord = AudioPlayer();
    return messages.replayedMessageType == MessageEnum.image
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
                      height: size.height * 0.2,
                      width: size.width * 0.3,
                      imageUrl: messages.repliedMessage,
                      fit: BoxFit.contain,
                    ),
                  )),
            ],
          )
        : messages.replayedMessageType == MessageEnum.audio
            ? StatefulBuilder(builder: (context, setState) {
                return IconButton(
                    onPressed: () async {
                      if (isplayRecord) {
                        await playRecord.getDuration();
                        setState(() {});
                      } else {
                        await playRecord
                            .play(UrlSource(messages.repliedMessage));
                        isplayRecord = !isplayRecord;
                        print(isplayRecord);
                        setState(() {});
                      }
                      isplayRecord = !isplayRecord;
                    },
                    icon: isplayRecord == true
                        ? Icon(Icons.pause)
                        : Icon(Icons.play_arrow));
              })
            : messages.replayedMessageType == MessageEnum.video
                ? MessageVideoPlayer(videoUrl: messages.repliedMessage)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          messages.repliedMessage,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  );
  }
}
