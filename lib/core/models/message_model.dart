// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import '../enums/message_enum.dart';

class Message {
  final String senderId;
  final String recieverid;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum replayedMessageType;
  final String reciverUsername;

  Message({
    required this.senderId,
    required this.recieverid,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.replayedMessageType,
    required this.reciverUsername,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'recieverid': recieverid,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'replayedMessageType': replayedMessageType.type,
      'reciverUsername': reciverUsername,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] as String,
      recieverid: map['recieverid'] as String,
      text: map['text'] as String,
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
      messageId: map['messageId'] as String,
      isSeen: map['isSeen'] as bool,
      repliedMessage: map['repliedMessage'] as String,
      repliedTo: map['repliedTo'] as String,
      replayedMessageType: (map['replayedMessageType'] as String).toEnum(),
      reciverUsername: map['reciverUsername'] as String,
    );
  }

  Message copyWith({
    String? senderId,
    String? recieverid,
    String? text,
    MessageEnum? type,
    DateTime? timeSent,
    String? messageId,
    bool? isSeen,
    String? repliedMessage,
    String? repliedTo,
    MessageEnum? replayedMessageType,
    String? reciverUsername,
  }) {
    return Message(
      senderId: senderId ?? this.senderId,
      recieverid: recieverid ?? this.recieverid,
      text: text ?? this.text,
      type: type ?? this.type,
      timeSent: timeSent ?? this.timeSent,
      messageId: messageId ?? this.messageId,
      isSeen: isSeen ?? this.isSeen,
      repliedMessage: repliedMessage ?? this.repliedMessage,
      repliedTo: repliedTo ?? this.repliedTo,
      replayedMessageType: replayedMessageType ?? this.replayedMessageType,
      reciverUsername: reciverUsername ?? this.reciverUsername,
    );
  }

  @override
  String toString() {
    return 'Message(senderId: $senderId, recieverid: $recieverid, text: $text, type: $type, timeSent: $timeSent, messageId: $messageId, isSeen: $isSeen, repliedMessage: $repliedMessage, repliedTo: $repliedTo, replayedMessageType: $replayedMessageType, reciverUsername: $reciverUsername)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.senderId == senderId &&
        other.recieverid == recieverid &&
        other.text == text &&
        other.type == type &&
        other.timeSent == timeSent &&
        other.messageId == messageId &&
        other.isSeen == isSeen &&
        other.repliedMessage == repliedMessage &&
        other.repliedTo == repliedTo &&
        other.replayedMessageType == replayedMessageType &&
        other.reciverUsername == reciverUsername;
  }

  @override
  int get hashCode {
    return senderId.hashCode ^
        recieverid.hashCode ^
        text.hashCode ^
        type.hashCode ^
        timeSent.hashCode ^
        messageId.hashCode ^
        isSeen.hashCode ^
        repliedMessage.hashCode ^
        repliedTo.hashCode ^
        replayedMessageType.hashCode ^
        reciverUsername.hashCode;
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);
}
