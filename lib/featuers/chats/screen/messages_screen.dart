import 'package:call_me/featuers/chats/screen/widget/TextField.dart';
import 'package:call_me/featuers/chats/screen/widget/messges.dart';
import 'package:call_me/featuers/user_profile/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';

import 'package:call_me/featuers/auth/controller/auth_controller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  final String uid;

  const MessagesScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  bool isloading = false;
  final message = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    message.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          !scrollController.position.pixels.isNegative) {
        ref.watch(userProfileControllerProvider.notifier).loadMessages();
        setState(() {});
        print("done");
      }
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   scrollController.jumpTo(scrollController.position.maxScrollExtent);
    // });
  }

  @override
  Widget build(BuildContext context) {
    // final currentTheme = ref.watch(themeNotiferProvider);
    // bool isGuest = !user.isAuthanticated;
    // Size size = MediaQuery.of(context).size;
    // bool imageloading = ref.watch(ChatControllerProider);

    return Scaffold(
      appBar: ref.watch(getUserDataProvider(widget.uid)).when(data: (user) {
        return AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.name}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Text('${user.isonline == true ? "online" : "offline"}',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  SizedBox(
                    width: 5,
                  ),
                  if (user.isonline)
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: Colors.green,
                    )
                ],
              )
            ],
          ),
          centerTitle: false,
          actions: [
            Builder(builder: (context) {
              return IconButton(
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                ),
                onPressed: () {},
              );
            }),
          ],
        );
      }, error: (error, StackTrace) {
        print(error);
        ;
        ErrorText(error: error.toString());
      }, loading: () {
        Loader();
      }),
      body: Column(
        children: [
          MessageBubble(
            scrollController: scrollController,
            uid: widget.uid,
          ),
          MssagesTextField(
            message: message,
            scrollController: scrollController,
            uid: widget.uid,
          )
        ],
      ),
    );
  }
}
