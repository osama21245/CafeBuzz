import 'package:call_me/core/constants/constants.dart';
import 'package:call_me/featuers/auth/controller/auth_controller.dart';
import 'package:call_me/featuers/home/delegates/search_community_delegate.dart';
import 'package:call_me/theme/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:routemaster/routemaster.dart';

import '../drawers/community_list_drawer.dart';
import '../drawers/profile_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        ref
            .watch(authControllerProvider.notifier)
            .updateUserStatus(true, context);
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        ref
            .watch(authControllerProvider.notifier)
            .updateUserStatus(false, context);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  int _page = 0;
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void navigateToChats() {
    Routemaster.of(context).push("/Chats");
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(usersProvider)!;
    final currentTheme = ref.watch(themeNotiferProvider);
    bool isGuest = !user.isAuthanticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => displayDrawer(context),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: navigateToChats,
            icon: const Icon(Icons.message_rounded),
          ),
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
              onPressed: () => displayEndDrawer(context),
            );
          }),
        ],
      ),
      body: Constants.tabWidget[_page],
      drawer: const CommunityListDrawer(),
      endDrawer: isGuest ? null : ProfileDrawer(),
      bottomNavigationBar: isGuest
          ? null
          : CupertinoTabBar(
              activeColor: currentTheme.iconTheme.color,
              backgroundColor: currentTheme.backgroundColor,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: "")
              ],
              currentIndex: _page,
              onTap: onPageChanged,
            ),
    );
  }
}
