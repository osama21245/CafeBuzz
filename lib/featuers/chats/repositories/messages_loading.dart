import 'package:flutter_riverpod/flutter_riverpod.dart';

class Loading {
  final bool loading;

  Loading(this.loading);
}

final loadingProvider = StateProvider<Loading?>((ref) => null);
