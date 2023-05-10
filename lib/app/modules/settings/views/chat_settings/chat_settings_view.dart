import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/chat_settings/chat_settings_controller.dart';

import '../../../../../mirrorfly_uikit_plugin.dart';
import '../../../../common/constants.dart';
import '../../../../common/widgets.dart';
import '../../../busy_status/views/busy_status_view.dart';
import '../settings_widgets.dart';
import 'datausage/datausage_list_view.dart';

class ChatSettingsView extends StatelessWidget {
  ChatSettingsView({Key? key}) : super(key: key);
  final controller = Get.put(ChatSettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
        ),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      ),
      body: Obx(() {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lockItem(
                  title: "Archive Settings",
                  subtitle: "Archived chats will remain archived when you receive a new message",
                  on: controller.archiveEnabled,
                  onToggle: (value) => controller.enableArchive()),
              notificationItem(
                  title: "Last Seen",
                  subtitle: "Hiding the last seen activity to other users",
                  on: controller.lastSeenPreference.value,
                  onTap: () => controller.lastSeenEnableDisable()),
              notificationItem(
                  title: "User Busy Status",
                  subtitle: "Set busy status as the Auto response to the message received from the individuals",
                  on: controller.busyStatusPreference.value,
                  onTap: () => controller.busyStatusEnable()),
              Visibility(
                  visible: controller.busyStatusPreference.value,
                  child: chatListItem(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Busy Status Message',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: MirrorflyUikit.getTheme?.textPrimaryColor,
                                  fontWeight: FontWeight.w400)),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(controller.busyStatus.value,
                                maxLines: null,
                                style: TextStyle(
                                    color: MirrorflyUikit.getTheme?.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ],
                      ),
                      rightArrowIcon,
                      () => {
                            // Get.toNamed(Routes.busyStatus)},
                            Navigator.push(context, MaterialPageRoute(builder: (con) => const BusyStatusView()))
                          })),
              notificationItem(
                  title: Constants.autoDownload,
                  subtitle: Constants.autoDownloadLable,
                  on: controller.autoDownloadEnabled,
                  onTap: ()=>controller.enableDisableAutoDownload(context)),
              Visibility(
                  visible: controller.autoDownloadEnabled,
                  child: chatListItem(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Constants.dataUsageSettings,
                            style: TextStyle(
                                fontSize: 14,
                                color: MirrorflyUikit.getTheme?.textPrimaryColor,
                                fontWeight: FontWeight.w400)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(Constants.dataUsageSettingsLable,
                              style: TextStyle(
                                  color: MirrorflyUikit.getTheme?.textSecondaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ],
                    ),
                    rightArrowIcon,
                    () => {
                      // Get.toNamed(Routes.dataUsageSetting)
                      Navigator.push(context, MaterialPageRoute(builder: (con) => const DataUsageListView()))
                    },
                  )),
              /* notificationItem(title: Constants.googleTranslationLabel, subtitle: Constants.googleTranslationMessage,on: controller.translationEnabled, onTap: controller.enableDisableTranslate),
              Visibility(
                  visible: controller.translationEnabled,
                  child: chatListItem(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(Constants.googleTranslationLanguageLable,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(controller.translationLanguage,
                            style: const TextStyle(
                                color: buttonBgColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                      const Text(Constants.googleTranslationLanguageDoubleTap,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400))
                    ],
                  ), rightArrowIcon, () => controller.chooseLanguage())),*/
              ListItem(
                  title: const Text('Clear All Conversation',
                      style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w400)),
                  dividerPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () {
                    controller.clearAllConversation(context);
                  })
            ],
          ),
        );
      }),
    );
  }
}
