import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/settings_widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/routes/app_pages.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit_plugin.dart';

import '../../../common/constants.dart';
import '../../profile/views/profile_view.dart';
import '../../starred_messages/views/starred_messages_view.dart';
import 'chat_settings/chat_settings_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(SettingsController());
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
        iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
        automaticallyImplyLeading: true,
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Get.toNamed(Routes.profile,arguments: {"from":Routes.settings})
              settingListItem("Profile", profileIcon, rightArrowIcon, () => Navigator.push(context, MaterialPageRoute(builder: (con)=> const ProfileView()))),
              settingListItem("Chats", chatIcon, rightArrowIcon, () {
                // Get.toNamed(Routes.chatSettings);
                Navigator.push(context, MaterialPageRoute(builder: (con)=> ChatSettingsView()));
              }),
              settingListItem(
                  "Starred Messages", staredMsgIcon, rightArrowIcon, () {
                    // Get.toNamed(Routes.starredMessages);
                    Navigator.push(context, MaterialPageRoute(builder: (con)=> const StarredMessagesView()));
              }),
              // settingListItem(
              //     "Notifications", notificationIcon, rightArrowIcon, ()=>Get.toNamed(Routes.notification)),
              settingListItem(
                  "Blocked Contacts", blockedIcon, rightArrowIcon, ()=>Get.toNamed(Routes.blockedList)),
              // settingListItem("App Lock", lockIcon, rightArrowIcon, ()=>Get.toNamed(Routes.appLock)),
              // settingListItem("About and Help", aboutIcon, rightArrowIcon, () =>Get.to(const AboutAndHelpView())),
              // settingListItem(
              //     "Connection Label", connectionIcon, toggleOffIcon, () {}),
              // settingListItem("Delete My Account", delete, rightArrowIcon, () {
              //   Get.toNamed(Routes.deleteAccount);
              // }),
              /*settingListItem("Logout", logoutIcon, rightArrowIcon, () {
                Helper.showAlert(
                    message:
                    "Are you sure want to logout from the app?",
                    actions: [
                      TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text("NO")),
                      TextButton(
                          onPressed: () {
                            controller.logout();
                          },
                          child: const Text("YES"))
                    ]);
              }),*/
          // Padding(
          //       padding: const EdgeInsets.all(20.0),
          //       child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             RichText(
          //               text: const TextSpan(
          //                   text: "Released On: ",
          //                   style: TextStyle(color: textColor),
          //                   children: [
          //                     TextSpan(
          //                         text: "March 2023",
          //                         style: TextStyle(color: textHintColor))
          //                   ]),
          //             ),
          //             RichText(
          //                 text: TextSpan(
          //                     text: "Version ",
          //                     style: const TextStyle(color: textColor),
          //                     children: [
          //                       TextSpan(
          //                           text: controller.packageInfo != null
          //                               ? controller.packageInfo!.version
          //                               : "",
          //                           style: const TextStyle(color: textHintColor))
          //                     ]),
          //               ),
          //           ]),
          //     )
            ],
          ),
        ),
      ),
    );
  }
}
