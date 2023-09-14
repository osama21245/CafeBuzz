import 'dart:io';

import 'package:call_me/core/common/error_text.dart';
import 'package:call_me/core/common/loader.dart';
import 'package:call_me/core/constants/constants.dart';
import 'package:call_me/core/models/community_model.dart';
import 'package:call_me/featuers/community/controller/community_controller.dart';
import 'package:call_me/theme/pallete.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({Key? key, required this.name}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;
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

  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
        profileFile: profileFile,
        bannerFile: bannerFile,
        context: context,
        community: community);
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(themeNotiferProvider);
    String decodedname = Uri.decodeComponent(widget.name);
    bool loading = ref.watch(communityControllerProvider);
    return ref.watch(getCommunityByNameProvider(decodedname)).when(
        data: (community) => Scaffold(
              backgroundColor: currentMode.backgroundColor,
              appBar: AppBar(
                title: Text("Edit Community"),
                actions: [
                  TextButton(
                      onPressed: () {
                        save(community);
                      },
                      child: Text("Save"))
                ],
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
                                            : community.banner.isEmpty ||
                                                    community.banner ==
                                                        Constants.bannerDefault
                                                ? Center(
                                                    child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 40,
                                                  ))
                                                : Image.network(
                                                    community.banner),
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
                                            : community.avatar !=
                                                    Constants.avatarDefault
                                                ? CircleAvatar(
                                                    radius: 32,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            community.avatar),
                                                  )
                                                : CircleAvatar(
                                                    radius: 32,
                                                    backgroundImage:
                                                        NetworkImage(Constants
                                                            .avatarDefault),
                                                  )))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
