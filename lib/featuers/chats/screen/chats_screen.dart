import 'package:cached_network_image/cached_network_image.dart';
import 'package:call_me/featuers/auth/controller/auth_controller.dart';
import 'package:call_me/featuers/chats/controller/chat_controller.dart';
import 'package:call_me/featuers/user_profile/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import 'messages_screen.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void navigateToUserProfile(BuildContext context, String uid) {
      Routemaster.of(context).push('/u/$uid');
    }

    final user = ref.watch(usersProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user!.profilePic),
              ),
              onPressed: () {
                if (user.isAuthanticated != false)
                  navigateToUserProfile(context, user.uid);
              },
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ref.watch(getUserChatsProvider(user!.uid)).when(
                data: (data) {
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final chats = data[index];
                        final timesent = DateFormat.Hm().format(chats.timeSent);
                        return ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MessagesScreen(
                                      uid: chats.contactId,
                                    )));
                          },
                          leading: InkWell(
                            onTap: () =>
                                navigateToUserProfile(context, chats.contactId),
                            child: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                chats.profilepic,
                              ),
                              radius: 23,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(chats.name),
                              SizedBox(
                                width: 6,
                              ),
                              Text(
                                timesent,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              )
                            ],
                          ),
                          subtitle: Text(chats.lastMessage),
                          trailing: Icon(Icons.more_vert),
                        );
                      });
                },
                error: (error, StackTrace) {
                  print(error);

                  return ErrorText(error: error.toString());
                },
                loading: () => const Loader()),
          ),
        ],
      ),
    );
  }
}
