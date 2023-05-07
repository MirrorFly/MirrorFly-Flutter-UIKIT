import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../image_view/views/image_view_view.dart';
import '../controllers/chat_info_controller.dart';

class ChatInfoView extends StatefulWidget {
  const ChatInfoView({
    Key? key,
    required this.jid,
  }) : super(key: key);
  final String jid;

  @override
  State<ChatInfoView> createState() => _ChatInfoViewState();
}

class _ChatInfoViewState extends State<ChatInfoView> {
  var controller = Get.put(ChatInfoController());

  @override
  void initState() {
    controller.init(widget.jid);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ChatInfoController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      body: NestedScrollView(
        controller: controller.scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          controller.silverBarHeight = Get.height * 0.45;
          return <Widget>[
            Obx(() {
              return SliverAppBar(
                backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
                actionsIconTheme: IconThemeData(
                    color: MirrorflyUikit.getTheme?.colorOnAppbar ?? iconColor),
                iconTheme: IconThemeData(
                    color: MirrorflyUikit.getTheme?.colorOnAppbar ?? iconColor),
                centerTitle: false,
                titleSpacing: 0.0,
                expandedHeight: MediaQuery.of(context).size.height * 0.45,
                snap: false,
                pinned: true,
                floating: false,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: controller.isSliverAppBarExpanded
                        ? Colors.white
                        : MirrorflyUikit.getTheme?.colorOnAppbar ??
                            Colors.black,
                  ),
                  onPressed: () {
                    // Get.back();
                    Navigator.pop(context);
                  },
                ),
                title: Visibility(
                  visible: !controller.isSliverAppBarExpanded,
                  child: Text(controller.profile.getName(),
                      style: TextStyle(
                        color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                            Colors.black,
                        fontSize: 18.0,
                      )),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  background: ImageNetwork(
                    url: controller.profile.image.checkNull(),
                    width: Get.width,
                    height: Get.height * 0.45,
                    clipOval: false,
                    errorWidget: ProfileTextImage(
                      text: controller.profile.getName(),
                      radius: 0,
                      fontSize: 120,
                    ),
                    onTap: () {
                      if (controller.profile.image!.isNotEmpty &&
                          !(controller.profile.isBlockedMe.checkNull() ||
                              controller.profile.isAdminBlocked.checkNull()) &&
                          !(!controller.profile.isItSavedContact.checkNull() ||
                              controller.profile.isDeletedContact())) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (con) => ImageViewView(
                                      imageName: controller.profile.getName(),
                                  imageUrl:
                                          controller.profile.image.checkNull(),
                                    )));
                        /*Get.toNamed(Routes.imageView, arguments: {
                          'imageName': getName(controller.profile),
                          'imageUrl': controller.profile.image.checkNull()
                        });*/
                      }
                    },
                    isGroup: controller.profile.isGroupProfile.checkNull(),
                    blocked: controller.profile.isBlockedMe.checkNull() ||
                        controller.profile.isAdminBlocked.checkNull(),
                    unknown:
                        (!controller.profile.isItSavedContact.checkNull() ||
                            controller.profile.isDeletedContact()),
                  ),
                  // titlePadding: controller.isSliverAppBarExpanded
                  //     ? const EdgeInsets.symmetric(vertical: 16, horizontal: 20)
                  //     : const EdgeInsets.symmetric(
                  //     vertical: 19, horizontal: 50),
                  titlePadding: const EdgeInsets.only(left: 16),

                  title: Visibility(
                    visible: controller.isSliverAppBarExpanded,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(controller.profile.getName(),
                              style: TextStyle(
                                color: controller.isSliverAppBarExpanded
                                    ? Colors.white
                                    : MirrorflyUikit.getTheme?.colorOnAppbar ??
                                        Colors.black,
                                fontSize: 18.0,
                              )),
                          Obx(() {
                            return Text(controller.userPresenceStatus.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.0,
                                ) //TextStyle
                                );
                          }),
                        ],
                      ),
                    ),
                  ),
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                    StretchMode.fadeTitle
                  ],
                ),
              );
            }),
          ];
        },
        body: ListView(
          children: [
            Obx(() {
              return controller.isSliverAppBarExpanded
                  ? const SizedBox.shrink()
                  : const SizedBox(height: 60);
            }),
            Obx(() {
              return listItem(
                title: Text("Mute Notification",
                    style: TextStyle(
                        color: MirrorflyUikit.getTheme?.textPrimaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                trailing: FlutterSwitch(
                    width: 40.0,
                    height: 20.0,
                    valueFontSize: 12.0,
                    toggleSize: 12.0,
                    activeColor: MirrorflyUikit.getTheme!.primaryColor,
                    //Colors.white,
                    activeToggleColor: MirrorflyUikit.getTheme?.colorOnPrimary,
                    //Colors.blue,
                    inactiveToggleColor: Colors.grey,
                    inactiveColor: Colors.white,
                    switchBorder: Border.all(
                        color: controller.mute.value
                            ? MirrorflyUikit.getTheme!.colorOnPrimary
                            : Colors.grey,
                        width: 1),
                    value: controller.mute.value,
                    onToggle: (value) => {controller.onToggleChange(value)}),
                onTap: () {
                  controller.onToggleChange(!controller.mute.value);
                },
              );
            }),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Email",
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.textPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        emailIcon,
                        package: package,
                        color: MirrorflyUikit.getTheme?.textSecondaryColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Obx(() {
                        return Text(controller.profile.email.checkNull(),
                            style: TextStyle(
                                fontSize: 13,
                                color: MirrorflyUikit
                                    .getTheme?.textSecondaryColor, //textColor,
                                fontWeight: FontWeight.w500));
                      }),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Mobile Number",
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.textPrimaryColor,
                          //Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        phoneIcon,
                        package: package,
                        color: MirrorflyUikit.getTheme?.textSecondaryColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Obx(() {
                        return Text(controller.profile.mobileNumber.checkNull(),
                            style: TextStyle(
                                fontSize: 13,
                                color: MirrorflyUikit
                                    .getTheme?.textSecondaryColor, //textColor,
                                fontWeight: FontWeight.w500));
                      }),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Status",
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.textPrimaryColor,
                          //Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        statusIcon,
                        package: package,
                        color: MirrorflyUikit.getTheme?.textSecondaryColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Obx(() {
                        return Text(controller.profile.status.checkNull(),
                            style: TextStyle(
                                fontSize: 13,
                                color: MirrorflyUikit
                                    .getTheme?.textSecondaryColor, //textColor,
                                fontWeight: FontWeight.w500));
                      }),
                    ],
                  ),
                ),
              ],
            ),
            listItem(
                leading: SvgPicture.asset(
                  imageOutline,
                  package: package,
                  color: MirrorflyUikit.getTheme?.textPrimaryColor,
                ),
                title: Text("View All Media",
                    style: TextStyle(
                        color: MirrorflyUikit.getTheme?.textPrimaryColor,
                        //Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: MirrorflyUikit.getTheme?.textPrimaryColor,
                ),
                onTap: () => {
                      controller.gotoViewAllMedia(context)
                    } //controller.gotoViewAllMedia(),
                ),
            listItem(
                leading: SvgPicture.asset(
                  reportUser,
                  package: package,
                  color: Colors.red,
                ),
                title: const Text("Report",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                onTap: () => {controller.reportChatOrUser(context)}),
          ],
        ),
      ),
    );
  }
}
