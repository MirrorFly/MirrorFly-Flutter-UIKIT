import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';

import 'package:get/get.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../chat/chat_widgets.dart';
import '../../chat/views/starred_message_header.dart';
import '../controllers/starred_messages_controller.dart';
import '../../../models.dart';

class StarredMessagesView extends StatefulWidget {
  const StarredMessagesView({Key? key}) : super(key: key);

  @override
  State<StarredMessagesView> createState() => _StarredMessagesViewState();
}

class _StarredMessagesViewState extends State<StarredMessagesView> {
  final controller = Get.put(StarredMessagesController());
  @override
  Widget build(BuildContext context) {
    controller.height = MediaQuery.of(context).size.height;
    controller.width = MediaQuery.of(context).size.width;
    return FocusDetector(
      onFocusGained: () {
        controller.getFavouriteMessages();
      },
      child: WillPopScope(
        onWillPop: () {
          if (controller.isSelected.value) {
            controller.clearAllChatSelection();
            return Future.value(false);
          }else if(controller.isSearch.value){
            controller.clearSearch();
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Scaffold(
            backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
          appBar: getAppBar(context),
          body: Obx(() {
            return controller.starredChatList.isNotEmpty ?
            SingleChildScrollView(child: favouriteChatListView(controller.starredChatList)) :
            controller.isListLoading.value ? const Center(child: CircularProgressIndicator(),) : Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 30),
              child: Text(controller.isSearch.value ? "No result found" : "No Starred Messages Found", style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),),
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
              onLongPress: () {
                if (!controller.isSelected.value) {
                  controller.isSelected(true);
                  controller.addChatSelection(starredChatList[index]);
                }
              },
              onTap: () {
                debugPrint("On Tap");
                controller.isSelected.value
                    ? controller.selectedChatList.contains(starredChatList[index])
                    ? controller.clearChatSelection(starredChatList[index])
                    : controller.addChatSelection(starredChatList[index])
                    : controller.navigateMessage(starredChatList[index]);
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
                                      ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.color
                                      : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.color),
                                  border: starredChatList[index].isMessageSentByMe
                                      ? Border.all(color: MirrorflyUikit.getTheme!.chatBubblePrimaryColor.color)
                                      : Border.all(color: MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.color)),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  (starredChatList[index]
                                      .replyParentChatMessage ==
                                      null)
                                      ? const SizedBox.shrink()
                                      : ReplyMessageHeader(
                                      chatMessage: starredChatList[index]),
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
            title: Text('Starred Messages', style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
            iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
            backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  searchIcon,package: package,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  color: MirrorflyUikit.getTheme?.colorOnAppbar,
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
        style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),
        controller: controller.searchedText,
        focusNode: controller.searchFocus,
        cursorColor: MirrorflyUikit.getTheme?.primaryColor,
        autofocus: true,
        decoration: InputDecoration(
            hintText: "Search...", border: InputBorder.none, hintStyle: TextStyle(
            color: MirrorflyUikit
            .getTheme?.colorOnAppbar),),
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
                    icon: SvgPicture.asset(forwardIcon,package: package,color: MirrorflyUikit.getTheme?.colorOnAppbar),tooltip: 'Forward',),
                overflowWidget: const Text("Forward"),
                showAsAction: controller.canBeForward.value ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Forward',
                onItemClick: () {
                  controller.checkBusyStatusForForward(context);
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.favouriteMessage();
                    },
                    icon: SvgPicture.asset(unFavouriteIcon,package: package,color: MirrorflyUikit.getTheme?.colorOnAppbar),tooltip: 'unFavourite',),
                overflowWidget: const Text("unFavourite"),
                showAsAction: ShowAsAction.always,
                keyValue: 'unfavoured',
                onItemClick: () {
                  controller.favouriteMessage();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.share();
                    },
                    icon: SvgPicture.asset(shareIcon,package: package,color: MirrorflyUikit.getTheme?.colorOnAppbar),tooltip: 'Share',),
                overflowWidget: const Text("Share"),
                showAsAction: controller.canBeShare.value ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Share',
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
                    fit: BoxFit.contain,color: MirrorflyUikit.getTheme?.colorOnAppbar
                  ),
                  tooltip: 'Copy',
                ),
                overflowWidget: const Text("Copy"),
                showAsAction: ShowAsAction.always,
                keyValue: 'Copy',
                onItemClick: () {
                  controller.copyTextMessages();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.deleteMessages(context);
                    },
                    icon: SvgPicture.asset(deleteIcon,package: package,color: MirrorflyUikit.getTheme?.colorOnAppbar),tooltip: 'Delete',),
                overflowWidget: const Text("Delete"),
                showAsAction: ShowAsAction.always,
                keyValue: 'Delete',
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
