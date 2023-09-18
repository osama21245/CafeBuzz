import 'package:cached_network_image/cached_network_image.dart';
import 'package:call_me/featuers/chats/controller/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/call.dart';
import 'call_screen.dart';

class CallPickupScreen extends ConsumerStatefulWidget {
  Widget scaffold;
  CallPickupScreen({super.key, required this.scaffold});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CallPickupScreenState();
}

class _CallPickupScreenState extends ConsumerState<CallPickupScreen> {
  @override
  void initState() {
    super.initState();
  }

  void endCall(WidgetRef ref, BuildContext context, String reciverId) {
    ref.watch(ChatControllerProider.notifier).endCall(context, reciverId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: ref.watch(ChatControllerProider.notifier).getCalls(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            print(snapshot.data!.data());
            Call callerData =
                Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            if (callerData.hasDialled) {
              return Scaffold(
                body: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Incoming Call',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 50),
                      CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(callerData.receiverPic),
                        radius: 60,
                      ),
                      const SizedBox(height: 50),
                      Text(
                        callerData.receiverName,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 75),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () =>
                                endCall(ref, context, callerData.receiverId),
                            icon: const Icon(Icons.call_end,
                                color: Colors.redAccent),
                          ),
                          const SizedBox(width: 25),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CallScreen(
                                    channelId: callerData.callId,
                                    call: callerData,
                                    isGroupChat: false,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.call,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          }
          return widget.scaffold;
        });
  }
}
