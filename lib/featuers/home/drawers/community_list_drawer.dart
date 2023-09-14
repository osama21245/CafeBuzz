import 'package:cached_network_image/cached_network_image.dart';
import 'package:call_me/core/common/error_text.dart';
import 'package:call_me/core/common/loader.dart';
import 'package:call_me/core/common/sign_in_button.dart';
import 'package:call_me/core/constants/constants.dart';
import 'package:call_me/core/models/community_model.dart';

import 'package:call_me/featuers/community/controller/community_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routemaster/routemaster.dart';

import '../../auth/controller/auth_controller.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
    print(community.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(usersProvider)!;
    bool isGuest = !user.isAuthanticated;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? SignInButton(
                    isFromLogin: true,
                  )
                : ListTile(
                    title: const Text('Create a community'),
                    leading: const Icon(Icons.add),
                    onTap: () => navigateToCreateCommunity(context),
                  ),
            if (!isGuest)
              ref.watch(UserCommunityProvider).when(
                  data: (communites) => Expanded(
                        child: ListView.builder(
                            itemCount: communites.length,
                            itemBuilder: (context, index) {
                              final community = communites[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: community.avatar !=
                                          Constants.avatarDefault
                                      ? CachedNetworkImageProvider(
                                          community.avatar)
                                      : CachedNetworkImageProvider(
                                          Constants.avatarDefault),
                                ),
                                title: Text("r/${community.name}"),
                                onTap: () {
                                  navigateToCommunity(context, community);
                                },
                              );
                            }),
                      ),
                  error: (error, StackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader())
          ],
        ),
      ),
    );
  }
}
