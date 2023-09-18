import 'dart:io';

import 'package:call_me/core/enums/message_enum.dart';
import 'package:call_me/featuers/auth/controller/auth_controller.dart';
import 'package:call_me/featuers/chats/repositories/messages_reply.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/call.dart';
import '../../../core/providers/storage_repository.dart';
import '../../../core/utils.dart';
import '../repositories/chat_repositories.dart';
import '../widget/call_screen.dart';

// final getCallsProvider = StreamProvider((ref) {
//   return ref.watch(ChatControllerProider.notifier).getCalls();
// });

StateNotifierProvider<ChatController, bool> ChatControllerProider =
    StateNotifierProvider<ChatController, bool>((ref) => ChatController(
        storageRepository: ref.watch(storageRepositoryProvider),
        chatRepositories: ref.watch(ChatRepositoriesProvider),
        ref: ref));

class ChatController extends StateNotifier<bool> {
  ChatRepositories _chatRepositories;
  Ref _ref;
  StorageRepository _storageRepository;

  ChatController(
      {required ChatRepositories chatRepositories,
      required Ref ref,
      required StorageRepository storageRepository})
      : _chatRepositories = chatRepositories,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  sendFileMessage(File file, WidgetRef ref, String recieverUserId,
      MessageEnum messageEnum, BuildContext context) async {
    final senderUserData = _ref.watch(usersProvider);
    var messagesReply = ref.read(messageReplyProvider);

    if (messagesReply == null) {
      messagesReply = MessagesReply("", false, MessageEnum.text);
    }

    final res = await _chatRepositories.sendFileMessage(
      messagesReply: messagesReply,
      file: file,
      recieverUserId: recieverUserId,
      senderUserData: senderUserData!,
      ref: ref,
      messageEnum: messageEnum,
    );

    res.fold((l) => showSnackBar(l.message, context), (r) => null);
  }

  void updateSeen(String reciverUserID, String messageId) {
    final senderID = _ref.read(usersProvider)!.uid;
    _chatRepositories.updateSeen(senderID, reciverUserID, messageId);
  }

  void makeCall(String receiverId, String receiverName, String receiverPic,
      BuildContext context) async {
    final user = _ref.read(usersProvider)!;
    final callId = Uuid().v1();
    Call callerData = Call(
        callerId: user.uid,
        callerName: user.name,
        callerPic: user.profilePic,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverPic: receiverPic,
        callId: callId,
        hasDialled: false);
    Call reciverCallData = Call(
        callerId: receiverId,
        callerName: receiverName,
        callerPic: receiverPic,
        receiverId: user.uid,
        receiverName: user.name,
        receiverPic: user.profilePic,
        callId: callId,
        hasDialled: true);

    final res = await _chatRepositories.makeCall(callerData, reciverCallData);

    res.fold(
        (l) => showSnackBar(l.message, context),
        (r) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallScreen(
                  channelId: callerData.callId,
                  call: callerData,
                  isGroupChat: false,
                ),
              ),
            ));
  }

  void endCall(BuildContext context, String reciverCallId) async {
    final callerId = _ref.read(usersProvider)!.uid;

    final res = await _chatRepositories.endCall(callerId, reciverCallId);

    res.fold((l) => showSnackBar(l.message, context), (r) => null);
  }

  Stream<DocumentSnapshot> getCalls() {
    final uid = _ref.watch(usersProvider)!.uid;
    return _chatRepositories.getcalls(uid);
  }

  void ChatScreenSeen(String reciverId, BuildContext context) async {
    final senderId = _ref.read(usersProvider)!.uid;
    final res = await _chatRepositories.ChatScreenSeen(senderId, reciverId);

    res.fold((l) => showSnackBar(l.message, context), (r) => null);
  }
}
