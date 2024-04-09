import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/group/controllers/group_creation_controller.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/image_view/views/image_view_view.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';

class GroupCreationView extends StatefulWidget {
  const GroupCreationView({super.key,this.enableAppBar=true});
  final bool enableAppBar;
  @override
  State<GroupCreationView> createState() => _GroupCreationViewState();
}

class _GroupCreationViewState extends State<GroupCreationView> {
  final controller = Get.put(GroupCreationController());
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    Get.delete<GroupCreationController>();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: widget.enableAppBar ? AppBar(
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
        automaticallyImplyLeading: true,
        actionsIconTheme: IconThemeData(
            color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                iconColor),
        iconTheme: IconThemeData(
            color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                iconColor),
        title: Text(
          AppConstants.newGroup,style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar)),
        actions: [
          TextButton(
              onPressed: () => controller.goToAddParticipantsPage(context),
              child: Text(
                AppConstants.next.toUpperCase(), style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),)),
        ],
      ):null,
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (controller.showEmoji.value) {
            controller.showEmoji(false);
          } else {
            Navigator.pop(context);
          }
        },
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18.0,
                        horizontal: 18.0,
                      ),
                      child: Obx(
                            () =>
                            InkWell(
                              child: controller.imagePath.value.isNotEmpty
                                  ? SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: ClipOval(
                                    child: Image.file(
                                      File(controller.imagePath.value),
                                      fit: BoxFit.fill,
                                    ),
                                  ))
                                  : ImageNetwork(
                                url: controller.userImgUrl.value.checkNull(),
                                width: 150,
                                height: 150,
                                clipOval: true,
                                errorWidget: ClipOval(
                                  child: Image.asset(groupImg,package: package,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover),
                                ),
                                isGroup: true,
                                blocked: false,
                                unknown: false,
                              ),
                              onTap: () {
                                if (controller.imagePath.value
                                    .checkNull()
                                    .isNotEmpty) {
                                  Navigator.push(context, MaterialPageRoute(builder: (con)=>ImageViewView(imageName: controller.groupName.text,imagePath: controller.imagePath.value.checkNull(),)));
                                  /*Get.toNamed(Routes.imageView, arguments: {
                                    'imageName': controller.groupName.text,
                                    'imagePath':
                                    controller.imagePath.value.checkNull()
                                  });*/
                                } else if (controller.userImgUrl.value
                                    .checkNull()
                                    .isNotEmpty) {
                                  Navigator.push(context, MaterialPageRoute(builder: (con)=>ImageViewView(imageName: controller.groupName.text,imageUrl: controller.userImgUrl.value.checkNull(),)));
                                  /*Get.toNamed(Routes.imageView, arguments: {
                                    'imageName': controller.groupName.text,
                                    'imageUrl':
                                    controller.userImgUrl.value.checkNull()
                                  });*/
                                } else {
                                  controller.choosePhoto(context);
                                }
                              },
                            ),
                      ),
                    ),
                    Obx(
                          () =>
                          Positioned(
                            right: 18,
                            bottom: 18,
                            child: InkWell(
                              onTap: controller.loading.value
                                  ? null
                                  : () {
                                controller.choosePhoto(context);
                              },
                              child: Image.asset(
                                cameraProfileChange,package: package,
                                height: 40,
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0, right: 20),
                      child: TextField(
                        focusNode: controller.focusNode,
                        keyboardAppearance: MirrorflyUikit.theme == "dark" ? Brightness.dark : Brightness.light,
                        style:
                        TextStyle(fontSize: 14,
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.visible, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                        onChanged: (_) => controller.onGroupNameChanged(),
                        maxLength: 25,
                        maxLines: 1,
                        cursorColor: MirrorflyUikit.getTheme?.primaryColor,
                        controller: controller.groupName,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: Constants.emptyString,
                            hintText: AppConstants.typeGroupName, hintStyle: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor)),
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Obx(
                              () =>
                              Text(
                                controller.count.toString(),
                                style: TextStyle(fontSize: 14,
                                    fontWeight: FontWeight.normal, color: MirrorflyUikit.getTheme?.textSecondaryColor),
                              ),
                        ),
                      )),
                  Obx(() {
                    return IconButton(
                        onPressed: () {
                          controller.showHideEmoji(context);
                        },
                        icon: controller.showEmoji.value ? Icon(
                          Icons.keyboard, color: MirrorflyUikit.getTheme?.secondaryColor,) : SvgPicture.asset(
                          smileIcon,package: package, width: 18, height: 18, colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.secondaryColor, BlendMode.srcIn)));
                  })
                ],
              ),
              const AppDivider(),
              const SizedBox(height: 20,),
              Text(AppConstants.provideGroupNameIcon,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: MirrorflyUikit.getTheme?.textPrimaryColor),),
              Expanded(
                child: Obx(() {
                  if (controller.showEmoji.value) {
                    return EmojiLayout(
                      textController: TextEditingController(),
                      onBackspacePressed: () => controller.onEmojiBackPressed(),
                      onEmojiSelected: (cat, emoji) => controller.onEmojiSelected(emoji),
                    );
                  } else {
                    return const Offstage();
                  }
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
