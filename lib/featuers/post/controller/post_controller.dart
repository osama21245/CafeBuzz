import 'dart:io';
import 'package:call_me/core/enums/enums.dart';
import 'package:call_me/featuers/post/repositories/post_repository.dart';
import 'package:call_me/featuers/user_profile/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/comment_model.dart';
import '../../../core/models/community_model.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/post_model.dart';
import '../../../core/providers/storage_repository.dart';
import '../../../core/utils.dart';
import '../../auth/controller/auth_controller.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(PostRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});
final getPostsProvider =
    StreamProvider.family((ref, List<Community> community) {
  final controller = ref.watch(postControllerProvider.notifier);
  return controller.showPosts(community);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});
final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(usersProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updataKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(l.message, context), (r) {
      showSnackBar('Posted successfully!', context);
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(usersProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updataKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnackBar(l.message, context), (r) {
      showSnackBar('Posted successfully!', context);
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(usersProvider)!;
    final imageRes = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
    );

    imageRes.fold((l) => showSnackBar(l.toString(), context), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: r,
      );

      final res = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updataKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnackBar(l.message, context), (r) {
        showSnackBar('Posted successfully!', context);
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> showPosts(List<Community> community) {
    if (community.isNotEmpty) {
      return _postRepository.showPosts(community);
    }
    return Stream.value([]);
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post.id);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updataKarma(UserKarma.deletePost);
    res.fold((l) => null,
        (r) => showSnackBar('Post Deleted successfully!', context));
  }

  void upvote(Post post) async {
    final uid = _ref.read(usersProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  void downvote(Post post) async {
    final uid = _ref.read(usersProvider)!.uid;
    _postRepository.downvote(post, uid);
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
    final postController = ref.watch(postControllerProvider.notifier);
    return postController.fetchPostComments(postId);
  });

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(usersProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      username: user.name,
      profilePic: user.profilePic,
    );
    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updataKarma(UserKarma.comment);
    res.fold((l) => showSnackBar(l.message, context), (r) => null);
  }

  void addAwards(String award, Post post, BuildContext context) async {
    final senderId = _ref.read(usersProvider)!.uid;
    final res = await _postRepository.addAward(post, award, senderId);

    res.fold((l) => showSnackBar(l.toString(), context), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updataKarma(UserKarma.awardPost);
      _ref.read(usersProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
