import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../chat/chat_widgets.dart';
import '../../chat/views/starred_message_header.dart';
import '../controllers/starred_messages_controller.dart';
import '../../../models.dart';

class StarredMessagesView extends StatefulWidget {
  const StarredMessagesView({super.key, this.enableAppBar = true});
  final bool enableAppBar;

  @override
  State<StarredMessagesView> createState() => _StarredMessagesViewState();
}

class _StarredMessagesViewState extends State<StarredMessagesView> {
  final controller = Get.put(StarredMessagesController());

  @override
  void dispose() {
    super.dispose();
    Get.delete<StarredMessagesController>();
  }
  @override
  Widget build(BuildContext context) {
    controller.height = MediaQuery.of(context).size.height;
    controller.width = MediaQuery.of(context).size.width;
    return FocusDetector(
      onFocusGained: () {
        controller.getFavouriteMessages();
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (controller.isSelected.value) {
            controller.clearAllChatSelection();
            return;
          }else if(controller.isSearch.value){
            controller.clearSearch();
            return;
          }
          Navigator.pop(context);
        },
        child: Scaffold(
            backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
          appBar: widget.enableAppBar ? getAppBar(context) : null,
          body: Obx(() {
            return controller.starredChatList.isNotEmpty ?
            SingleChildScrollView(child: favouriteChatListView(controller.starredChatList)) :
            controller.isListLoading.value ? Center(child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.primaryColor,),) : Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 30),
              child: Text(controller.isSearch.value ? AppConstants.noResultsFound : AppConstants.noStarredMessages, style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),),
            ));
          })
        ),
      ),
    );
  }

  Widget favouriteChatListView(RxList<ChatMessageModel> starredChatList) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        // controller: controller.scrollController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: starredChatList.length,
        shrinkWrap: true,
        reverse: false,
        itemBuilder: (context, index) {
          // int reversedIndex = chatList.length - 1 - index;
            return GestureDetector(
              onLongPress: widget.enableAppBar ? () {
                if (!controller.isSelected.value) {
                  controller.isSelected(true);
                  controller.addChatSelection(starredChatList[index]);
                }
              } : null,
              onTap: () {
                debugPrint("On Tap");
                controller.isSelected.value
                    ? controller.selectedChatList.contains(starredChatList[index])
                    ? controller.clearChatSelection(starredChatList[index])
                    : controller.addChatSelection(starredChatList[index])
                    : controller.navigateMessage(starredChatList[index], context);
              },
              child: Obx(() {
                return Column(
                  children: [
                    Container(
                      key: Key(starredChatList[index].messageId),
                      color: controller.isSelected.value &&
                          (starredChatList[index].isSelected.value) &&
                          controller.starredChatList.isNotEmpty
                          ? MirrorflyUikit.getTheme?.primaryColor.withAlpha(60)
                          : Colors.transparent,
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, top: 5, bottom: 10),
                      margin: const EdgeInsets.all(2),
                      child: Column(
                        children: [
                          const AppDivider(),
                          const SizedBox(height: 10,),
                          StarredMessageHeader(chatList: starredChatList[index], isTapEnabled: false,),
                          const SizedBox(height: 10,),
                          Align(
                            alignment: (starredChatList[index].isMessageSentByMe
                                ? Alignment.bottomRight
                                : Alignment.bottomLeft),
                            child: Container(
                              constraints:
                              BoxConstraints(maxWidth: controller.width * 0.75),
                              decoration: BoxDecoration(
                                  borderRadius: starredChatList[index].isMessageSentByMe
                                      ? const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10))
                                      : const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  color: (starredChatList[index].isMessageSentByMe
                                      ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor
                                      .color
                                      : Colors.white),
                                  border: starredChatList[index].isMessageSentByMe
                                      ? Border.all(color: MirrorflyUikit.getTheme!.chatBubblePrimaryColor
                                      .color)
                                      : Border.all(color: MirrorflyUikit.getTheme!
                                      .chatBubblePrimaryColor.textSecondaryColor
                                      .withOpacity(0.2)/*chatBorderColor*/)),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  starredChatList[index].isThisAReplyMessage ? starredChatList[index].replyParentChatMessage == null
                                      ? messageNotAvailableWidget(starredChatList[index])
                                      : ReplyMessageHeader(
                                      chatMessage: starredChatList[index]) : const SizedBox.shrink(),
                                  MessageContent(chatList: starredChatList,search: controller.searchedText.text.trim(),index:index, onPlayAudio: (){
                                    controller.playAudio(starredChatList[index]);
                                  },onSeekbarChange:(value){

                                  },),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            );
        },
      ),
    );
  }

  getAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: Obx(() {
        return Container(
          child: controller.isSelected.value ? selectedAppBar(context) : controller.isSearch.value ? searchBar() : AppBar(
            title: Text(AppConstants.starredMessages, style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
            iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
            backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  searchIcon,package: package,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn),
                ),
                onPressed: () {
                  controller.onSearchClick();
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  searchBar(){
    return AppBar(
      automaticallyImplyLeading: true,
      iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
      backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      title: TextField(
        onChanged: (text) => controller.startSearch(text),
        style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
        controller: controller.searchedText,
        focusNode: controller.searchFocus,
        cursorColor: MirrorflyUikit.getTheme?.colorOnAppbar,
        autofocus: true,
        decoration: InputDecoration(
            hintText: AppConstants.searchPlaceHolder, border: InputBorder.none, hintStyle: TextStyle(
            color: MirrorflyUikit
                .getTheme?.colorOnAppbar.withOpacity(0.5)),),
      ),
      actions: [
        Visibility(
          visible: controller.clear.value,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.clearSearch();
            },
          ),
        ),
      ],
    );
  }

  selectedAppBar(BuildContext context) {
    return AppBar(
      // leadingWidth: 25,
      iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
      backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      leading: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          controller.clearAllChatSelection();
        },
      ),
      title: Text(controller.selectedChatList.length.toString()),
      actions: [
        CustomActionBarIcons(
            availableWidth: controller.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.checkBusyStatusForForward(context);
                    },
                    icon: SvgPicture.asset(forwardIcon,package: package, colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),tooltip: AppConstants.forward,),
                overflowWidget: Text(AppConstants.forward),
                showAsAction: controller.canBeForward.value ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: AppConstants.forward,
                onItemClick: () {
                  controller.checkBusyStatusForForward(context);
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.favouriteMessage();
                    },
                    icon: SvgPicture.asset(unFavouriteIcon,package: package, colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),tooltip: AppConstants.unFavourite,),
                overflowWidget: Text(AppConstants.unFavourite),
                showAsAction: ShowAsAction.always,
                keyValue: AppConstants.unFavourite,
                onItemClick: () {
                  controller.favouriteMessage();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.share();
                    },
                    icon: SvgPicture.asset(shareIcon,package: package, colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),tooltip: AppConstants.share,),
                overflowWidget: Text(AppConstants.share),
                showAsAction: controller.canBeShare.value ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: AppConstants.share,
                onItemClick: () {},
              ),
              controller.selectedChatList.length > 1 ||
                  controller.selectedChatList[0].messageType !=
                      Constants.mText
                  ? customEmptyAction()
                  : CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.copyTextMessages();
                  },
                  icon: SvgPicture.asset(
                    copyIcon,package: package,
                    fit: BoxFit.contain, colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn),
                  ),
                  tooltip: AppConstants.copy,
                ),
                overflowWidget: Text(AppConstants.copy),
                showAsAction: ShowAsAction.always,
                keyValue: AppConstants.copy,
                onItemClick: () {
                  controller.copyTextMessages();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.deleteMessages(context);
                    },
                    icon: SvgPicture.asset(deleteIcon,package: package, colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn),),tooltip: AppConstants.delete,),
                overflowWidget: Text(AppConstants.delete),
                showAsAction: ShowAsAction.always,
                keyValue: AppConstants.delete,
                onItemClick: () {
                  controller.deleteMessages(context);
                },
              ),
            ]),
      ],
    );
  }

  customEmptyAction() {
    return CustomAction(
        visibleWidget: const SizedBox.shrink(),
        overflowWidget: const SizedBox.shrink(),
        showAsAction: ShowAsAction.gone,
        keyValue: 'Empty',
        onItemClick: () {});
  }
}
