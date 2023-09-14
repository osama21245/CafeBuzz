import 'package:call_me/featuers/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'animated_splash_screen.dart';
import 'featuers/chats/screen/chats_screen.dart';
import 'featuers/chats/screen/messages_screen.dart';
import 'featuers/community/screens/add_mods_screen.dart';
import 'featuers/community/screens/community_screen.dart';
import 'featuers/community/screens/create_community_screen.dart';
import 'featuers/community/screens/edit_community_screen.dart';
import 'featuers/community/screens/mod_tools_screen.dart';
import 'featuers/home/screens/home_screen.dart';
import 'featuers/post/screens/add_post_type_screen.dart';
import 'featuers/post/screens/comments_screen.dart';
import 'featuers/user_profile/screens/edit_profile_screen.dart';
import 'featuers/user_profile/screens/user_profile_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  "/": (_) => MaterialPage(child: LoginScreen()),
});

final splashScreenRoute =
    RouteMap(routes: {"/": (_) => MaterialPage(child: SplashScreen())});

final loggedInRoute = RouteMap(routes: {
  "/": (_) => MaterialPage(child: HomeScreen()),
  '/create-community': (_) => MaterialPage(child: CreateCommunityScreen()),
  '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
        name: route.pathParameters['name']!,
      )),
  '/mod-tools/:name': (routeData) => MaterialPage(
          child: ModToolsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/edit-community/:name': (routeData) => MaterialPage(
          child: EditCommunityScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/add-mods/:name': (routeData) => MaterialPage(
        child: AddModsScreen(
          name: routeData.pathParameters['name']!,
        ),
      ),
  '/u/:uid': (routeData) => MaterialPage(
        child: UserProfileScreen(
          uid: routeData.pathParameters['uid']!,
        ),
      ),
  '/edit-profile/:uid': (routeData) => MaterialPage(
        child: EditprofileScreen(
          uid: routeData.pathParameters['uid']!,
        ),
      ),
  '/add-post/:type': (routeData) => MaterialPage(
        child: AddPostTypeScreen(
          type: routeData.pathParameters['type']!,
        ),
      ),
  '/post/:postId/comments': (routeData) => MaterialPage(
        child: CommentsScreen(
          postId: routeData.pathParameters['postId']!,
        ),
      ),
  // '/messages/:name/:uid/:profile/:karma': (routeData) => MaterialPage(
  //       child: MessagesScreen(
  //         name: routeData.pathParameters['name']!,
  //         uid: routeData.pathParameters['uid']!,
  //         profile: routeData.pathParameters['profile']!,
  //       ),
  //     ),
  '/Chats': (routeData) => MaterialPage(
        child: ChatScreen(),
      ),
});
