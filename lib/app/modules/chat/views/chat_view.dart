import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:marquee/marquee.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../../widgets/lottie_animation.dart';
import '../chat_widgets.dart';
import '../controllers/chat_controller.dart';
import '../../../models.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key, required this.jid, this.isUser=false, this.messageId, this.isFromStarred = false, this.enableAppBar=true, this.showChatDeliveryIndicator = true}) : super(key: key);
  final String jid;
  final bool isUser;
  final bool isFromStarred;
  final String? messageId;
  final bool enableAppBar;
  final bool showChatDeliveryIndicator;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final controller = Get.put(ChatController());

  @override
  void initState() {
    controller.init(context,jid: widget.jid,isUser: widget.isUser,isFromStarred: widget.isFromStarred,messageId: widget.messageId, showChatDeliveryIndicator: widget.showChatDeliveryIndicator);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ChatController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // controller.screenHeight = MediaQuery.of(context).size.height;
    // controller.screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: widget.enableAppBar ? getAppBar(context) : null,
        body: SafeArea(
          child: Container(
            width: Get.width,//controller.screenWidth,
            height: Get.height,//controller.screenHeight,
            decoration: BoxDecoration(
              color: MirrorflyUikit.getTheme?.scaffoldColor,
              /*image: const DecorationImage(
                image: AssetImage(chatBg,package: package),
                fit: BoxFit.cover,
              ),*/
            ),
            child: WillPopScope(
              onWillPop: () {
                if (controller.showEmoji.value) {
                  controller.showEmoji(false);
                } else if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
                  controller.focusNode.unfocus();
                } else if (controller.nJid != null) {
                  // Get.offAllNamed(Routes.dashboard);
                  return Future.value(true);
                } else if (controller.isSelected.value) {
                  controller.clearAllChatSelection();
                } else {
                  return Future.value(true);
                }
                return Future.value(false);
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(child: Obx(() {
                        return controller.chatLoading.value
                            ? Center(
                                child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.primaryColor,),
                              )
                            : chatListView(controller.chatList);
                      })),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Obx(() {
                          return Container(
                            color: Colors.transparent,
                            child: controller.isBlocked.value
                                ? userBlocked()
                                : controller.isMemberOfGroup
                                    ? Column(
                              mainAxisAlignment:
                              MainAxisAlignment.end,
                              children: [
                                Obx(() {
                                  if (controller.isReplying.value) {
                                    return ReplyingMessageHeader(
                                      chatMessage:
                                      controller.replyChatMessage,
                                      onCancel: () => controller
                                          .cancelReplyMessage(),
                                      onClick: () {
                                        controller.navigateToMessage(
                                            controller
                                                .replyChatMessage);
                                      },
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }),
                                const AppDivider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding:
                                          const EdgeInsets.only(
                                              left: 10),
                                          margin:
                                          const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              bottom: 10),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: MirrorflyUikit.getTheme!.textSecondaryColor,
                                            ),
                                            borderRadius:
                                            const BorderRadius
                                                .all(
                                                Radius.circular(
                                                    40)),
                                          ),
                                          child: Obx(() {
                                            return messageTypingView(
                                                context);
                                          }),
                                        ),
                                      ),
                                      Obx(() {
                                        return controller
                                            .isUserTyping.value
                                            ? InkWell(
                                            onTap: () {
                                              controller
                                                  .isAudioRecording
                                                  .value ==
                                                  Constants
                                                      .audioRecordDone
                                                  ? controller
                                                  .sendRecordedAudioMessage(context)
                                                  : controller
                                                  .sendMessage(
                                                  controller
                                                      .profile, context);
                                            },
                                            child: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 8.0,
                                                  right: 8.0,
                                                  bottom: 8),
                                              child: SvgPicture.asset(
                                                  sendIcon,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.primaryColor, BlendMode.srcIn)),
                                            ))
                                            : const SizedBox.shrink();
                                      }),
                                      Obx(() {
                                        return controller
                                            .isAudioRecording
                                            .value ==
                                            Constants
                                                .audioRecording
                                            ? InkWell(
                                            onTap: () {
                                              controller
                                                  .stopRecording();
                                            },
                                            child: const Padding(
                                              padding:
                                              EdgeInsets.only(
                                                  bottom:
                                                  8.0),
                                              child:
                                              LottieAnimation(
                                                lottieJson:
                                                audioJson1,
                                                showRepeat: true,
                                                width: 54,
                                                height: 54,
                                              ),
                                            ))
                                            : const SizedBox.shrink();
                                      }),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                emojiLayout(),
                              ],
                            )
                                    : userNoLonger(),
                          );
                        }),
                      ),
                    ],
                  ),
                  Obx(() {
                    return Visibility(
                      visible: controller.showHideRedirectToLatest.value,
                      child: Positioned(
                        bottom: controller.isReplying.value ? 160 : 100,
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            controller.unreadCount.value != 0
                                ? CircleAvatar(
                                    radius: 8,
                                    backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
                                    child: Text(
                                      returnFormattedCount(
                                          controller.unreadCount.value),
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: MirrorflyUikit.getTheme?.colorOnPrimary,
                                          fontFamily: 'sf_ui'),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: FloatingActionButton.small(
                                backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
                                child: Icon(Icons.keyboard_double_arrow_down_rounded,color: MirrorflyUikit.getTheme?.colorOnPrimary,),
                                /*icon: Image.asset(
                                  redirectLastMessage,package: package,
                                  width: 32,
                                  height: 32,
                                ),*/
                                onPressed: () {
                                  //scroll to end
                                  controller.scrollToEnd();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (!controller.isTrail)
                    Obx(() {
                      return !controller.profile.isItSavedContact.checkNull()
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                buttonNotSavedContact(
                                    text: 'Add',
                                    onClick: () {
                                      controller.saveContact();
                                    }),
                                const SizedBox(
                                  width: 8,
                                ),
                                buttonNotSavedContact(
                                    text:
                                        controller.profile.isBlocked.checkNull()
                                            ? 'UnBlock'
                                            : 'Block',
                                    onClick: () {
                                      if (controller.profile.isBlocked
                                          .checkNull()) {
                                        controller.unBlockUser(context);
                                      } else {
                                        controller.blockUser(context);
                                      }
                                    }),
                                const SizedBox(
                                  width: 8,
                                ),
                              ],
                            )
                          : const SizedBox.shrink();
                    })
                  else
                    const SizedBox.shrink()
                ],
              ),
            ),
          ),
        ));
  }

  Widget buttonNotSavedContact(
          {required String text, required Function()? onClick}) =>
      Expanded(
        child: InkWell(
          onTap: onClick,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey,
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  messageTypingView(BuildContext context) {
    return Row(
      children: <Widget>[
        controller.isAudioRecording.value == Constants.audioRecording ||
                controller.isAudioRecording.value == Constants.audioRecordDone
            ? Text(controller.timerInit.value,
                style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? InkWell(
                onTap: () {
                  controller.showHideEmoji(context);
                },
                child: controller.showEmoji.value
                    ? Icon(
                        Icons.keyboard,
                        color: MirrorflyUikit.getTheme?.textPrimaryColor,
                      )
                    : SvgPicture.asset(smileIcon,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.textPrimaryColor, BlendMode.srcIn)))
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordDelete
            ? const Padding(
                padding: EdgeInsets.all(13.0),
                child: LottieAnimation(
                  lottieJson: deleteDustbin,
                  showRepeat: false,
                  width: 25,
                  height: 25,
                ),
              )
            : const SizedBox.shrink(),
        const SizedBox(
          width: 10,
        ),
        controller.isAudioRecording.value == Constants.audioRecording
            ? Expanded(
                child: Dismissible(
                  key: UniqueKey(),
                  dismissThresholds: const {
                    DismissDirection.endToStart: 0.1,
                  },
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
                      controller.cancelRecording();
                      return true;
                    }
                    return false;
                  },
                  onUpdate: (details) {
                    mirrorFlyLog("dismiss", details.progress.toString());
                    if (details.progress > 0.5) {
                      controller.cancelRecording();
                    }
                  },
                  direction: DismissDirection.endToStart,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        height: 50,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('< Slide to Cancel',
                                textAlign: TextAlign.end,style:TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)))),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordDone
            ? Expanded(
                child: InkWell(
                  onTap: () {
                    controller.deleteRecording();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? Expanded(
                child: TextField(
                  onChanged: (text) {
                    controller.isTyping(text);
                  },
                  keyboardType: TextInputType.multiline,
                  keyboardAppearance: MirrorflyUikit.theme == "dark" ? Brightness.dark : Brightness.light,
                  minLines: 1,
                  maxLines: 5,
                  enabled: controller.isAudioRecording.value ==
                          Constants.audioRecordInitial
                      ? true
                      : false,
                  controller: controller.messageController,
                  focusNode: controller.focusNode,
                  cursorColor: MirrorflyUikit.getTheme!.primaryColor,
                  style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor,fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                      hintText: "Start Typing...", border: InputBorder.none,hintStyle: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor)),
                ),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? IconButton(
                onPressed: () {
                  controller.showAttachmentsView(context);
                },
                icon: SvgPicture.asset(attachIcon,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.textPrimaryColor, BlendMode.srcIn)),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? IconButton(
                onPressed: () {
                  controller.startRecording(context);
                },
                icon: SvgPicture.asset(micIcon,package: package,colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.textPrimaryColor, BlendMode.srcIn),),
              )
            : const SizedBox.shrink(),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }

  Widget userBlocked() {
    return Column(
      children: [
        const AppDivider(),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "You have blocked ",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15,color: MirrorflyUikit.getTheme?.textPrimaryColor),
              ),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  controller.profile.getName(),
                  //controller.profile.name.checkNull(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15,color: MirrorflyUikit.getTheme?.textPrimaryColor),
                ),
              ),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'UNBLOCK',
                    style: TextStyle(
                        decoration: TextDecoration.underline, color: MirrorflyUikit.getTheme?.primaryColor)//),
                  ),
                ),
                onTap: () => controller.unBlockUser(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget userNoLonger() {
    return Column(
      children: [
        const AppDivider(),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            "You can't send messages to this group because you're no longer a participant.",
            style: TextStyle(
              fontSize: 15,color: MirrorflyUikit.getTheme?.textPrimaryColor
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return SizedBox(
          height: 250,
          child: emoji.EmojiPicker(
            onBackspacePressed: () {
              controller.isTyping();
              // Do something when the user taps the backspace button (optional)
            },
            onEmojiSelected: (cat, emoji) {
              controller.isTyping();
            },
            textEditingController: controller.messageController,
            config: emoji.Config(
              columns: 7,
              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              initCategory: emoji.Category.RECENT,
              bgColor: MirrorflyUikit.getTheme!.scaffoldColor,
              indicatorColor: MirrorflyUikit.getTheme!.primaryColor,
              iconColor: MirrorflyUikit.getTheme!.textPrimaryColor,
              iconColorSelected: MirrorflyUikit.getTheme!.primaryColor,
              backspaceColor: MirrorflyUikit.getTheme!.primaryColor,
              skinToneDialogBgColor: MirrorflyUikit.getTheme!.textPrimaryColor,
              skinToneIndicatorColor: MirrorflyUikit.getTheme!.textPrimaryColor,
              enableSkinTones: true,
              // showRecentsTab: true,
              recentsLimit: 28,
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const emoji.CategoryIcons(),
              buttonMode: emoji.ButtonMode.CUPERTINO,
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget chatListView(List<ChatMessageModel> chatList) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ScrollablePositionedList.builder(
        itemScrollController: controller.newScrollController,
        itemPositionsListener: controller.newitemPositionsListener,
        itemCount: chatList.length,
        shrinkWrap: true,
        reverse: true,
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              groupedDateMessage(index, chatList) != null
                  ? NotificationMessageView(
                      chatMessage: groupedDateMessage(index, chatList))
                  : const SizedBox.shrink(),
              (chatList[index].messageType.toUpperCase() !=
                      Constants.mNotification)
                  ? SwipeTo(
                      key: ValueKey(chatList[index].messageId),
                      onRightSwipe: () {
                        if (!chatList[index].isMessageRecalled.value &&
                            !chatList[index].isMessageDeleted &&
                            chatList[index]
                                    .messageStatus.value
                                    .checkNull()
                                    .toString() !=
                                "N") {
                          controller.handleReplyChatMessage(chatList[index]);
                        }
                      },
                      animationDuration: const Duration(milliseconds: 300),
                      offsetDx: 0.2,
                      child: GestureDetector(
                        onLongPress: widget.enableAppBar ? () {
                          debugPrint("LongPressed");
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (!controller.isSelected.value) {
                            controller.isSelected(true);
                            controller.addChatSelection(chatList[index]);
                          }
                        } : null,
                        onTap: () {
                          debugPrint("On Tap");
                          if (controller.isSelected.value) {
                            if(controller.isSelected.value) {
                              controller.selectedChatList
                                  .contains(chatList[index])
                                  ? controller
                                  .clearChatSelection(chatList[index])
                                  : controller
                                  .addChatSelection(chatList[index]);
                            }
                            controller.getMessageActions();
                          } else {
                            var replyChat =
                                chatList[index].replyParentChatMessage;
                            if (replyChat != null) {
                              debugPrint("reply tap ");
                              var chat = chatList.indexWhere((element) =>
                                  element.messageId == replyChat.messageId);
                              if (!chat.isNegative) {
                                controller.navigateToMessage(chatList[chat],
                                    index: chat);
                              }
                            }
                          }
                        },
                        onDoubleTap: () {
                          controller.translateMessage(index);
                        },
                        child: Obx(() {
                          return Container(
                            key: Key(chatList[index].messageId),
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
                                    visible:
                                        chatList[index].isMessageSentByMe &&
                                            controller.forwardMessageVisibility(
                                                chatList[index]),
                                    child: IconButton(
                                        onPressed: () {
                                          controller.forwardSingleMessage(
                                              chatList[index].messageId);
                                        },
                                        icon: SvgPicture.asset(forwardMedia,package: package,colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.textPrimaryColor, BlendMode.srcIn),)),
                                  ),
                                  ChatContainer(
                                    chatMessage: chatList[index],
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SenderHeader(
                                            isGroupProfile: controller
                                                .profile.isGroupProfile,
                                            chatList: chatList,
                                            index: index),
                                        (chatList[index]
                                                    .replyParentChatMessage ==
                                                null)
                                            ? const SizedBox.shrink()
                                            : ReplyMessageHeader(
                                                chatMessage: chatList[index]),

                                        Obx(() {
                                          return MessageContent(
                                              chatList: chatList,
                                              index: index,
                                              onPlayAudio: () {
                                                if (controller.isAudioRecording
                                                        .value ==
                                                    Constants.audioRecording) {
                                                  controller.stopRecording();
                                                }
                                                controller
                                                    .playAudio(chatList[index]);
                                              },
                                              onSeekbarChange: (double value) {
                                                controller.onSeekbarChange(
                                                    value, chatList[index]);
                                              },
                                              isSelected:
                                                  controller.isSelected.value, showChatDeliveryIndicator: widget.showChatDeliveryIndicator,);
                                        })
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        !chatList[index].isMessageSentByMe &&
                                            controller.forwardMessageVisibility(
                                                chatList[index]),
                                    child: IconButton(
                                        onPressed: () {
                                          controller.forwardSingleMessage(
                                              chatList[index].messageId);
                                        },
                                        icon: SvgPicture.asset(forwardMedia,package: package,)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    )
                  : NotificationMessageView(
                      chatMessage: chatList[index].messageTextContent)
            ],
          );
        },
      ),
    );
  }

  Widget chatGroupedListView(List<ChatMessageModel> chatList) {
    return GroupedListView<dynamic, String>(
      elements: chatList,
      groupBy: (element) => element['group'],
      groupSeparatorBuilder: (String groupByValue) => Text(groupByValue),
      itemBuilder: (context, dynamic element) => Text(element['name']),
      // itemComparator: (item1, item2) => item1['name'].compareTo(item2['name']), // optional
      useStickyGroupSeparators: true,
      // optional
      floatingHeader: true,
      // optional
      order: GroupedListOrder.ASC, // optional
    );
  }

  /*handleMediaUploadDownload(
      int mediaDownloadStatus, ChatMessageModel chatList) {
    switch (chatList.isMessageSentByMe
        ? chatList.mediaChatMessage?.mediaUploadStatus
        : mediaDownloadStatus) {
      case Constants.mediaDownloaded:
      case Constants.mediaUploaded:
        if (chatList.messageType.toUpperCase() == 'VIDEO') {
          if (controller.checkFile(
                  chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaDownloaded ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaUploaded ||
                  chatList.isMessageSentByMe)) {
            Get.toNamed(Routes.videoPlay, arguments: {
              "filePath": chatList.mediaChatMessage!.mediaLocalStoragePath,
            });
          }
        }
        if (chatList.messageType.toUpperCase() == 'AUDIO') {
          if (controller.checkFile(
                  chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaDownloaded ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaUploaded ||
                  chatList.isMessageSentByMe)) {
            debugPrint("audio click1");
            controller.playAudio(chatList, chatList.mediaChatMessage!.mediaLocalStoragePath);
          } else {
            debugPrint("condition failed");
          }
        }
        break;
      case Constants.mediaDownloadedNotAvailable:
      case Constants.mediaNotDownloaded:
        //download
        debugPrint("Download");
        debugPrint(chatList.messageId);
        chatList.mediaChatMessage!.mediaDownloadStatus =
            Constants.mediaDownloading;
        controller.downloadMedia(chatList.messageId);
        break;
      case Constants.mediaUploadedNotAvailable:
        //upload
        break;
      case Constants.mediaNotUploaded:
      case Constants.mediaDownloading:
      case Constants.mediaUploading:
        //return uploadingView(chatList.messageType);
      // break;
    }
  }*/
  selectedAppBar() {
    return AppBar(
      backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      actionsIconTheme: IconThemeData(
          color: MirrorflyUikit.getTheme?.colorOnAppbar ??
              iconColor),
      iconTheme: IconThemeData(
          color: MirrorflyUikit.getTheme?.colorOnAppbar ??
              iconColor),
      leading: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          controller.clearAllChatSelection();
        },
      ),
      title: Text(controller.selectedChatList.length.toString(),style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
      actions: [
        CustomActionBarIcons(
            availableWidth: Get.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              // controller.getOptionStatus('Reply')
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller
                        .handleReplyChatMessage(controller.selectedChatList[0]);
                    controller
                        .clearChatSelection(controller.selectedChatList[0]);
                  },
                  icon: SvgPicture.asset(replyIcon,package: package,colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),
                  tooltip: 'Reply',
                ),
                overflowWidget: Text("Reply",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeReplied.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: 'Reply',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller
                      .handleReplyChatMessage(controller.selectedChatList[0]);
                  controller.clearChatSelection(controller.selectedChatList[0]);
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.checkBusyStatusForForward(context);
                  },
                  icon: SvgPicture.asset(forwardIcon,package: package,colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),
                  tooltip: 'Forward',
                ),
                overflowWidget: Text("Forward",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeForwarded.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: 'Forward',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.checkBusyStatusForForward(context);
                },
              ),
              /*controller.getOptionStatus('Favourite')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.favouriteMessage();
                  },
                  // icon: controller.getOptionStatus('Favourite') ? const Icon(Icons.star_border_outlined)
                  // icon: controller.selectedChatList[0].isMessageStarred
                  icon: SvgPicture.asset(favouriteIcon,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),
                  tooltip: 'Favourite',
                ),
                overflowWidget: Text("Favourite",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeStarred.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: 'favourite',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.favouriteMessage();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.favouriteMessage();
                  },
                  // icon: controller.getOptionStatus('Favourite') ? const Icon(Icons.star_border_outlined)
                  // icon: controller.selectedChatList[0].isMessageStarred
                  icon: SvgPicture.asset(unFavouriteIcon,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),
                  tooltip: 'unFavourite',
                ),
                overflowWidget: Text("unFavourite",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeUnStarred.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: 'favourite',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.favouriteMessage();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.deleteMessages(context);
                  },
                  icon: SvgPicture.asset(deleteIcon,package: package,colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),
                  tooltip: 'Delete',
                ),
                overflowWidget: Text("Delete",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: ShowAsAction.always,
                keyValue: 'Delete',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.deleteMessages(context);
                },
              ),
              /*controller.getOptionStatus('Report')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.reportChatOrUser(context);
                    },
                    icon: const Icon(Icons.report_problem_rounded)),
                overflowWidget: Text("Report",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canShowReport.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: 'Report',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.reportChatOrUser(context);
                },
              ),
              /*controller.selectedChatList.length > 1 ||
                      controller.selectedChatList[0].messageType !=
                          Constants.mText
                  ? customEmptyAction()
                  : ,*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.closeKeyBoard();
                    controller.copyTextMessages();
                  },
                  icon: SvgPicture.asset(
                    copyIcon,
                    fit: BoxFit.contain,
                    package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn),
                  ),
                  tooltip: 'Copy',
                ),
                overflowWidget: Text("Copy",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeCopied.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: 'Copy',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.copyTextMessages();
                },
              ),
              /*controller.getOptionStatus('Message Info')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    // Get.back();
                    controller.messageInfo();
                  },
                  icon: SvgPicture.asset(
                    infoIcon,
                    fit: BoxFit.contain,
                    package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)
                  ),
                  tooltip: 'Message Info',
                ),
                overflowWidget: Text("Message Info",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canShowInfo.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: 'MessageInfo',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.messageInfo();
                },
              ),
              /*controller.getOptionStatus('Share')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(shareIcon,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),
                  tooltip: 'Share',
                ),
                overflowWidget: Text("Share",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeShared.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: 'Share',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.share();
                },
              ),
            ]),
      ],
    );
  }

  chatAppBar() {
    return Obx(() {
      return AppBar(
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
        actionsIconTheme: IconThemeData(
            color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                iconColor),
        iconTheme: IconThemeData(
            color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                iconColor),
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () {
            if (controller.showEmoji.value) {
              controller.showEmoji(false);
            } else if (controller.nJid != null) {
              // Get.offAllNamed(Routes.dashboard);
              Navigator.pop(context);
            } else {
              // Get.back();
              Navigator.pop(context);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              const Icon(Icons.arrow_back),
              const SizedBox(
                width: 10,
              ),
              ImageNetwork(
                url: controller.profile.image.checkNull(),
                width: 35,
                height: 35,
                clipOval: true,
                isGroup: controller.profile.isGroupProfile.checkNull(),
                errorWidget: controller.profile.isGroupProfile ?? false
                    ? ClipOval(
                        child: Image.asset(
                          groupImg,package: package,
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ProfileTextImage(
                        text: controller.profile.getName(),
                        /*controller.profile.name.checkNull().isEmpty
                            ? controller.profile.nickName.checkNull().isEmpty
                                ? controller.profile.mobileNumber.checkNull()
                                : controller.profile.nickName.checkNull()
                            : controller.profile.name.checkNull(),*/
                        radius: 18,
                      ),
                blocked: controller.profile.isBlockedMe.checkNull() ||
                    controller.profile.isAdminBlocked.checkNull(),
                unknown: (!controller.profile.isItSavedContact.checkNull() ||
                    controller.profile.isDeletedContact()),
              ),
            ],
          ),
        ),
        title: SizedBox(
          width: (Get.width) / 1.9,
          child: InkWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.profile.getName(),
                  /*controller.profile.name.checkNull().isEmpty
                      ? controller.profile.nickName.checkNull()
                      : controller.profile.name.checkNull(),*/
                  overflow: TextOverflow.fade,
                  style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
                ),
                Obx(() {
                  return controller.groupParticipantsName.isNotEmpty
                      ? SizedBox(
                          width: (Get.width) * 0.90,
                          height: 15,
                          child: Marquee(
                              text:
                                  "${controller.groupParticipantsName}       ",
                              style: TextStyle(fontSize: 12,color: MirrorflyUikit.getTheme?.colorOnAppbar)))
                      : controller.subtitle.isNotEmpty
                          ? Text(
                              controller.subtitle,
                              style: TextStyle(fontSize: 12,color: MirrorflyUikit.getTheme?.colorOnAppbar),
                              overflow: TextOverflow.fade,
                            )
                          : const SizedBox();
                })
              ],
            ),
            onTap: () {
              mirrorFlyLog("title clicked",
                  controller.profile.isGroupProfile.toString());
              controller.infoPage(context);
            },
          ),
        ),
        actions: [
          CustomActionBarIcons(
            availableWidth: Get.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.clearUserChatHistory(context);
                  },
                  icon: const Icon(Icons.cancel),
                ),
                overflowWidget: Text("Clear Chat",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: ShowAsAction.never,
                keyValue: 'Clear Chat',
                onItemClick: () {
                  controller.closeKeyBoard();
                  debugPrint("Clear chat tap");
                  controller.clearUserChatHistory(context);
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.reportChatOrUser(context);
                  },
                  icon: const Icon(Icons.report_problem_rounded),
                ),
                overflowWidget: Text("Report",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: ShowAsAction.never,
                keyValue: 'Report',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.reportChatOrUser(context);
                },
              ),
              controller.isBlocked.value
                  ? CustomAction(
                      visibleWidget: IconButton(
                        onPressed: () {
                          // Get.back();
                          controller.unBlockUser(context);
                        },
                        icon: const Icon(Icons.block),
                      ),
                      overflowWidget: Text("Unblock",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                      showAsAction: ShowAsAction.never,
                      keyValue: 'Unblock',
                      onItemClick: () {
                        debugPrint('onItemClick unblock');
                        controller.unBlockUser(context);
                      },
                    )
                  : CustomAction(
                      visibleWidget: IconButton(
                        onPressed: () {
                          // Get.back();
                          controller.blockUser(context);
                        },
                        icon: const Icon(Icons.block),
                      ),
                      overflowWidget: Text("Block",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                      showAsAction: controller.profile.isGroupProfile ?? false
                          ? ShowAsAction.gone
                          : ShowAsAction.never,
                      keyValue: 'Block',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.blockUser(context);
                      },
                    ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
                overflowWidget: Text("Search",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: ShowAsAction.never,
                keyValue: 'Search',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.gotoSearch();
                },
              ),
              /*CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined),
                ),
                overflowWidget: GestureDetector(
                  onTap: () {
                    controller.closeKeyBoard();
                    controller.exportChat();
                  },
                  child: Text("Email Chat",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                ),
                showAsAction: ShowAsAction.never,
                keyValue: 'EmailChat',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.exportChat();
                },
              ),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shortcut),
                ),
                overflowWidget: Text("Add Chat Shortcut",style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: ShowAsAction.never,
                keyValue: 'Shortcut',
                onItemClick: () {
                  controller.closeKeyBoard();
                },
              ),
            ],
          ),
        ],
      );
    });
  }

  getAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: Obx(() {
        return Container(
          child: controller.isSelected.value ? selectedAppBar() : chatAppBar(),
        );
      }),
    );
  }

  customEmptyAction() {
    return CustomAction(
        visibleWidget: const SizedBox.shrink(),
        overflowWidget: const SizedBox.shrink(),
        showAsAction: ShowAsAction.always,
        keyValue: 'Empty',
        onItemClick: () {});
  }
}
