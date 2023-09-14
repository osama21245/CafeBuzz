// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Chats {
  final String name;
  final String profilepic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;
  Chats({
    required this.name,
    required this.profilepic,
    required this.contactId,
    required this.timeSent,
    required this.lastMessage,
  });

  Chats copyWith({
    String? name,
    String? profilepic,
    String? contactId,
    DateTime? timeSent,
    String? lastMessage,
  }) {
    return Chats(
      name: name ?? this.name,
      profilepic: profilepic ?? this.profilepic,
      contactId: contactId ?? this.contactId,
      timeSent: timeSent ?? this.timeSent,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilepic': profilepic,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
    };
  }

  factory Chats.fromMap(Map<String, dynamic> map) {
    return Chats(
      name: map['name'] as String,
      profilepic: map['profilepic'] as String,
      contactId: map['contactId'] as String,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
      lastMessage: map['lastMessage'] as String,
    );
  }

  @override
  String toString() {
    return 'Chats(name: $name, profilepic: $profilepic, contactId: $contactId, timeSent: $timeSent,  lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(covariant Chats other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.profilepic == profilepic &&
        other.contactId == contactId &&
        other.timeSent == timeSent &&
        other.lastMessage == lastMessage;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilepic.hashCode ^
        contactId.hashCode ^
        timeSent.hashCode ^
        lastMessage.hashCode;
  }
}
