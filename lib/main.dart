import 'package:call_me/core/common/loader.dart';
import 'package:call_me/featuers/auth/controller/auth_controller.dart';
import 'package:call_me/routes.dart';
import 'package:call_me/theme/pallete.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/common/error_text.dart';
import 'core/models/user_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
      name: "Dopamine", options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  SharedPreferences? prefs; // Declare SharedPreferences as an instance variable
  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(
        () {}); // Trigger a rebuild after SharedPreferences are initialized
  }

  @override
  void initState() {
    super.initState();
    initPrefs(); // Call the function to initialize SharedPreferences
  }

  UserModel? usermodel;

  void getData(WidgetRef ref, User data) async {
    usermodel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(usersProvider.notifier).update((state) => usermodel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateCahngeProvider).when(
        data: (data) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'CoffeeBuzz',
              theme: ref.watch(themeNotiferProvider),
              // home: Welcomescreen(),
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) {
                  if (data != null) {
                    getData(ref, data);
                    if (usermodel != null) {
                      return prefs!.getString("cycle") != "1"
                          ? splashScreenRoute
                          : loggedInRoute;
                    }
                  }
                  return loggedOutRoute;
                },
              ),
              routeInformationParser: const RoutemasterParser(),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
