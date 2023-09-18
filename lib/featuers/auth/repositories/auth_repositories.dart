import 'package:call_me/core/constants/constants.dart';
import 'package:call_me/core/faliure.dart';
import 'package:call_me/core/providers/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/type_def.dart';

final Provider<AuthRepository> AuthRepositoryProvider = Provider((ref) =>
    AuthRepository(
        firestore: ref.read(FirestoreProvider),
        auth: ref.read(AuthProvider),
        googleSignIn: ref.read(GoogleProvider)));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signinWithGoogle(bool isFromLogin) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: (googleAuth).accessToken, idToken: (googleAuth).idToken);
      UserCredential userCredential;

      if (isFromLogin) {
        userCredential = await _auth.signInWithCredential(credential);
      } else {
        userCredential =
            await _auth.currentUser!.linkWithCredential(credential);
      }

      UserModel userModel;
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
            ingroup: [],
            isonline: false,
            name: userCredential.user!.displayName ?? "No Name",
            profilePic:
                userCredential.user!.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthanticated: true,
            karma: 0,
            followers: [],
            awards: ['gold']);
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();

      UserModel userModel = UserModel(
          followers: [],
          name: 'Guest',
          profilePic: Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthanticated: false,
          karma: 0,
          awards: [],
          isonline: false,
          ingroup: []);

      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  FutureVoid updateUserState(String uid, bool isonline) async {
    try {
      if (isonline == true) {
        return right(_users.doc(uid).update({"isonline": isonline}));
      } else {
        return right(_users.doc(uid).update({"isonline": isonline}));
      }
    } on FirebaseException catch (e) {
      throw e;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
