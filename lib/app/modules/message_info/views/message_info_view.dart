import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/model/chat_message_model.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../chat/chat_widgets.dart';

import '../controllers/message_info_controller.dart';

class MessageInfoView extends StatefulWidget {
  const MessageInfoView(
      {super.key,
      required this.chatMessage,
      required this.isGroupProfile,
      required this.jid,
      this.enableAppBar = true,
      this.showChatDeliveryIndicator = true});

  // final String messageID;
  final ChatMessageModel chatMessage;
  final bool isGroupProfile;
  final String jid;
  final bool enableAppBar;
  final bool showChatDeliveryIndicator;

  @override
  State<MessageInfoView> createState() => _MessageInfoViewState();
}

class _MessageInfoViewState extends State<MessageInfoView> {
  var controller = Get.put(MessageInfoController());

  @override
  void initState() {
    controller.init(widget.chatMessage, widget.isGroupProfile, widget.jid);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<MessageInfoController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: widget.enableAppBar
            ? AppBar(
                iconTheme: IconThemeData(
                    color: MirrorflyUikit.getTheme?.colorOnAppbar),
                backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
                title: Text(
                  AppConstants.messageInfo,
                  style:
                      TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
                ),
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                          color: MirrorflyUikit.getTheme?.chatBubblePrimaryColor
                              .color, //chatSentBgColor,
                          border: Border.all(
                            color: MirrorflyUikit.getTheme!
                                .chatBubblePrimaryColor.textSecondaryColor
                                .withOpacity(0.2), //chatSentBgColor
                          )),
                      child: Obx(() {
                        return Column(
                          children: [
                            controller.chatMessage[0].isThisAReplyMessage
                                ? controller.chatMessage[0]
                                            .replyParentChatMessage ==
                                        null
                                    ? messageNotAvailableWidget(
                                        controller.chatMessage[0])
                                    : ReplyMessageHeader(
                                        chatMessage: controller.chatMessage[0],
                                      )
                                : const SizedBox.shrink(),
                            SenderHeader(
                                isGroupProfile: controller.isGroupProfile.value,
                                chatList: controller.chatMessage,
                                index: 0),
                            //getMessageContent(index, context, chatList),
                            MessageContent(
                              chatList: controller.chatMessage,
                              index: 0,
                              showChatDeliveryIndicator:
                                  widget.showChatDeliveryIndicator,
                              onPlayAudio: () {
                                controller.playAudio(controller.chatMessage[0]);
                              },
                              onSeekbarChange: (value) {
                                controller.onSeekbarChange(
                                    value, controller.chatMessage[0]);
                              },
                            )
                            //MessageHeader(chatList: controller.chatMessage, isTapEnabled: false,),
                            //MessageContent(chatList: controller.chatMessage, isTapEnabled: false,),
                          ],
                        );
                      }),
                    ),
                  ),
                  statusView(context),
                ],
              ),
            ),
          ),
        ));
  }

  Widget statusView(BuildContext context) {
    return Obx(() {
      return controller.isGroupProfile.value
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppDivider(
                  padding: EdgeInsets.only(top: 8),
                ),
                ListItem(
                  leading: !controller.visibleDeliveredList.value
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor:
                              MirrorflyUikit.getTheme?.primaryColor,
                          child: Icon(
                            Icons.add,
                            color: MirrorflyUikit.getTheme?.colorOnPrimary,
                            size: 16,
                          ),
                        ) //SvgPicture.asset(icExpand,package: package,)
                      : CircleAvatar(
                          radius: 10,
                          backgroundColor:
                              MirrorflyUikit.getTheme?.primaryColor,
                          child: Icon(
                            Icons.remove,
                            color: MirrorflyUikit.getTheme?.colorOnPrimary,
                            size: 16,
                          ),
                        ),
                  /*SvgPicture.asset(
                          icCollapse,
                          package: package,
                        ),*/
                  title: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    child: Text(
                      "${AppConstants.deliveredTo} ${controller.messageDeliveredList.length} ${AppConstants.of} ${controller.statusCount.value}",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: MirrorflyUikit.getTheme?.textPrimaryColor),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  onTap: () {
                    controller.onDeliveredClick();
                  },
                ),
                Visibility(
                    visible: controller.visibleDeliveredList.value,
                    child: controller.messageDeliveredList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.messageDeliveredList.length,
                            itemBuilder: (cxt, index) {
                              var member = controller
                                  .messageDeliveredList[index].profileDetails!;
                              return memberItem(
                                name: member.name.checkNull().isNotEmpty
                                    ? member.name.checkNull()
                                    : member.nickName.checkNull(),
                                image: member.image.checkNull(),
                                status: controller.chatDate(context,
                                    controller.messageDeliveredList[index]),
                                onTap: () {},
                                blocked: member.isBlockedMe.checkNull() ||
                                    member.isAdminBlocked.checkNull(),
                                unknown:
                                    (!member.isItSavedContact.checkNull() ||
                                        member.isDeletedContact()),
                              );
                            })
                        : emptyDeliveredSeen(
                            context, AppConstants.sentNotDelivered)),
                const AppDivider(
                  padding: EdgeInsets.only(top: 8),
                ),
                ListItem(
                  leading: !controller.visibleReadList.value
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor:
                              MirrorflyUikit.getTheme?.primaryColor,
                          child: Icon(
                            Icons.add,
                            color: MirrorflyUikit.getTheme?.colorOnPrimary,
                            size: 16,
                          ),
                        ) //SvgPicture.asset(icExpand,package: package,)
                      : CircleAvatar(
                          radius: 10,
                          backgroundColor:
                              MirrorflyUikit.getTheme?.primaryColor,
                          child: Icon(
                            Icons.remove,
                            color: MirrorflyUikit.getTheme?.colorOnPrimary,
                            size: 16,
                          ),
                        ),
                  /*SvgPicture.asset(
                          icCollapse,
                          package: package,
                        ),*/
                  title: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    child: Text(
                      "${AppConstants.readBy} ${controller.messageReadList.length} ${AppConstants.of} ${controller.statusCount.value}",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: MirrorflyUikit.getTheme?.textPrimaryColor),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  onTap: () {
                    controller.onReadClick();
                  },
                ),
                Visibility(
                    visible: controller.visibleReadList.value,
                    child: controller.messageReadList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.messageReadList.length,
                            itemBuilder: (cxt, index) {
                              var member = controller
                                  .messageReadList[index].profileDetails!;
                              return memberItem(
                                name: member.name.checkNull().isNotEmpty
                                    ? member.name.checkNull()
                                    : member.nickName.checkNull(),
                                image: member.image.checkNull(),
                                status: controller.chatDate(context,
                                    controller.messageDeliveredList[index]),
                                onTap: () {},
                                blocked: member.isBlockedMe.checkNull() ||
                                    member.isAdminBlocked.checkNull(),
                                unknown:
                                    (!member.isItSavedContact.checkNull() ||
                                        member.isDeletedContact()),
                              );
                            })
                        : emptyDeliveredSeen(
                            context, AppConstants.yourMessageNotRead)),
                const AppDivider(
                  padding: EdgeInsets.only(top: 8),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppDivider(
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
                Text(
                  AppConstants.delivered,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: MirrorflyUikit.getTheme?.textPrimaryColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() {
                  return Text(
                    controller.deliveredTime.value == ""
                        ? AppConstants.sentNotDelivered
                        : controller.getChatTime(
                            context, int.parse(controller.deliveredTime.value)),
                    style: TextStyle(
                        color: MirrorflyUikit.getTheme?.textSecondaryColor),
                  );
                }),
                const SizedBox(
                  height: 10,
                ),
                const AppDivider(
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
                Text(
                  AppConstants.read,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: MirrorflyUikit.getTheme?.textPrimaryColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() {
                  return Text(
                    controller.readTime.value == ""
                        ? AppConstants.notRead
                        : controller.getChatTime(
                            context, int.parse(controller.readTime.value)),
                    style: TextStyle(
                        color: MirrorflyUikit.getTheme?.textSecondaryColor),
                  );
                }),
                const SizedBox(
                  height: 10,
                ),
                const AppDivider(
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
              ],
            );
    });
  }

  Widget emptyDeliveredSeen(BuildContext context, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            noChatIcon,
            package: package,
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.0,
                  color: MirrorflyUikit.getTheme?.textPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
