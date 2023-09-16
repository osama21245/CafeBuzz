import 'dart:io';

import 'package:call_me/core/constants/constants.dart';
import 'package:call_me/core/faliure.dart';
import 'package:call_me/core/providers/storage_repository.dart';
import 'package:call_me/featuers/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/models/community_model.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils.dart';
import '../repositories/community_repository.dart';

StateNotifierProvider<CommunityController, bool> communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(CommunityRepositoryProvider);
  return CommunityController(
      communityRepository: communityRepository,
      ref: ref,
      storageRepository: ref.watch(storageRepositoryProvider));
});

final getComunityPostsProvider =
    StreamProvider.family((ref, String communityName) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getComuunitPosts(communityName);
});

final UserCommunityProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserComuunities();
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;

    final uid = _ref.read(usersProvider)?.uid ?? "";
    Community community = Community(
        id: name,
        name: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        members: [uid],
        mods: [uid]);

    final res = await _communityRepository.createCommunity(community);

    state = false;
    res.fold((l) => showSnackBar(l.message, context), (r) {
      showSnackBar("community Created Successfuly!", context);
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> getUserComuunities() {
    final uid = _ref.read(usersProvider)?.uid ?? "";
    return _communityRepository.getUserComuunities(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity(
      {required File? profileFile,
      required File? bannerFile,
      required BuildContext context,
      required Community community}) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
          path: "communities/profile", id: community.name, file: profileFile);

      res.fold((l) => showSnackBar(l.toString(), context),
          (r) => community = community.copyWith(avatar: r));
    }
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          path: "communities/banner", id: community.name, file: bannerFile);

      res.fold((l) => showSnackBar(l.toString(), context),
          (r) => community = community.copyWith(banner: r));
    }

    final res = await _communityRepository.editCommunity(community);
    state = false;

    res.fold((l) => showSnackBar(l.message, context),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(usersProvider)!;

    var res;
    if (community.members.contains(user.uid)) {
      res =
          (await _communityRepository.leaveCommunity(community.name, user.uid));
    } else {
      res =
          (await _communityRepository.joinCommunity(community.name, user.uid));
    }

    res.fold((l) => showSnackBar(l.message, context), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar('Community left successfully!', context);
      } else {
        showSnackBar('Community joined successfully!', context);
      }
    });
  }

  void addMod(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMod(communityName, uids);

    res.fold((l) => showSnackBar(l.message, context),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Post>> getComuunitPosts(String uid) {
    return _communityRepository.getCommunityPosts(uid);
  }
}
