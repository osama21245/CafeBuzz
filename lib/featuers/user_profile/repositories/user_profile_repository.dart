import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:call_me/core/constants/firebase_constants.dart';

import '../../../core/enums/enums.dart';
import '../../../core/enums/message_enum.dart';
import '../../../core/faliure.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_def.dart';
import '../../chats/repositories/messages_reply.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository(firestore: ref.watch(FirestoreProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  UserProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _chats =>
      _firestore.collection(FirebaseConstants.chats);

  CollectionReference get _messages => _firestore.collection("messages");

  Future<Either> editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts.where("uid", isEqualTo: uid).snapshots().map((event) => event
        .docs
        .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<List<Chats>> getUserchats(String uid) {
    return _users.doc(uid).collection("chats").snapshots().map((event) {
      List<Chats> chats = [];
      for (var document in event.docs) {
        chats.add(Chats.fromMap(document.data()));
      }
      return chats;
    });
  }

  int messages = 15;
  Stream<List<Message>> getMessages(String uid, String reciverid) {
    return _users
        .doc(uid)
        .collection("chats")
        .doc(reciverid)
        .collection("messages")
        .orderBy("timeSent", descending: true)
        .limit(messages)
        .snapshots()
        .map((event) {
      List<Message> chats = [];
      for (var document in event.docs) {
        chats.add(Message.fromMap(document.data()));
      }
      return chats;
    });
  }

  void loadMessages() {
    messages = messages + 10;
    print(messages);
  }

  Future<Either> updateKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({"karma": user.karma}));
    } on FirebaseException catch (e) {
      throw e;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  _saveDateToChatsSubColletion(
    UserModel senderData,
    UserModel reciverData,
    String text,
    DateTime timeSent,
  ) async {
    Chats reciverChatData = Chats(
        isSeen: true,
        name: reciverData.name,
        profilepic: reciverData.profilePic,
        contactId: reciverData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await _users
        .doc(senderData.uid)
        .collection("chats")
        .doc(reciverData.uid)
        .set(reciverChatData.toMap());

    Chats senderChatData = Chats(
        isSeen: false,
        name: senderData.name,
        profilepic: senderData.profilePic,
        contactId: senderData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await _users
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
      String replayedToUsername,
      MessagesReply? messagesReply,
      String reciverUsername) async {
    Message message = Message(
        reciverUsername: reciverUsername,
        replayedMessageType: messagesReply == null
            ? MessageEnum.text
            : messagesReply.messageType,
        repliedMessage: messagesReply == null ? "" : messagesReply.message,
        repliedTo: replayedToUsername,
        senderId: senderID,
        recieverid: reciverUserID,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false);

    await _users
        .doc(senderID)
        .collection("chats")
        .doc(reciverUserID)
        .collection("messages")
        .doc(messageId)
        .set(message.toMap());

    await _users
        .doc(reciverUserID)
        .collection("chats")
        .doc(senderID)
        .collection("messages")
        .doc(messageId)
        .set(message.toMap());
  }

  Future<Either> sendTextMessage(
      String text,
      String recieverUserId,
      UserModel senderUser,
      String messageId,
      MessagesReply? messagesReply) async {
    try {
      DateTime sentTime = DateTime.now();

      UserModel reciverUserData;

      var userDataMap =
          await _firestore.collection("users").doc(recieverUserId).get();

      reciverUserData = UserModel.fromMap(userDataMap.data()!);
      _savaDataToMessagesSubColletions(
          reciverUserData.uid,
          text,
          sentTime,
          messageId,
          senderUser.name,
          MessageEnum.text,
          senderUser.uid,
          reciverUserData.name,
          messagesReply,
          reciverUserData.name);
      return right(_saveDateToChatsSubColletion(
          senderUser, reciverUserData, text, sentTime));
    } on FirebaseException catch (e) {
      throw e.toString();
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<dynamic, void>> follow(String myId, String userId) async {
    try {
      return right(await _users.doc(userId).update({
        'followers': FieldValue.arrayUnion([myId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<Either<dynamic, void>> unfollow(String myId, String userId) async {
    try {
      return right(await _users.doc(userId).update({
        'followers': FieldValue.arrayRemove([myId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
