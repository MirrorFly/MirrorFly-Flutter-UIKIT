import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

import '../../../mirrorfly_uikit_plugin.dart';
import '../../common/constants.dart';
import '../../widgets/custom_action_bar_icons.dart';
import '../dashboard/widgets.dart';
import 'archived_chat_list_controller.dart';

class ArchivedChatListView extends StatelessWidget {
  ArchivedChatListView({Key? key}) : super(key: key);

  final controller = Get.put(ArchivedChatListController());
  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        controller.getArchivedChatsList();
      },
      child: WillPopScope(
        onWillPop: () {
          if (controller.selected.value) {
            controller.clearAllChatSelection();
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Obx(() {
          return Scaffold(
            backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
            appBar: AppBar(
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
                  : Text('Archived Chats',style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
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
                              icon: SvgPicture.asset(delete,package: package, color: MirrorflyUikit.getTheme?.colorOnAppbar),tooltip: 'Delete',),
                          overflowWidget: Text("Delete",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                          showAsAction: controller.delete.value ? ShowAsAction.always : ShowAsAction.gone,
                          keyValue: 'Delete',
                          onItemClick: () {
                            controller.deleteChats(context);
                          },
                        ),
                        CustomAction(
                          visibleWidget: IconButton(
                            onPressed: () {
                              controller.muteChats();
                            },
                            icon: SvgPicture.asset(mute,package: package, color: MirrorflyUikit.getTheme?.colorOnAppbar),tooltip: 'Mute',),
                          overflowWidget: Text("Mute",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                          showAsAction: controller.mute.value
                              ? ShowAsAction.always
                              : ShowAsAction.gone,
                          keyValue: 'Mute',
                          onItemClick: () {
                            controller.muteChats();
                          },
                        ),
                        CustomAction(
                          visibleWidget: IconButton(
                            onPressed: () {
                              controller.unMuteChats();
                            },
                            icon: SvgPicture.asset(unMute,package: package, color: MirrorflyUikit.getTheme?.colorOnAppbar),tooltip: 'UnMute',),
                          overflowWidget: Text("UnMute",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                          showAsAction: controller.unMute.value
                              ? ShowAsAction.always
                              : ShowAsAction.gone,
                          keyValue: 'UnMute',
                          onItemClick: () {
                            controller.unMuteChats();
                          },
                        ),
                        CustomAction(
                          visibleWidget: IconButton(
                              onPressed: () {
                                controller.unArchiveSelectedChats();
                              },
                              icon: SvgPicture.asset(unarchive,package: package, color: MirrorflyUikit.getTheme?.colorOnAppbar),tooltip: 'UnArchive',),
                          overflowWidget: Text("UnArchive",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                          showAsAction: ShowAsAction.always,
                          keyValue: 'UnArchive',
                          onItemClick: () {
                            controller.unArchiveSelectedChats();
                          },
                        ),
                      ]),
                )
              ],
            ),
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
                            isSelected: controller.isSelected(index),
                            typingUserid: controller.typingUser(
                                item.jid.checkNull()),
                            archiveVisible: false,
                            archiveEnabled: controller.archiveEnabled.value,
                            onTap: () {
                              if (controller.selected.value) {
                                controller.selectOrRemoveChatFromList(index);
                              } else {
                                controller.toChatPage(item.jid.checkNull());
                              }
                            },
                            onLongPress: () {
                              controller.selected(true);
                              controller.selectOrRemoveChatFromList(index);
                            },
                          );
                        });
                      }) : Center(
                    child: Text('No archived chats',style: TextStyle( color: MirrorflyUikit.getTheme?.textPrimaryColor),),
                  )),
            ),
          );
        }),
      ),
    );
  }
}
