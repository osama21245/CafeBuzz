import 'dart:io';

import 'package:call_me/core/common/error_text.dart';
import 'package:call_me/core/common/loader.dart';
import 'package:call_me/core/constants/constants.dart';

import 'package:call_me/featuers/auth/controller/auth_controller.dart';
import 'package:call_me/featuers/community/controller/community_controller.dart';
import 'package:call_me/featuers/user_profile/controller/user_profile_controller.dart';
import 'package:call_me/theme/pallete.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';

class EditprofileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditprofileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditprofileScreenState();
}

class _EditprofileScreenState extends ConsumerState<EditprofileScreen> {
  File? bannerFile;
  File? profileFile;
  late TextEditingController nameController;

  @override
  void initState() {
    nameController = TextEditingController(text: ref.read(usersProvider)!.name);

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void selectBannerImage() async {
    final res = await picImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await picImage();

    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  void save() {
    ref.read(userProfileControllerProvider.notifier).editProfile(
        profileFile: profileFile,
        bannerFile: bannerFile,
        context: context,
        name: nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    //  String decodedname = Uri.decodeComponent(widget.name);
    bool loading = ref.watch(userProfileControllerProvider);
    final currentMode = ref.watch(themeNotiferProvider);

    return ref.watch(getUserDataProvider(widget.uid)).when(
        data: (user) => Scaffold(
              backgroundColor: currentMode.backgroundColor,
              appBar: AppBar(
                title: Text("Edit Community"),
                actions: [TextButton(onPressed: save, child: Text("Save"))],
              ),
              body: loading
                  ? Loader()
                  : Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: selectBannerImage,
                                  child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(10),
                                      dashPattern: [10, 4],
                                      strokeCap: StrokeCap.round,
                                      color: currentMode
                                          .textTheme.bodyText2!.color!,
                                      child: Container(
                                        width: double.infinity,
                                        height: 150,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: bannerFile != null
                                            ? Image.file(bannerFile!)
                                            : user.banner.isEmpty ||
                                                    user.banner ==
                                                        Constants.bannerDefault
                                                ? Center(
                                                    child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 40,
                                                  ))
                                                : Image.network(user.banner),
                                      )),
                                ),
                                Positioned(
                                    bottom: 20,
                                    left: 20,
                                    child: InkWell(
                                        onTap: selectProfileImage,
                                        child: profileFile != null
                                            ? CircleAvatar(
                                                radius: 32,
                                                backgroundImage:
                                                    FileImage(profileFile!))
                                            : user.profilePic !=
                                                    Constants.avatarDefault
                                                ? CircleAvatar(
                                                    radius: 32,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            user.profilePic),
                                                  )
                                                : CircleAvatar(
                                                    radius: 32,
                                                    backgroundImage:
                                                        NetworkImage(Constants
                                                            .avatarDefault),
                                                  )))
                              ],
                            ),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(18),
                                filled: true,
                                hintText: "name",
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                    ),
                                    borderRadius: BorderRadius.circular(10))),
                          )
                        ],
                      ),
                    ),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
