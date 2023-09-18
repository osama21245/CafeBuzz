import 'package:cached_network_image/cached_network_image.dart';
import 'package:call_me/core/models/user_model.dart';
import 'package:call_me/featuers/auth/controller/auth_controller.dart';
import 'package:call_me/featuers/chats/screen/messages_screen.dart';
import 'package:call_me/featuers/user_profile/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/common/post_card.dart';

// ignore: must_be_immutable
class UserProfileScreen extends ConsumerWidget {
  String uid;
  UserProfileScreen({super.key, required this.uid});

  navigateToEditUser(BuildContext context) {
    Routemaster.of(context).push("/edit-profile/$uid");
  }

  navigateToMessages(String uid, BuildContext context, String profile,
      String karma, String name) {
    Routemaster.of(context).push("/messages/$name/$uid/$profile/$karma");
  }

  follow(WidgetRef ref, UserModel usermodel, BuildContext context) {
    ref
        .watch(userProfileControllerProvider.notifier)
        .follow(usermodel, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentuser = ref.watch(usersProvider);
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
          data: (user) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                              child: CachedNetworkImage(
                            imageUrl: user.banner,
                            fit: BoxFit.cover,
                          )),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding:
                                const EdgeInsets.all(20).copyWith(bottom: 70),
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                user.profilePic,
                              ),
                              radius: 45,
                            ),
                          ),
                          if (currentuser!.uid == uid)
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(20),
                              child: OutlinedButton(
                                onPressed: () => navigateToEditUser(context),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                ),
                                child: const Text('Edit Profile'),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'u/${user.name}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (currentuser.uid !=
                                    uid) //user.isAuthanticated != false
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MessagesScreen(
                                                    uid: user.uid,
                                                  )));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                    ),
                                    child: const Text('Messages'),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        '${user.karma} caffeine',
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        '${user.followers.isEmpty ? "0" : user.followers.length}  Followers',
                                      ),
                                    ),
                                  ],
                                ),
                                OutlinedButton(
                                  onPressed: () => follow(ref, user, context),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                  child:
                                      user.followers.contains(currentuser.uid)
                                          ? Text('Following')
                                          : Text('Follow'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(thickness: 2),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: ref.watch(getUserPostsProvider(uid)).when(
                    data: (posts) {
                      return ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return PostCard(
                              post: post,
                            );
                          });
                    },
                    error: (error, StackTrace) {
                      print(error);
                      ;
                      return ErrorText(error: error.toString());
                    },
                    loading: () => const Loader()),
              ),
          error: (error, StackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
