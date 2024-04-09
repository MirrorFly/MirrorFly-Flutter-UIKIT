import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';

import '../../../mirrorfly_uikit_plugin.dart';
import '../../common/constants.dart';
import '../../common/extensions.dart';
import '../../widgets/custom_action_bar_icons.dart';
import '../dashboard/widgets.dart';
import 'archived_chat_list_controller.dart';

class ArchivedChatListView extends StatelessWidget {
  ArchivedChatListView({super.key, this.enableAppBar=true, this.showChatDeliveryIndicator = true});
  final bool enableAppBar;
  final bool showChatDeliveryIndicator;
  final controller = Get.put(ArchivedChatListController());
  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        controller.showChatDeliveryIndicator = showChatDeliveryIndicator;
        controller.getArchivedChatsList();
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (controller.selected.value) {
            controller.clearAllChatSelection();
            return;
          }
          // Get.back();
          Navigator.pop(context);
        },
        child: Obx(() {
          return Scaffold(
            backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
            appBar: enableAppBar ? AppBar(
              backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
              iconTheme: IconThemeData(
                  color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                      iconColor),
              leading: controller.selected.value ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clearAllChatSelection();
                },
              ) : null,
              title: controller.selected.value
                  ? Text(
                  (controller.selectedChats.length).toString())
                  : Text(AppConstants.archivedChats,style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
              actions: [
                Visibility(
                  visible: controller.selected.value,
                  child: CustomActionBarIcons(
                      availableWidth: MediaQuery
                          .of(context)
                          .size
                          .width * 0.80,
                      // 80 percent of the screen width
                      actionWidth: 48,
                      // default for IconButtons
                      actions: [
                        CustomAction(
                          visibleWidget: IconButton(
                              onPressed: () {
                                controller.deleteChats(context);
                              },
                              icon: SvgPicture.asset(delete,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),tooltip: AppConstants.delete,),
                          overflowWidget: Text(AppConstants.delete,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                          showAsAction: controller.delete.value ? ShowAsAction.always : ShowAsAction.gone,
                          keyValue: AppConstants.delete,
                          onItemClick: () {
                            controller.deleteChats(context);
                          },
                        ),
                        CustomAction(
                          visibleWidget: IconButton(
                            onPressed: () {
                              controller.muteChats();
                            },
                            icon: SvgPicture.asset(mute,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),tooltip: AppConstants.mute,),
                          overflowWidget: Text(AppConstants.mute,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                          showAsAction: controller.mute.value
                              ? ShowAsAction.always
                              : ShowAsAction.gone,
                          keyValue: AppConstants.mute,
                          onItemClick: () {
                            controller.muteChats();
                          },
                        ),
                        CustomAction(
                          visibleWidget: IconButton(
                            onPressed: () {
                              controller.unMuteChats();
                            },
                            icon: SvgPicture.asset(unMute,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),tooltip: AppConstants.unMute,),
                          overflowWidget: Text(AppConstants.unMute,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                          showAsAction: controller.unMute.value
                              ? ShowAsAction.always
                              : ShowAsAction.gone,
                          keyValue: AppConstants.unMute,
                          onItemClick: () {
                            controller.unMuteChats();
                          },
                        ),
                        CustomAction(
                          visibleWidget: IconButton(
                              onPressed: () {
                                controller.unArchiveSelectedChats();
                              },
                              icon: SvgPicture.asset(unarchive,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),tooltip: AppConstants.unArchived,),
                          overflowWidget: Text(AppConstants.unArchived,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                          showAsAction: ShowAsAction.always,
                          keyValue: AppConstants.unArchived,
                          onItemClick: () {
                            controller.unArchiveSelectedChats();
                          },
                        ),
                      ]),
                )
              ],
            ) : null,
            body: SafeArea(
              child: Obx(() =>
                  controller.archivedChats.isNotEmpty ? ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: controller.archivedChats.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        var item = controller.archivedChats[index];
                        return Obx(() {
                          return RecentChatItem(
                            item: item,
                            onAvatarClick: (){
                              controller.getProfileDetail(context, item, index);
                            },
                            isSelected: controller.isSelected(index),
                            typingUserid: controller.typingUser(
                                item.jid.checkNull()),
                            archiveVisible: false,
                            archiveEnabled: controller.archiveEnabled.value,
                            showChatDeliveryIndicator: showChatDeliveryIndicator,
                            onTap: () {
                              if (controller.selected.value) {
                                controller.selectOrRemoveChatFromList(index);
                              } else {
                                controller.toChatPage(item.jid.checkNull(),item.isGroup.checkNull(), context);
                              }
                            },
                            onLongPress: () {
                              controller.selected(true);
                              controller.selectOrRemoveChatFromList(index);
                            },
                          );
                        });
                      }) : Center(
                    child: Text(AppConstants.noArchivedChats,style: TextStyle( color: MirrorflyUikit.getTheme?.textPrimaryColor),),
                  )),
            ),
          );
        }),
      ),
    );
  }
}
