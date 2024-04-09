import 'package:flutter/material.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/settings_widgets.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit_plugin.dart';

import '../../../common/constants.dart';
import '../../profile/views/profile_view.dart';
import '../../starred_messages/views/starred_messages_view.dart';
import 'blocked/blocked_list_view.dart';
import 'chat_settings/chat_settings_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, this.enableAppBar = true});
  final bool enableAppBar;
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(SettingsController());
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: widget.enableAppBar
          ? AppBar(
              title: Text(
                AppConstants.settingsTitle,
                style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
              ),
              iconTheme:
                  IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
              automaticallyImplyLeading: true,
              backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Get.toNamed(Routes.profile,arguments: {"from":Routes.settings})
              settingListItem(
                  AppConstants.profileTitle,
                  profileIcon,
                  rightArrowIcon,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (con) => const ProfileView()))),
              settingListItem(
                  AppConstants.chatsSettings, chatIcon, rightArrowIcon, () {
                // Get.toNamed(Routes.chatSettings);
                Navigator.push(context,
                    MaterialPageRoute(builder: (con) => ChatSettingsView()));
              }),
              settingListItem(
                  AppConstants.starredMessages, staredMsgIcon, rightArrowIcon,
                  () {
                // Get.toNamed(Routes.starredMessages);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (con) => const StarredMessagesView()));
              }),
              // settingListItem(
              //     "Notifications", notificationIcon, rightArrowIcon, ()=>Get.toNamed(Routes.notification)),
              settingListItem(
                  AppConstants.blockedContacts,
                  blockedIcon,
                  rightArrowIcon,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (con) => const BlockedListView()))),
            ],
          ),
        ),
      ),
    );
  }
}
