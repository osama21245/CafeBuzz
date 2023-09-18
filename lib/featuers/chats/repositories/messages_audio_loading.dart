import 'package:call_me/featuers/chats/repositories/messages_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioLoading {
  final bool loading;

  AudioLoading(this.loading);
}

final AudioloadingProvider = StateProvider<Loading?>((ref) => null);
