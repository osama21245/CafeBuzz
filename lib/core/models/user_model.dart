// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String name;
  final String profilePic;
  final String banner;
  final String uid;
  final bool isAuthanticated;
  final int karma;
  final bool isonline;
//  final List<String> ingroup;
  final List<String> awards;
  UserModel({
    required this.name,
    required this.profilePic,
    required this.banner,
    required this.uid,
    required this.isAuthanticated,
    required this.karma,
    required this.isonline,
    //required this.ingroup,
    required this.awards,
  });

  UserModel copyWith({
    String? name,
    String? profilePic,
    String? banner,
    String? uid,
    bool? isAuthanticated,
    int? karma,
    bool? isonline,
    //  List<String>? ingroup,
    List<String>? awards,
  }) {
    return UserModel(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      uid: uid ?? this.uid,
      isAuthanticated: isAuthanticated ?? this.isAuthanticated,
      karma: karma ?? this.karma,
      isonline: isonline ?? this.isonline,
      // ingroup: ingroup ?? this.ingroup,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'banner': banner,
      'uid': uid,
      'isAuthanticated': isAuthanticated,
      'karma': karma,
      'isonline': isonline,
      //'ingroup': ingroup,
      'awards': awards,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    List<dynamic> awards = map['awards'] as List<dynamic>;

    // Convert the List<dynamic> to List<String>
    List<String> awardslist = awards.cast<String>();

    // List<dynamic> ingroup = map['ingroup'] as List<dynamic>;

    // // Convert the List<dynamic> to List<String>
    // List<String> ingrouplist = ingroup.cast<String>();

    return UserModel(
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      banner: map['banner'] as String,
      uid: map['uid'] as String,
      isAuthanticated: map['isAuthanticated'] as bool,
      karma: map['karma'] as int,
      isonline: map['isonline'] as bool,
      //  ingroup: ingrouplist,
      awards: awardslist,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, banner: $banner, uid: $uid, isAuthanticated: $isAuthanticated, karma: $karma, isonline: $isonline, , awards: $awards)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.profilePic == profilePic &&
        other.banner == banner &&
        other.uid == uid &&
        other.isAuthanticated == isAuthanticated &&
        other.karma == karma &&
        other.isonline == isonline &&
        // listEquals(other.ingroup, ingroup) &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilePic.hashCode ^
        banner.hashCode ^
        uid.hashCode ^
        isAuthanticated.hashCode ^
        karma.hashCode ^
        isonline.hashCode ^
        //   ingroup.hashCode ^
        awards.hashCode;
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
