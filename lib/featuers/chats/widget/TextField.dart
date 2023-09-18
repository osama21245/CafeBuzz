import 'dart:io';
import 'package:call_me/core/common/loader.dart';
import 'package:call_me/featuers/chats/repositories/messages_loading.dart';
import 'package:call_me/featuers/chats/repositories/messages_reply.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/enums/message_enum.dart';
import '../../../core/utils.dart';
import '../../user_profile/controller/user_profile_controller.dart';
import '../controller/chat_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';

import 'message_replay_preview.dart';

class MssagesTextField extends ConsumerStatefulWidget {
  TextEditingController message;
  ScrollController scrollController;
  FocusNode focusNode;

  final String uid;
  MssagesTextField(
      {super.key,
      required this.message,
      required this.scrollController,
      required this.uid,
      required this.focusNode});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MssagesTextFieldState();
}

class _MssagesTextFieldState extends ConsumerState<MssagesTextField> {
  bool isShowEmojiContainer = false;
  bool isSountInit = false;
  bool? isRecord = false;
  FlutterSoundRecord? _flutterSoundRecorder;

  @override
  void initState() {
    _flutterSoundRecorder = FlutterSoundRecord();
    openAudio();
    super.initState();
  }

  @override
  void dispose() {
    _flutterSoundRecorder!.dispose();
    isSountInit = false;
    super.dispose();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Mic permission not allowed");
    }
    isSountInit = true;
  }

  void showEmoji() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void hideEmoji() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void hideKeyboard() => widget.focusNode.unfocus();
  void showKeyboard() => widget.focusNode.requestFocus();

  void toggleEmojiKeyboardContainer() {
    if (!isShowEmojiContainer) {
      hideKeyboard();
      showEmoji();
      print(isShowEmojiContainer);
    } else {
      hideEmoji();
      showKeyboard();
      print(isShowEmojiContainer);
    }
  }

  void sendMessage(
    String reciverUserId,
    BuildContext context,
  ) async {
    if (widget.message.text != "") {
      ref.watch(userProfileControllerProvider.notifier).sendText(
            widget.message.text.trim(),
            reciverUserId,
            context,
          );

      setState(() {
        widget.message.text = '';
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController
            .jumpTo(widget.scrollController.position.minScrollExtent);
      });
    } else {
      if (!isSountInit) {
        return;
      } else {
        var tempDir = await getTemporaryDirectory();
        var path = '${tempDir.path}/flutter_sound.aac';
        if (isRecord!) {
          await _flutterSoundRecorder!.stop();
          sendFile(File(path), MessageEnum.audio);
          setState(() {
            isRecord = !isRecord!;
          });
        } else {
          _flutterSoundRecorder!.start(
              path: path,
              bitRate: 192000,
              samplingRate: 48000.0,
              encoder: AudioEncoder.AAC);
          setState(() {
            isRecord = !isRecord!;
          });
        }

        // await Future.delayed(Duration(seconds: 3));
        // ref.watch(loadingProvider.notifier).update((state) => null);
      }
    }
  }

  sendFile(
    File image,
    MessageEnum messageEnum,
  ) {
    ref.watch(ChatControllerProider.notifier).sendFileMessage(
          image!,
          ref,
          widget.uid,
          messageEnum,
          context,
        );
  }

  void sendImage() async {
    ref.watch(loadingProvider.notifier).update((state) => Loading(true));
    setState(() {});
    final image = await pickImageFromGallery(context);
    if (image != null) {
      await sendFile(
        image!,
        MessageEnum.image,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController
            .jumpTo(widget.scrollController.position.minScrollExtent);
      });
    }
    await Future.delayed(Duration(seconds: 13));
    ref.watch(loadingProvider.notifier).update((state) => null);
  }

  void sendvideo() async {
    ref.watch(loadingProvider.notifier).update((state) => Loading(true));
    final video = await pickVideoFromGallery(context);
    if (video != null) {
      await sendFile(
        video!,
        MessageEnum.video,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController
            .jumpTo(widget.scrollController.position.minScrollExtent);
      });
    }
    await Future.delayed(Duration(seconds: 23));
    ref.watch(loadingProvider.notifier).update((state) => null);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final reply = ref.watch(messageReplyProvider);
    final loading = ref.watch(loadingProvider);
    bool isloading = false;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (loading != null) Loader(),
          if (reply != null)
            MessageReplyPreview(
              messageReply: reply!,
            ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  focusNode: widget.focusNode,
                  controller: widget.message,
                  onChanged: (val) {
                    if (val.isNotEmpty) {
                      setState(() {});
                    } else {
                      setState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromRGBO(27, 27, 27, 0.877),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        width: size.width * 0.14,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: toggleEmojiKeyboardContainer,
                              icon: const Icon(
                                Icons.emoji_emotions,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    suffixIcon: SizedBox(
                      width: size.width * 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => sendvideo(),
                            icon: const Icon(
                              Icons.video_camera_back_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              sendImage();
                            },
                            icon: Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                              onPressed: () => sendMessage(widget.uid, context),
                              icon: widget.message.text != ""
                                  ? Icon(
                                      Icons.send,
                                      size: 25,
                                    )
                                  : isRecord!
                                      ? Icon(
                                          Icons.close,
                                          size: 25,
                                        )
                                      : Icon(
                                          Icons.mic,
                                          size: 25,
                                        )),
                        ],
                      ),
                    ),
                    hintText: 'Type a message!',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ),
            ],
          ),
          isShowEmojiContainer
              ? SizedBox(
                  height: size.height * 0.32,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      setState(() {
                        widget.message.text = widget.message.text + emoji.emoji;
                      });
                    },
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
