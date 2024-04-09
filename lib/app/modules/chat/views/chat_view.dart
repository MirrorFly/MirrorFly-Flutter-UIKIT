import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/views/chat_list_view.dart';


import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../../widgets/lottie_animation.dart';
import '../chat_widgets.dart';
import '../controllers/chat_controller.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.jid, this.isUser=false, this.messageId, this.isFromStarred = false, this.enableAppBar=true, this.showChatDeliveryIndicator = true});
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
    controller.profile.isGroupProfile.checkNull() ? debugPrint("this is group profile") : debugPrint("this is single page");
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
          child: GestureDetector(
            onTap: (){
              debugPrint("tapping on screen");
              if(controller.isKeyboardVisible.value){
                FocusScope.of(context).unfocus();
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,//controller.screenWidth,
              height: MediaQuery.of(context).size.height,//controller.screenHeight,
              decoration: BoxDecoration(
                color: MirrorflyUikit.getTheme?.scaffoldColor,
                /*image: const DecorationImage(
                  image: AssetImage(chatBg,package: package),
                  fit: BoxFit.cover,
                ),*/
              ),
              child: PopScope(
                canPop: false,
                onPopInvoked: (didPop) {
                  if (didPop) {
                    return;
                  }
                  mirrorFlyLog("viewInsets", MediaQuery.of(context).viewInsets.bottom.toString());
                  if (controller.showEmoji.value) {
                    controller.showEmoji(false);
                  } else if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
                    controller.focusNode.unfocus();
                  } else if (controller.nJid != null) {
                    Navigator.pop(context);
                  } else if (controller.isSelected.value) {
                    controller.clearAllChatSelection();
                  } else {
                    Navigator.pop(context);
                  }
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
                              : ChatListView(chatController: controller, chatList: controller.chatList);
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
                                  controller.emojiLayout(textEditingController: controller.messageController, sendTypingStatus: true),
                                ],
                              )
                                  : !controller.availableFeatures.value.isGroupChatAvailable.checkNull()
                                  ? featureNotAvailable()
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
                                      text: AppConstants.add,
                                      onClick: () {
                                        controller.saveContact();
                                      }),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  buttonNotSavedContact(
                                      text:
                                          controller.profile.isBlocked.checkNull()
                                              ? AppConstants.unblock
                                              : AppConstants.block,
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
                            child: Text(AppConstants.slideToCancel,
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
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Text(
                      AppConstants.cancel,
                      textAlign: TextAlign.end,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? Expanded(
                child: TextField(
                  onTap: (){
                    controller.isKeyboardVisible(true);
                  },
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
                      hintText: AppConstants.startTyping, border: InputBorder.none,hintStyle: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor)),
                ),
              )
            : const SizedBox.shrink(),
        (controller.isAudioRecording.value == Constants.audioRecordInitial && controller.availableFeatures.value.isAttachmentAvailable.checkNull())
            ? IconButton(
                onPressed: () {
                  controller.showAttachmentsView(context);
                },
                icon: SvgPicture.asset(attachIcon,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.textPrimaryColor, BlendMode.srcIn)),
              )
            : const SizedBox.shrink(),
        (controller.isAudioRecording.value == Constants.audioRecordInitial &&
            controller.availableFeatures.value.isAudioAttachmentAvailable.checkNull())
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
                AppConstants.youHaveBlocked,
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
                      AppConstants.unblock.toLowerCase(),
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
            AppConstants.youCantSentMessageNoLonger,
            style: TextStyle(
              fontSize: 15,color: MirrorflyUikit.getTheme?.textPrimaryColor
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget featureNotAvailable() {
    return Column(
      children: [
        const AppDivider(),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            AppConstants.featureNotAvailable,
            style: const TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

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
            availableWidth: MediaQuery.of(context).size.width / 2, // half the screen width
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
                  tooltip: AppConstants.reply,
                ),
                overflowWidget: Text(AppConstants.reply,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: (controller.canBeReplied.value && controller.availableFeatures.value.isClearChatAvailable.checkNull())
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: AppConstants.reply,
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
                  tooltip: AppConstants.forward,
                ),
                overflowWidget: Text(AppConstants.forward,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeForwarded.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: AppConstants.forward,
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
                  tooltip: AppConstants.favourite,
                ),
                overflowWidget: Text(AppConstants.favourite,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeStarred.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: AppConstants.favourite,
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
                  tooltip: AppConstants.unFavourite,
                ),
                overflowWidget: Text(AppConstants.unFavourite,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeUnStarred.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: AppConstants.unFavourite,
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
                  tooltip: AppConstants.delete,
                ),
                overflowWidget: Text(AppConstants.delete,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.availableFeatures.value.isDeleteMessageAvailable.checkNull() ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: AppConstants.delete,
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
                overflowWidget: Text(AppConstants.report,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canShowReport.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: AppConstants.report,
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
                overflowWidget: Text(AppConstants.copy,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
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
                  tooltip: AppConstants.messageInfo,
                ),
                overflowWidget: Text(AppConstants.messageInfo,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canShowInfo.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: AppConstants.messageInfo,
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
                  tooltip: AppConstants.share,
                ),
                overflowWidget: Text(AppConstants.share,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.canBeShared.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: AppConstants.share,
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.share();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(shareIcon),
                  tooltip: 'Edit Message',
                ),
                overflowWidget: const Text("Edit Message"),
                showAsAction: ShowAsAction.gone,//controller.canEditMessage.value ? ShowAsAction.never : ShowAsAction.gone,
                keyValue: 'Edit Message',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.editMessage(context);
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
          width: (MediaQuery.of(context).size.width) / 1.9,
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
                          width: (MediaQuery.of(context).size.width) * 0.90,
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
            availableWidth: MediaQuery.of(context).size.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.clearUserChatHistory(context);
                  },
                  icon: const Icon(Icons.cancel),
                ),
                overflowWidget: Text(AppConstants.clearChat,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: controller.availableFeatures.value.isClearChatAvailable.checkNull() ? ShowAsAction.never : ShowAsAction.gone,
                keyValue: AppConstants.clearChat,
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
                overflowWidget: Text(AppConstants.report,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: ShowAsAction.never,
                keyValue: AppConstants.report,
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
                      overflowWidget: Text(AppConstants.unblock,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                      showAsAction: ShowAsAction.never,
                      keyValue: AppConstants.unblock,
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
                      overflowWidget: Text(AppConstants.block,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                      showAsAction: controller.profile.isGroupProfile ?? false
                          ? ShowAsAction.gone
                          : ShowAsAction.never,
                      keyValue: AppConstants.block,
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
                overflowWidget: Text(AppConstants.search,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: ShowAsAction.never,
                keyValue: AppConstants.search,
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
                overflowWidget: Text(AppConstants.addChatShortcut,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                showAsAction: ShowAsAction.gone,
                keyValue: AppConstants.addChatShortcut,
                onItemClick: () {
                  controller.closeKeyBoard();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.makeVideoCall();
                  },
                  icon: SvgPicture.asset(videoCallIcon,package: package,fit: BoxFit.contain, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),
                ),
                overflowWidget: const  Text("Video Call"),
                showAsAction: controller.isVideoCallAvailable ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Video Call',
                onItemClick: () {
                  controller.makeVideoCall();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.makeVoiceCall();
                  },
                  icon: SvgPicture.asset(audioCallIcon,package: package,fit: BoxFit.contain, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)),
                ),
                overflowWidget: const Text("Call"),
                showAsAction: controller.isAudioCallAvailable ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Audio Call',
                onItemClick: () {
                  controller.makeVoiceCall();
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
}
