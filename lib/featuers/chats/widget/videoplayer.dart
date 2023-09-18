import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';

class MessageVideoPlayer extends StatefulWidget {
  String videoUrl;
  MessageVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<MessageVideoPlayer> createState() => _MessageVideoPlayerState();
}

class _MessageVideoPlayerState extends State<MessageVideoPlayer> {
  bool isplay = false;
  CachedVideoPlayerController? cachedVideoPlayerController;

  @override
  void initState() {
    cachedVideoPlayerController =
        CachedVideoPlayerController.network(widget.videoUrl)
          ..initialize().then((value) {
            cachedVideoPlayerController!.setVolume(1.0);
          });
    super.initState();
  }

  @override
  void dispose() {
    cachedVideoPlayerController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isplay == true) {
          cachedVideoPlayerController!.pause();
        } else {
          cachedVideoPlayerController!.play();
        }
        setState(() {
          isplay = !isplay;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 5 / 5,
          child: Stack(
            children: [
              CachedVideoPlayer(cachedVideoPlayerController!),
              Center(
                child: Visibility(
                  visible: !isplay,
                  child: Icon(isplay ? Icons.pause_circle : Icons.play_circle),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
