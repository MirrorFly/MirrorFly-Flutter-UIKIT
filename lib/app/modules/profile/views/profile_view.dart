import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/image_view/views/image_view_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/profile/views/status_list_view.dart';
import 'package:mirrorfly_uikit_plugin/app/routes/app_pages.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/widgets.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  var controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        if (!KeyboardVisibilityController().isVisible) {
          if (controller.userNameFocus.hasFocus) {
            controller.userNameFocus.unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              controller.userNameFocus.requestFocus();
            });
          } else if (controller.emailFocus.hasFocus) {
            controller.emailFocus.unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              controller.emailFocus.requestFocus();
            });
          }
        }
      },
      child: Scaffold(
          backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
          appBar: AppBar(
            title: Text(
              'Profile', style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar)
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
            backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
            automaticallyImplyLeading: controller.from.value == Routes.login ? false : true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Obx(
                                () {
                                  debugPrint("controller.userImgUrl.value ${controller.userImgUrl.value}");
                                  return InkWell(
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
                                      errorWidget: controller.profileName.text.checkNull()
                                          .isNotEmpty
                                          ? ProfileTextImage(
                                        fontSize: 40,
                                        bgColor: buttonBgColor,
                                        text: controller.profileName.text.checkNull(),
                                        radius: 75,
                                      )
                                          : null,
                                      isGroup: false,
                                      blocked: false,
                                      unknown: false,
                                    ),
                                    onTap: () {
                                      if (controller.imagePath.value
                                          .checkNull()
                                          .isNotEmpty) {
                                        // Get.toNamed(Routes.imageView, arguments: {
                                        //   'imageName': controller.profileName.text,
                                        //   'imagePath': controller.imagePath.value.checkNull()
                                        // });
                                        Navigator.push(context, MaterialPageRoute(builder: (con)=> ImageViewView(imageName: controller.profileName.text, imagePath: controller.imagePath.value.checkNull())));
                                      } else if (controller.userImgUrl.value
                                          .checkNull()
                                          .isNotEmpty) {
                                        // Get.toNamed(Routes.imageView, arguments: {
                                        //   'imageName': controller.profileName.text,
                                        //   'imageUrl': controller.userImgUrl.value.checkNull()
                                        // });
                                        Navigator.push(context, MaterialPageRoute(builder: (con)=> ImageViewView(imageName: controller.profileName.text, imageUrl: controller.userImgUrl.value.checkNull())));

                                      }
                                    },
                                  );
                                }),
                            ),
                          ),
                          Obx(
                            () => Positioned(
                              right: 10,
                              bottom: 10,
                              child: InkWell(
                                onTap: controller.loading.value
                                    ? null
                                    : () {
                                        bottomSheetView(context);
                                      },
                                child: Image.asset(
                                  cameraProfileChange,package: package,
                                  height: 40,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Obx(() {
                        return SizedBox(
                          width: controller.name.isNotEmpty ? null : 80,
                          child: TextField(
                            focusNode: controller.userNameFocus,
                            autofocus: false,
                            onChanged: (value) => controller.nameChanges(value),
                            textAlign: controller.profileName.text.isNotEmpty ? TextAlign.center : TextAlign.start,
                            maxLength: 30,
                            controller: controller.profileName,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Username',
                              counterText: '',
                            ),
                            style: TextStyle(fontWeight: FontWeight.bold, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                    ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      focusNode: controller.emailFocus,
                      onChanged: (value) => controller.onEmailChange(value),
                      controller: controller.profileEmail,
                      enabled: controller.emailEditAccess,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Email Id',
                        icon: SvgPicture.asset(emailIcon,package: package, color: MirrorflyUikit.getTheme?.textSecondaryColor,),
                      ),
                      style: TextStyle(fontWeight: FontWeight.normal, color: MirrorflyUikit.getTheme?.textSecondaryColor),
                    ),
                    const AppDivider(),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Mobile Number',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                    ),
                    TextField(
                      controller: controller.profileMobile,
                      enabled: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Mobile Number',
                        icon: SvgPicture.asset(phoneIcon,package: package,color: MirrorflyUikit.getTheme?.textSecondaryColor),
                      ),
                      style: TextStyle(fontWeight: FontWeight.normal, color: MirrorflyUikit.getTheme?.textSecondaryColor),
                    ),
                    const AppDivider(),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                    ),
                    Obx(() => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            controller.profileStatus.value.isNotEmpty
                                ? controller.profileStatus.value
                                : Constants.defaultStatus,
                            style: TextStyle(
                                color: controller.profileStatus.value.isNotEmpty ? MirrorflyUikit.getTheme?.textSecondaryColor : Colors.black38,
                                fontWeight: FontWeight.normal),
                          ),
                          minLeadingWidth: 10,
                          leading: SvgPicture.asset(statusIcon,package: package,color: MirrorflyUikit.getTheme?.textSecondaryColor),
                          onTap: () async {
                            // Get.toNamed(Routes.statusList, arguments: {'status': controller.profileStatus.value})
                            //     ?.then((value) {
                            //   if (value != null) {
                            //     controller.profileStatus.value = value;
                            //   }
                            // });
                            final result = await Navigator.push(context, MaterialPageRoute(builder: (con)=> StatusListView(status: controller.profileStatus.value)));
                            if (result != null) {
                              controller.profileStatus.value = result;
                            }

                          },
                        )),
                    const AppDivider(
                      padding: EdgeInsets.only(bottom: 16),
                    ),
                    Center(
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              textStyle: const TextStyle(fontSize: 14),
                              backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
                              shape: const StadiumBorder()),
                          onPressed: controller.loading.value
                              ? null
                              : controller.changed.value
                                  ? () {
                                      FocusScope.of(context).unfocus();
                                      if (!controller.loading.value) {
                                        controller.save(context: context);
                                      }
                                    }
                                  : null,
                          child: Text(
                            controller.from.value == Routes.login
                                ? 'Save'
                                : controller.changed.value
                                    ? 'Update & Continue'
                                    : 'Save',
                            style: TextStyle(fontWeight: FontWeight.w600, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  bottomSheetView(BuildContext context) {
    showModalBottomSheet(
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return SafeArea(
            child: SizedBox(
              child: Card(
                color: MirrorflyUikit.getTheme?.scaffoldColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: MirrorflyUikit.getTheme!.textSecondaryColor),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text("Options", style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            controller.camera(context);
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: Text("Take Photo",
                              style: TextStyle(color:  MirrorflyUikit.getTheme?.textPrimaryColor, fontWeight: FontWeight.bold))),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            controller.imagePicker(context);
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: Text("Choose from Gallery",
                              style: TextStyle(color:  MirrorflyUikit.getTheme?.textPrimaryColor, fontWeight: FontWeight.bold))),
                      controller.userImgUrl.value.isNotEmpty
                          ? TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Helper.showAlert(message: "Are you sure you want to remove the photo?", actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("CANCEL", style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        controller.removeProfileImage(context);
                                      },
                                      child: Text("REMOVE", style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor)))

                                ], context: context);
                              },
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft),
                              child: Text(
                                "Remove Photo",
                                style: TextStyle(color:  MirrorflyUikit.getTheme?.textPrimaryColor, fontWeight: FontWeight.bold),
                              ))
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
