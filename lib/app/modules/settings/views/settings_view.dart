import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/controllers/settings_controller.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/settings_widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/routes/app_pages.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit_plugin.dart';

import '../../../common/constants.dart';
import 'about/about_and_help_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: true,
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            settingListItem("Profile", profileIcon, rightArrowIcon,
                () => Get.toNamed(Routes.profile,arguments: {"from":Routes.settings})),
            settingListItem("Chats", chatIcon, rightArrowIcon, () {
              Get.toNamed(Routes.chatSettings);
            }),
            settingListItem(
                "Starred Messages", staredMsgIcon, rightArrowIcon, () {
                  Get.toNamed(Routes.starredMessages);
            }),
            settingListItem(
                "Notifications", notificationIcon, rightArrowIcon, ()=>Get.toNamed(Routes.notification)),
            settingListItem(
                "Blocked Contacts", blockedIcon, rightArrowIcon, ()=>Get.toNamed(Routes.blockedList)),
            // settingListItem("App Lock", lockIcon, rightArrowIcon, ()=>Get.toNamed(Routes.appLock)),
            settingListItem("About and Help", aboutIcon, rightArrowIcon, () =>Get.to(const AboutAndHelpView())),
            settingListItem(
                "Connection Label", connectionIcon, toggleOffIcon, () {}),
            settingListItem("Delete My Account", delete, rightArrowIcon, () {
              Get.toNamed(Routes.deleteAccount);
            }),
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
        Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                          text: "Released On: ",
                          style: TextStyle(color: textColor),
                          children: [
                            TextSpan(
                                text: "March 2023",
                                style: TextStyle(color: textHintColor))
                          ]),
                    ),
                    RichText(
                        text: TextSpan(
                            text: "Version ",
                            style: const TextStyle(color: textColor),
                            children: [
                              TextSpan(
                                  text: controller.packageInfo != null
                                      ? controller.packageInfo!.version
                                      : "",
                                  style: const TextStyle(color: textHintColor))
                            ]),
                      ),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
