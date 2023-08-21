import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../models.dart';

import '../chat_widgets.dart';
import '../controllers/chat_controller.dart';

class ChatSearchView extends StatelessWidget {
  ChatSearchView({super.key, this.showChatDeliveryIndicator = true});

  final bool showChatDeliveryIndicator;

  final controller = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        controller.searchInit();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: AppBar(
          backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
          actionsIconTheme: IconThemeData(
              color: MirrorflyUikit.getTheme?.colorOnAppbar ?? iconColor),
          iconTheme: IconThemeData(
              color: MirrorflyUikit.getTheme?.colorOnAppbar ?? iconColor),
          automaticallyImplyLeading: true,
          title: TextField(
            onChanged: (text) => controller.setSearch(text),
            controller: controller.searchedText,
            focusNode: controller.searchfocusNode,
            autofocus: true,
            cursorColor: MirrorflyUikit.getTheme?.colorOnAppbar,
            style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
            decoration: InputDecoration(
                hintText: AppConstants.searchPlaceHolder, border: InputBorder.none,hintStyle: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar.withOpacity(0.5))),
            onSubmitted: (str) {
              if (controller.filteredPosition.isNotEmpty) {
                controller.scrollUp();
              } else {
                toToast(AppConstants.noResultsFound);
              }
            },
          ),
          // iconTheme: const IconThemeData(color: iconColor),
          actions: [
            IconButton(
                onPressed: () {
                  controller.scrollUp();
                },
                icon: const Icon(Icons.keyboard_arrow_up)),
            IconButton(
                onPressed: () {
                  controller.scrollDown();
                },
                icon: const Icon(Icons.keyboard_arrow_down)),
          ],
        ),
        body: Obx(() => controller.chatList.isEmpty
            ? const SizedBox.shrink()
            : chatListView(controller.chatList)),
      ),
    );
  }

  Widget chatListView(List<ChatMessageModel> chatList) {
    return ScrollablePositionedList.builder(
      itemCount: chatList.length,
      //initialScrollIndex: chatList.length,
      itemScrollController: controller.searchScrollController,
      itemPositionsListener: controller.itemPositionsListener,
      reverse: true,
      itemBuilder: (context, index) {
        return Column(
          children: [
            groupedDateMessage(index, chatList) != null
                ? NotificationMessageView(
                    chatMessage: groupedDateMessage(index, chatList))
                : const SizedBox.shrink(),
            (chatList[index].messageType.toUpperCase() !=
                    Constants.mNotification)
                ? Container(
                    color: chatList[index].isSelected.value
                        ? MirrorflyUikit.getTheme?.primaryColor.withAlpha(60)
                        : Colors.transparent,
                    margin: const EdgeInsets.only(
                        left: 14, right: 14, top: 5, bottom: 10),
                    child: Align(
                      alignment: (chatList[index].isMessageSentByMe
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(
                            visible: chatList[index].isMessageSentByMe &&
                                controller
                                    .forwardMessageVisibility(chatList[index]),
                            child: IconButton(
                                onPressed: () {
                                  controller.forwardSingleMessage(
                                      chatList[index].messageId);
                                },
                                icon: SvgPicture.asset(
                                  forwardMedia,
                                  package: package,
                                )),
                          ),
                          ChatContainer(
                            chatMessage: chatList[index],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SenderHeader(
                                    isGroupProfile:
                                        controller.profile.isGroupProfile,
                                    chatList: chatList,
                                    index: index),
                                (chatList[index].replyParentChatMessage == null)
                                    ? const SizedBox.shrink()
                                    : ReplyMessageHeader(
                                        chatMessage: chatList[index]),
                                MessageContent(
                                  chatList: chatList,
                                  index: index,
                                  search: controller.searchedText.text.trim(),
                                  onPlayAudio: () {
                                    controller.playAudio(chatList[index]);
                                  },
                                  onSeekbarChange: (value) {},
                                  showChatDeliveryIndicator: showChatDeliveryIndicator,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: !chatList[index].isMessageSentByMe &&
                                controller
                                    .forwardMessageVisibility(chatList[index]),
                            child: IconButton(
                                onPressed: () {
                                  controller.forwardSingleMessage(
                                      chatList[index].messageId);
                                },
                                icon: SvgPicture.asset(
                                  forwardMedia,
                                  package: package,
                                )),
                          ),
                        ],
                      ),
                    ),
                  )
                : NotificationMessageView(
                    chatMessage: chatList[index].messageTextContent),
          ],
        );
      },
    );
  }
}
