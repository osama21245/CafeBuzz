import 'dart:io';

import 'package:call_me/core/faliure.dart';
import 'package:call_me/core/models/chat_model.dart';
import 'package:call_me/core/models/message_model.dart';
import 'package:call_me/core/models/user_model.dart';
import 'package:call_me/core/providers/storage_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/enums/message_enum.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_def.dart';
import 'messages_reply.dart';

Provider<ChatRepositories> ChatRepositoriesProvider = Provider((ref) =>
    ChatRepositories(
        storageRepository: ref.watch(storageRepositoryProvider),
        firestore: ref.watch(FirestoreProvider),
        auth: ref.watch(AuthProvider)));

class ChatRepositories {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final StorageRepository _storageRepository;

  ChatRepositories(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required StorageRepository storageRepository})
      : _firestore = firestore,
        _auth = auth,
        _storageRepository = storageRepository;

  _saveDateToChatsSubColletion(
    UserModel senderData,
    UserModel reciverData,
    String text,
    DateTime timeSent,
  ) async {
    Chats reciverChatData = Chats(
        name: reciverData.name,
        profilepic: reciverData.profilePic,
        contactId: reciverData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await _firestore
        .collection("users")
        .doc(senderData.uid)
        .collection("chats")
        .doc(reciverData.uid)
        .set(reciverChatData.toMap());

    Chats senderChatData = Chats(
        name: senderData.name,
        profilepic: senderData.profilePic,
        contactId: senderData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await _firestore
        .collection("users")
        .doc(reciverData.uid)
        .collection("chats")
        .doc(senderData.uid)
        .set(senderChatData.toMap());
  }

  _savaDataToMessagesSubColletions(
      String reciverUserID,
      String text,
      DateTime timeSent,
      String messageId,
      String username,
      MessageEnum messageType,
      String senderID,
      replayedToUsername,
      MessagesReply messagesReply,
      String reciverUsername) async {
    Message message = Message(
        reciverUsername: reciverUsername,
        replayedMessageType: messagesReply == null
            ? MessageEnum.text
            : messagesReply.messageType,
        repliedMessage: messagesReply.message,
        repliedTo: replayedToUsername,
        senderId: senderID,
        recieverid: reciverUserID,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false);

    await _firestore
        .collection("users")
        .doc(senderID)
        .collection("chats")
        .doc(reciverUserID)
        .collection("messages")
        .doc(messageId)
        .set(message.toMap());

    await _firestore
        .collection("users")
        .doc(reciverUserID)
        .collection("chats")
        .doc(senderID)
        .collection("messages")
        .doc(messageId)
        .set(message.toMap());
  }

  FutureVoid sendFileMessage(
      {required File file,
      required String recieverUserId,
      required UserModel senderUserData,
      required WidgetRef ref,
      required MessageEnum messageEnum,
      required MessagesReply messagesReply}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      final imageUrl = await _storageRepository.storeFile2(
        path: 'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId',
        id: messageId,
        file: file,
      );

      UserModel? recieverUserData;
      var userDataMap =
          await _firestore.collection('users').doc(recieverUserId).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }
      _saveDateToChatsSubColletion(
        senderUserData,
        recieverUserData!,
        contactMsg,
        timeSent,
      );

      return right(_savaDataToMessagesSubColletions(
          recieverUserData.uid,
          imageUrl.toString(),
          timeSent,
          messageId,
          senderUserData.name,
          messageEnum,
          senderUserData.uid,
          recieverUserData.name,
          messagesReply,
          recieverUserData.name));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateSeen(
      String senderID, String reciverUserID, String messageId) async {
    try {
      await _firestore
          .collection("users")
          .doc(senderID)
          .collection("chats")
          .doc(reciverUserID)
          .collection("messages")
          .doc(messageId)
          .update({"isSeen": true});

      return right(await _firestore
          .collection("users")
          .doc(reciverUserID)
          .collection("chats")
          .doc(senderID)
          .collection("messages")
          .doc(messageId)
          .update({"isSeen": true}));
    } on FirebaseException catch (e) {
      throw e.toString();
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
