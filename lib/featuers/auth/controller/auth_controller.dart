import 'package:call_me/core/models/user_model.dart';
import 'package:call_me/featuers/auth/repositories/auth_repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';

final authStateCahngeProvider = StreamProvider((ref) {
  final authcontroller = ref.watch(authControllerProvider.notifier);
  return authcontroller.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authcontroller = ref.watch(authControllerProvider.notifier);
  return authcontroller.getUserData(uid);
});

StateProvider<UserModel?> usersProvider =
    StateProvider<UserModel?>((ref) => null);

StateNotifierProvider<AuthController, bool> authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) => AuthController(
        authRepository: ref.watch(AuthRepositoryProvider), ref: ref));

class AuthController extends StateNotifier<bool> {
  final Ref _ref;
  final AuthRepository _authRepository;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  signinWithGoogle(BuildContext context, bool isFromLogin) async {
    state = true;
    final user = await _authRepository.signinWithGoogle(isFromLogin);
    state = false;

    user.fold((l) => showSnackBar(l.message, context), (userModel) async {
      _ref.read(usersProvider.notifier).update((state) => userModel);
    });
  }

  void signInAsGuest(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInAsGuest();
    state = false;

    user.fold((l) => showSnackBar(l.message, context), (userModel) async {
      _ref.read(usersProvider.notifier).update((state) => userModel);
    });
  }

  void logOut() async {
    _authRepository.logOut();
  }

  void updateUserStatus(bool isonline, BuildContext context) async {
    final uid = _ref.read(usersProvider)!.uid;
    final res = await _authRepository.updateUserState(uid, isonline);
    res.fold((l) => showSnackBar(l.message, context), (r) => null);
  }
}
