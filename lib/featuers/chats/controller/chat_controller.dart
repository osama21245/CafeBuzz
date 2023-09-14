import 'dart:io';

import 'package:call_me/core/enums/message_enum.dart';
import 'package:call_me/featuers/auth/controller/auth_controller.dart';
import 'package:call_me/featuers/chats/repositories/messages_reply.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/storage_repository.dart';
import '../../../core/utils.dart';
import '../repositories/chat_repositories.dart';

// final getMessagesProvider = StreamProvider.family((ref, String reciverId) {
//   return ref.watch(ChatControllerProider.notifier).getMessages(reciverId);
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

  void sendFileMessage(File file, WidgetRef ref, String recieverUserId,
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
}
