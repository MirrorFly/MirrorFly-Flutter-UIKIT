import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/app/common/AppConstants.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/views/chat_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/image_view/views/image_view_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../mirrorfly_uikit_plugin.dart';
import '../../models.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants.dart';
import '../../data/apputils.dart';
import '../../data/helper.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../dashboard/widgets.dart';
import '../preview_contact/views/preview_contact_view.dart';
import '../video_preview/video_player_view.dart';

class ReplyingMessageHeader extends StatelessWidget {
  const ReplyingMessageHeader({Key? key,
    required this.chatMessage,
    required this.onCancel,
    required this.onClick})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final Function() onCancel;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: MirrorflyUikit.getTheme?.chatBubblePrimaryColor.color.withAlpha(70),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: MirrorflyUikit.getTheme?.chatBubblePrimaryColor.color,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                      child: getReplyTitle(chatMessage.isMessageSentByMe,
                          chatMessage.senderUserName.checkNull().isNotEmpty ? chatMessage.senderUserName : chatMessage.senderNickName),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0, left: 15.0),
                      child: getReplyMessage(
                          chatMessage.messageType.toUpperCase(),
                          chatMessage.messageTextContent,
                          chatMessage.contactChatMessage?.contactName,
                          chatMessage.mediaChatMessage?.mediaFileName,
                          chatMessage.mediaChatMessage,
                          true,MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor,),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  getReplyImageHolder(
                      context,
                      chatMessage,
                      null,
                      chatMessage.mediaChatMessage,
                      70,
                      true,
                      chatMessage.locationChatMessage),
                  GestureDetector(
                    onTap: onCancel,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16.0,top: 10.0,left: 16.0),
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 10,
                          child:
                          Icon(Icons.close, size: 15, color: Colors.black)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

getReplyTitle(bool isMessageSentByMe, String senderUserName) {
  return isMessageSentByMe
      ? Text(
    AppConstants.you,
    style: TextStyle(fontWeight: FontWeight.bold,color:MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor,),
  )
      : Text(senderUserName,
      style: TextStyle(fontWeight: FontWeight.bold,color:MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor,));
}

getReplyMessage(String messageType,
    String? messageTextContent,
    String? contactName,
    String? mediaFileName,
    MediaChatMessage? mediaChatMessage,
    bool isReplying, Color? color) {
  debugPrint(messageType);
  switch (messageType) {
    case Constants.mText:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mText),
          Expanded(child: Text(messageTextContent!,style: TextStyle(color: color),maxLines: 1,overflow: TextOverflow.clip,)),
        ],
      );
    case Constants.mImage:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mImage),
          const SizedBox(
            width: 5,
          ),
          Text(Helper.capitalize(Constants.mImage),style: TextStyle(color: color)),
        ],
      );
    case Constants.mVideo:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mVideo),
          const SizedBox(
            width: 5,
          ),
          Text(Helper.capitalize(Constants.mVideo),style: TextStyle(color: color)),
        ],
      );
    case Constants.mAudio:
      return Row(
        children: [
          isReplying
              ? Helper.forMessageTypeIcon(
              Constants.mAudio,
              mediaChatMessage != null
                  ? mediaChatMessage.isAudioRecorded
                  : true)
              : const SizedBox.shrink(),
          isReplying
              ? const SizedBox(
            width: 5,
          )
              : const SizedBox.shrink(),
          Text(
            Helper.durationToString(Duration(
                milliseconds: mediaChatMessage != null
                    ? mediaChatMessage.mediaDuration
                    : 0)),style: TextStyle(color: color)

          ),
          const SizedBox(
            width: 5,
          ),
          // Text(Helper.capitalize(Constants.mAudio)),
        ],
      );
    case Constants.mContact:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mContact),
          const SizedBox(
            width: 5,
          ),
          Text("${Helper.capitalize(Constants.mContact)} :",style: TextStyle(color: color)),
          const SizedBox(
            width: 5,
          ),
          SizedBox(
              width: 120,
              child: Text(
                contactName!,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,style: TextStyle(color: color)
              )),
        ],
      );
    case Constants.mLocation:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mLocation),
          const SizedBox(
            width: 5,
          ),
          Text(Helper.capitalize(Constants.mLocation),style: TextStyle(color: color)),
        ],
      );
    case Constants.mDocument:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mDocument),
          const SizedBox(
            width: 5,
          ),
          Flexible(child: Text(
            mediaFileName!, overflow: TextOverflow.ellipsis, maxLines: 1,style: TextStyle(color: color))),
        ],
      );
    default:
      return const SizedBox.shrink();
  }
}

// chatMessage.messageType.toUpperCase(),
// chatMessage.mediaChatMessage?.mediaThumbImage,
// chatMessage.locationChatMessage,
getReplyImageHolder(BuildContext context,
    ChatMessageModel chatMessageModel,
    ReplyParentChatMessage? replyChatMessageModel,
    MediaChatMessage? mediaChatMessage,
    double size,
    bool isNotChatItem,
    LocationChatMessage? locationChatMessage) {
  var isReply = false;
  if (mediaChatMessage != null || locationChatMessage != null) {
    isReply = true;
  }
  switch (isReply
      ? mediaChatMessage == null ? Constants.mLocation : mediaChatMessage.messageType
      .checkNull().toUpperCase()
      : replyChatMessageModel?.messageType ?? chatMessageModel.messageType.checkNull().toUpperCase()) {
    case Constants.mImage:
      debugPrint("reply header--> IMAGE");
      return ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
        child: imageFromBase64String(
            isReply
                ? mediaChatMessage!.mediaThumbImage
                : replyChatMessageModel?.mediaChatMessage?.mediaThumbImage ?? chatMessageModel.mediaChatMessage!.mediaThumbImage
                .checkNull(),
            context,
            size,
            size),
      );
    case Constants.mLocation:
    // debugPrint("location mesg--> ${locationChatMessage?.toJson().toString()}");
    // debugPrint("location mesg--> ${chatMessageModel.locationChatMessage?.toJson().toString()}");
      return getLocationImage(
          isReply ? locationChatMessage : replyChatMessageModel?.locationChatMessage ?? chatMessageModel.locationChatMessage,
          size,
          size, isSelected: true);
    case Constants.mVideo:
      return ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
        child: imageFromBase64String(
            isReply
                ? mediaChatMessage!.mediaThumbImage
                : replyChatMessageModel?.mediaChatMessage?.mediaThumbImage ?? chatMessageModel.mediaChatMessage!.mediaThumbImage,
            context,
            size,
            size),
      );
    case Constants.mDocument:
      debugPrint("isNotChatItem--> $isNotChatItem");
      debugPrint("Document --> $isReply");
      debugPrint("Document --> ${isReply
          ? mediaChatMessage!.mediaFileName
          : replyChatMessageModel?.mediaChatMessage?.mediaFileName ?? chatMessageModel.mediaChatMessage!.mediaFileName}");
      return isNotChatItem
          ? SizedBox(height: size)
          : Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            color: Colors.white,
          ),
          child: Center(
            child: getImageHolder(
                isReply
                    ? mediaChatMessage!.mediaFileName
                    : replyChatMessageModel?.mediaChatMessage?.mediaFileName ?? chatMessageModel.mediaChatMessage!.mediaFileName,
                30),
          ));
    case Constants.mAudio:
      return isNotChatItem
          ? SizedBox(height: size)
          : ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(5)),
        child: Container(
          height: size,
          width: size,
          color: audioBgColor,
          child: Center(
            child: SvgPicture.asset(
              (mediaChatMessage?.isAudioRecorded).checkNull()
                  ? mAudioRecordIcon
                  : mAudioIcon,
              package: package,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              height: 18,
            ),
          ),
        ),
      );
    default:
      debugPrint("reply header--> DEFAULT");
      return SizedBox(
        height: size,
      );
  }
}

class ReplyMessageHeader extends StatelessWidget {
  const ReplyMessageHeader({Key? key, required this.chatMessage})
      : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: chatMessage.isMessageSentByMe
            ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor.withAlpha(30)
            : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor.withAlpha(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getReplyTitle(
                    chatMessage.replyParentChatMessage!.isMessageSentByMe,
                    chatMessage.replyParentChatMessage!.senderUserName.checkNull().isNotEmpty ? chatMessage.replyParentChatMessage!.senderUserName : chatMessage.replyParentChatMessage!.senderNickName),
                const SizedBox(height: 5),
                getReplyMessage(
                    chatMessage.replyParentChatMessage!.messageType,
                    chatMessage.replyParentChatMessage?.messageTextContent,
                    chatMessage.replyParentChatMessage?.contactChatMessage
                        ?.contactName,
                    chatMessage.replyParentChatMessage?.mediaChatMessage
                        ?.mediaFileName,
                    chatMessage.replyParentChatMessage?.mediaChatMessage,
                    false,chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor
                    : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor,),
              ],
            ),
          ),
          getReplyImageHolder(
              context,
              chatMessage,
              chatMessage.replyParentChatMessage!,
              chatMessage.replyParentChatMessage!.mediaChatMessage,
              55,
              false,
              chatMessage.replyParentChatMessage!.locationChatMessage),
        ],
      ),
    );
  }
}

Image imageFromBase64String(String base64String, BuildContext context,
    double? width, double? height) {
  var decodedBase64 = base64String.replaceAll("\n", Constants.emptyString);
  Uint8List image = const Base64Decoder().convert(decodedBase64);
  return Image.memory(
    image,
    width: width ?? MediaQuery
        .of(context)
        .size
        .width * 0.60,
    height: height ?? MediaQuery
        .of(context)
        .size
        .height * 0.4,
    fit: BoxFit.cover,
  );
}

Widget getLocationImage(LocationChatMessage? locationChatMessage, double width,
    double height,
    {bool isSelected = false}) {
  return InkWell(
      onTap: isSelected
          ? null
          : () async {
        String googleUrl =
            '${Constants.googleMapQuery}${locationChatMessage!
            .latitude}, ${locationChatMessage.longitude}';
        if (await canLaunchUrl(Uri.parse(googleUrl))) {
          await launchUrl(Uri.parse(googleUrl));
        } else {
          throw 'Could not open the map.';
        }
      },
    child: CachedNetworkImage(imageUrl: Helper.getMapImageUri(
        locationChatMessage!.latitude, locationChatMessage.longitude),errorWidget: (c,l,er){
      return  Center(child: Text(MirrorflyUikit.instance.googleMapKey.isEmpty ? AppConstants.googleMapKeyisRequired : AppConstants.invalidMapKey),);

    },width: width,height: height,fit: BoxFit.fill,)
      /*child: Image.network(
        Helper.getMapImageUri(
            locationChatMessage!.latitude, locationChatMessage.longitude),
        fit: BoxFit.fill,
        width: width,
        height: height,
      )*/);
}

class SenderHeader extends StatelessWidget {
  const SenderHeader({Key? key,
    required this.isGroupProfile,
    required this.chatList,
    required this.index})
      : super(key: key);
  final bool? isGroupProfile;
  final List<ChatMessageModel> chatList;
  final int index;

  bool isSenderChanged(List<ChatMessageModel> messageList, int position) {
    var preposition = position + 1;
    if (!preposition.isNegative) {
      var currentMessage = messageList[position];
      var previousMessage = messageList[preposition];
      if (currentMessage.isMessageSentByMe !=
          previousMessage.isMessageSentByMe ||
          previousMessage.messageType == Constants.msgTypeNotification ||
          (currentMessage.messageChatType == Constants.typeGroupChat &&
              currentMessage.isThisAReplyMessage)) {
        return true;
      }
      var currentSenderJid = currentMessage.senderUserJid.checkNull();
      var previousSenderJid = previousMessage.senderUserJid.checkNull();
      debugPrint("currentSenderJid  : $currentSenderJid");
      debugPrint("previousSenderJid : $previousSenderJid");
      debugPrint("isSenderChanged : ${previousSenderJid != currentSenderJid}");
      return previousSenderJid != currentSenderJid;
    } else {
      return false;
    }
  }

  bool isMessageDateEqual(List<ChatMessageModel> messageList, int position) {
    var previousMessage = getPreviousMessage(messageList, position);
    return previousMessage != null && checkIsNotNotification(previousMessage);
  }

  ChatMessageModel? getPreviousMessage(List<ChatMessageModel> messageList,
      int position) {
    return (position > 0) ? messageList[position + 1] : null;
  }

  bool checkIsNotNotification(ChatMessageModel messageItem) {
    var msgType = messageItem.messageType;
    return msgType.toUpperCase() != Constants.mNotification;
  }

  @override
  Widget build(BuildContext context) {
    // mirrorFlyLog("index", index.toString());
    return Visibility(
      visible: isGroupProfile ?? false
          ? (index == chatList.length - 1 ||
          isSenderChanged(chatList, index)) &&
          !chatList[index].isMessageSentByMe
          : false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
        child: Text(
          chatList[index].senderUserName.checkNull().isNotEmpty ? chatList[index].senderUserName : chatList[index].senderNickName,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(Helper.getColourCode(
                  chatList[index].senderUserName.checkNull().isNotEmpty ? chatList[index].senderUserName : chatList[index].senderNickName))),
        ),
      ),
    );
  }
}

class LocationMessageView extends StatelessWidget {
  const LocationMessageView(
      {Key? key, required this.chatMessage, required this.isSelected, required this.showChatDeliveryIndicator})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final bool isSelected;
  final bool showChatDeliveryIndicator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: getLocationImage(chatMessage.locationChatMessage, 200, 171,
                isSelected: isSelected),
          ),
          Positioned(
            bottom: 8,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                chatMessage.isMessageStarred.value
                    ? SvgPicture.asset(starSmallIcon,package: package,)
                    : const SizedBox.shrink(),
                const SizedBox(
                  width: 5,
                ),
                Obx(() {
                  return getMessageIndicator(chatMessage.messageStatus.value,
                      chatMessage.isMessageSentByMe, chatMessage.messageType,
                      chatMessage.isMessageRecalled.value,showChatDeliveryIndicator: showChatDeliveryIndicator);
                }),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  getChatTime(context, chatMessage.messageSentTime.toInt()),
                  style: TextStyle(
                      fontSize: 12,
                      color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioMessageView extends StatefulWidget {
  const AudioMessageView({Key? key,
    required this.chatMessage,
    required this.onPlayAudio,
    required this.onSeekbarChange, required this.showChatDeliveryIndicator})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final Function() onPlayAudio;
  final Function(double) onSeekbarChange;
  final bool showChatDeliveryIndicator;

  @override
  State<AudioMessageView> createState() => _AudioMessageViewState();
}

class _AudioMessageViewState extends State<AudioMessageView>
    with WidgetsBindingObserver {
  onAudioClick() {
    switch (widget.chatMessage.isMessageSentByMe
        ? widget.chatMessage.mediaChatMessage?.mediaUploadStatus
        : widget.chatMessage.mediaChatMessage?.mediaDownloadStatus) {
      case Constants.mediaDownloaded:
      case Constants.mediaUploaded:
        if (checkFile(
            widget.chatMessage.mediaChatMessage!.mediaLocalStoragePath) &&
            (widget.chatMessage.mediaChatMessage!.mediaDownloadStatus ==
                Constants.mediaDownloaded ||
                widget.chatMessage.mediaChatMessage!.mediaDownloadStatus ==
                    Constants.mediaUploaded ||
                widget.chatMessage.isMessageSentByMe)) {
          //playAudio(chatList, chatList.mediaChatMessage!.mediaLocalStoragePath);
        } else {
          debugPrint("condition failed");
        }
    }
  }

  AudioPlayer player = AudioPlayer();

  RxDouble currentPos = 0.0.obs;

  /*double
        .parse(chatMessage
        .mediaChatMessage!.currentPos
        .toString())
        .obs;*/
  RxBool isPlaying = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentPos = widget.chatMessage.mediaChatMessage!
        .currentPos
        .toDouble()
        .obs;

    player.onPlayerStateChanged.listen(
          (it) {
        switch (it) {
          case PlayerState.playing:
            isPlaying(true);
            break;
          case PlayerState.stopped:
            isPlaying(false);
            break;
          case PlayerState.paused:
            isPlaying(false);
            break;
          case PlayerState.completed:
            break;
          default:
            break;
        }
      },
    );
    player.onPlayerComplete.listen((event) {
      isPlaying(false);
      currentPos(0);
      widget.chatMessage.mediaChatMessage!.currentPos = 0;
      player.stop();
    });

    // player.onDurationChanged.listen((Duration p) {
    //   mirrorFlyLog('p.inMilliseconds', p.inMilliseconds.toString());
    //   widget.chatMessage.mediaChatMessage!.currentPos = p.inMilliseconds;
    //   currentPos(p.inMilliseconds.toDouble());
    //   currentPos.refresh();
    // });
    player.onPositionChanged.listen((Duration  p) {
      mirrorFlyLog('p.inMilliseconds', p.inMilliseconds.toString());
      widget.chatMessage.mediaChatMessage!.currentPos = p.inMilliseconds;
      currentPos(p.inMilliseconds.toDouble());
      currentPos.refresh();
  });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        debugPrint('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        debugPrint('appLifeCycleState paused');
        isPlaying(false);
        player.stop();
        break;
      case AppLifecycleState.detached:
        debugPrint('appLifeCycleState detached');
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    var currentPos = 0.0;
    debugPrint(
        "max duration--> ${double.parse(
            widget.chatMessage.mediaChatMessage!.mediaDuration.toString())}");
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.chatMessage.isMessageSentByMe
              ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.color.withAlpha(50)
              : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.color.withAlpha(50)//chatReplySenderColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.transparent,
      ),
      width: Get.width * 0.70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: widget.chatMessage.isMessageSentByMe
                  ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor.withAlpha(50)
                  : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.color.withAlpha(50),
            ),
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.chatMessage.mediaChatMessage!.isAudioRecorded
                    ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      audioMicBg,package: package,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    SvgPicture.asset(
                      audioMic1,package: package,
                      fit: BoxFit.contain,
                    ),
                  ],
                )
                    : SvgPicture.asset(
                  musicIcon,package: package,
                  fit: BoxFit.contain,
                ),
                getImageOverlay(context,widget.chatMessage, onAudio: () {
                  // widget.onPlayAudio();
                  playAudio(widget.chatMessage);
                }), //widget.onPlayAudio),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: SliderTheme(
                          data: SliderThemeData(
                            thumbColor: widget.chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor,
                            trackHeight: 2,
                            overlayShape: SliderComponentShape.noThumb,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 4),
                          ),
                          child: Slider(
                            value: currentPos,
                            /*double.parse(chatMessage
                                .mediaChatMessage!.currentPos
                                .toString()),*/
                            min: 0.0,
                            activeColor: widget.chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor,
                            thumbColor: widget.chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor,
                            inactiveColor: widget.chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor.withAlpha(60) : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor.withAlpha(60),
                            max: double.parse(widget
                                .chatMessage.mediaChatMessage!.mediaDuration
                                .toString()),
                            divisions: widget
                                .chatMessage.mediaChatMessage!.mediaDuration,
                            onChanged: (double value) {
                              debugPrint('onChanged $value');
                              /*setState(() {
                                currentPos = value;
                              });*/
                              widget.onSeekbarChange(value);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Text(
                          Helper.durationToString(Duration(
                              milliseconds: currentPos !=
                                  0.0 // chatMessage.mediaChatMessage?.currentPos != 0
                                  ? currentPos
                                  .toInt() /*chatMessage
                                              .mediaChatMessage?.currentPos ??
                                          0*/
                                  : widget.chatMessage.mediaChatMessage!
                                  .mediaDuration)),
                          style: TextStyle(
                              color: widget.chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.chatMessage.isMessageStarred.value
                    ? SvgPicture.asset(starSmallIcon,package: package, colorFilter: ColorFilter.mode(widget.chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn))
                    : const SizedBox.shrink(),
                const SizedBox(
                  width: 5,
                ),
                Obx(() {
                  return getMessageIndicator(
                      widget.chatMessage.messageStatus.value,
                      widget.chatMessage.isMessageSentByMe,
                      widget.chatMessage.messageType,
                      widget.chatMessage.isMessageRecalled.value,showChatDeliveryIndicator: widget.showChatDeliveryIndicator) ;
                }),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  getChatTime(
                      context, widget.chatMessage.messageSentTime.toInt()),
                  style: TextStyle(
                      fontSize: 12,
                      color: widget.chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  playAudio(ChatMessageModel chatMessage) {
    var maxPos =
    double.parse(chatMessage.mediaChatMessage!.mediaDuration.toString());
    /*if(!(currentPos >= 0.0 && currentPos <= maxPos)){
      currentPos(maxPos);
    }*/
    showDialog(
      context: context, builder: (BuildContext context) {
        return Dialog(
          child: WillPopScope(
            onWillPop: () {
              // currentPos(0);
              isPlaying(false);
              player.stop();
              return Future.value(true);
            },
            child: Container(
              decoration: BoxDecoration(
                color: chatMessage.isMessageSentByMe
                    ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.color
                    : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.color
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  widget.chatMessage.mediaChatMessage!.isAudioRecorded
                      ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        audioMicBg,package: package,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                      SvgPicture.asset(
                        audioMic1,package: package,
                        fit: BoxFit.contain,
                      ),
                    ],
                  )
                      : SvgPicture.asset(
                    musicIcon,package: package,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Obx(() {
                    return InkWell(
                      onTap: () async {
                        if (!isPlaying.value) {
                          debugPrint(chatMessage.mediaChatMessage!.mediaLocalStoragePath);
                          debugPrint(chatMessage.mediaChatMessage?.mediaFileType);
                          debugPrint(chatMessage.mediaChatMessage?.currentPos.toString());
                          debugPrint(chatMessage.toJson().toString());
                         await player.play(DeviceFileSource(chatMessage.mediaChatMessage!.mediaLocalStoragePath),position: Duration(
                              milliseconds:
                              chatMessage.mediaChatMessage!.currentPos));
                          /*int result = await player.play(
                              chatMessage.mediaChatMessage!.mediaLocalStoragePath,
                              position: Duration(
                                  milliseconds:
                                  chatMessage.mediaChatMessage!.currentPos),
                              isLocal: true);*/
                          // if (result == 1) {
                            isPlaying(true);
                          // } else {
                          //   mirrorFlyLog(Constants.emptyString, "Error while playing audio.");
                          // }
                        } else {
                          await player.pause();
                          // if (result == 1) {
                            isPlaying(false);
                          // } else {
                          //   mirrorFlyLog(Constants.emptyString, "Error on pause audio.");
                          // }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: isPlaying.value
                            ? SvgPicture.asset(
                          pauseIcon,package: package,
                          height: 17,
                          colorFilter: ColorFilter.mode(chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn),
                        ) //const Icon(Icons.pause)
                            : SvgPicture.asset(
                          playIcon,package: package,
                          height: 17,
                          colorFilter: ColorFilter.mode(chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn),
                        ),
                      ),
                    );
                  }),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          child: SliderTheme(
                            data: SliderThemeData(
                              thumbColor: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor,
                              trackHeight: 2,
                              overlayShape: SliderComponentShape.noOverlay,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                            ),
                            child: Obx(() {
                              return Slider(
                                value: (!(currentPos.value >= 0.0 &&
                                    currentPos.value <= maxPos))
                                    ? maxPos
                                    : currentPos.value,
                                /*double.parse(chatMessage
                                .mediaChatMessage!.currentPos
                                .toString()),*/
                                min: 0.0,
                                activeColor: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor,
                                thumbColor: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor,
                                inactiveColor: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor.withAlpha(60) : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor.withAlpha(60),
                                max: double.parse(chatMessage
                                    .mediaChatMessage!.mediaDuration
                                    .toString()),
                                divisions:
                                chatMessage.mediaChatMessage!.mediaDuration,
                                onChanged: (double value) {
                                  // debugPrint('onChanged $value');
                                  player.seek(
                                      Duration(milliseconds: value.toInt()));
                                  // currentPos(value);
                                  /*setState(() {
                              currentPos = value;
                            });*/
                                  //widget.onSeekbarChange(value);
                                },
                              );
                            }),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() {
                              return Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  Helper.durationToString(Duration(
                                      milliseconds: currentPos.value == 0.0
                                          ? chatMessage.mediaChatMessage!
                                          .mediaDuration
                                          : currentPos.value.toInt())),
                                  style: TextStyle(
                                      color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w300),
                                ),
                              );
                            }),
                            /*Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            Helper.durationToString(Duration(
                                milliseconds: chatMessage
                                    .mediaChatMessage!.mediaDuration)),
                            style: const TextStyle(
                                color: durationTextColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w400),
                          ),
                        ),*/
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    },
    );
  }
}

class ContactMessageView extends StatelessWidget {
  const ContactMessageView({Key? key,
    required this.chatMessage,
    this.search = Constants.emptyString,
    required this.isSelected, required this.showChatDeliveryIndicator})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;
  final bool showChatDeliveryIndicator;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    debugPrint("Is Starred --> ${chatMessage.isMessageStarred.value}");
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: chatMessage.isMessageSentByMe
            ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor.withAlpha(30)
            : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor.withAlpha(30),
      ),
      width: screenWidth * 0.70,
      child: Column(
        children: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (con) => PreviewContactView(contactName : chatMessage.contactChatMessage!.contactName, from: "chat", previewContactList: chatMessage.contactChatMessage?.contactPhoneNumbers,)));
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: Row(
                    children: [
                      Image.asset(
                        profileImage,package: package,
                        width: 35,
                        height: 35,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                          child: search.isEmpty
                              ? textMessageSpannableText(
                              chatMessage.contactChatMessage!.contactName
                                  .checkNull(),chatMessage.isMessageSentByMe,
                              maxLines: 2, isClickable: false)
                              : chatSpannedText(
                              chatMessage.contactChatMessage!.contactName,
                              search,
                              TextStyle(fontSize: 14, color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor),
                              chatMessage.isMessageSentByMe,
                              maxLines:
                              2) /*,Text(
                        chatMessage.contactChatMessage!.contactName,
                        maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                      )*/
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                chatMessage.isMessageStarred.value
                          ? SvgPicture.asset(starSmallIcon, package: package,)
                          : const SizedBox.shrink(),
                      const SizedBox(
                        width: 5,
                      ),
                      Obx(() {
                        return getMessageIndicator(chatMessage.messageStatus.value,
                            chatMessage.isMessageSentByMe, chatMessage.messageType,
                      chatMessage.isMessageRecalled.value,showChatDeliveryIndicator:showChatDeliveryIndicator);
                      }),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        getChatTime(context, chatMessage.messageSentTime.toInt()),
                        style: TextStyle(
                            fontSize: 11,
                            color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          const AppDivider(),
          getJidOfContact(contactChatMessage: chatMessage.contactChatMessage, showChatDeliveryIndicator: showChatDeliveryIndicator),
        ],
      ),
    );
  }

  Future<String?> getUserJid(ContactChatMessage contactChatMessage) async {
    for (int i = 0; i < contactChatMessage.contactPhoneNumbers.length; i++) {
      debugPrint(
          "contactChatMessage.isChatAppUser[i]--> ${contactChatMessage
              .isChatAppUser[i]}");
      if (contactChatMessage.isChatAppUser[i]) {
        return await Mirrorfly.getJidFromPhoneNumber(
            contactChatMessage.contactPhoneNumbers[i],
            (SessionManagement.getCountryCode() ?? Constants.emptyString).replaceAll('+', Constants.emptyString));
      }
    }
    return Constants.emptyString;
  }

  Widget getJidOfContact({ContactChatMessage? contactChatMessage,
      required bool showChatDeliveryIndicator}) {
    // String? userJid;
    if (contactChatMessage == null ||
        contactChatMessage.contactPhoneNumbers.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder(
        future: getUserJid(contactChatMessage),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }
          var userJid = snapshot.data;
          debugPrint("getJidOfContact--> $userJid");
          return InkWell(
            onTap: () {
              (userJid != null && userJid.isNotEmpty)
                  ? sendToChatPage(context,userJid,showChatDeliveryIndicator)
                  : showInvitePopup(contactChatMessage, context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (userJid != null && userJid.isNotEmpty)
                              ? Text(AppConstants.message,style: TextStyle(color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor),)
                              : Text(AppConstants.invite,style: TextStyle(color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor),)
                        ))),
              ],
            ),
          );
        });
  }

  sendToChatPage(BuildContext context,String userJid, bool showChatDeliveryIndicator) {
    try {
      Navigator.push(context, MaterialPageRoute(
          builder: (con) => ChatView(jid: userJid,isUser: true, showChatDeliveryIndicator: showChatDeliveryIndicator,)));
    }catch(e){
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(
          builder: (con) => ChatView(jid: userJid,isUser: true, showChatDeliveryIndicator: showChatDeliveryIndicator,)));
    }
  }

  showInvitePopup(ContactChatMessage contactChatMessage, BuildContext context) {
    Helper.showButtonAlert(actions: [
      ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        title: Text(AppConstants.inviteFriend,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        title: Text(AppConstants.copyLink,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        onTap: () {
          Clipboard.setData(
              const ClipboardData(text: Constants.applicationLink));
          // Get.back();
          Navigator.pop(context);
          toToast(AppConstants.linkCopied);
        },
      ),
      ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        title: Text(AppConstants.sendSMS,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        onTap: () {
          Get.back();
          sendSMS(contactChatMessage.contactPhoneNumbers[0]);
        },
      ),
    ], context: context);
  }

  void sendSMS(String contactPhoneNumber) async {
    var info = await PackageInfo.fromPlatform();
    Uri sms = Uri.parse('sms:$contactPhoneNumber?body=${Constants.smsContent.replaceAll('MirrorFly', info.appName)}');
    if (await launchUrl(sms)) {
      //app opened
    } else {
      //app is not opened
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

class DocumentMessageView extends StatelessWidget {
  const DocumentMessageView(
      {Key? key, required this.chatMessage, this.search = Constants.emptyString, required this.showChatDeliveryIndicator})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool showChatDeliveryIndicator;

  onDocumentClick() {
    openDocument(
        chatMessage.mediaChatMessage!.mediaLocalStoragePath);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return InkWell(
      onTap: () {
        onDocumentClick();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: chatMessage.isMessageSentByMe
                ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor.withAlpha(30)
                : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor.withAlpha(30),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.transparent,
        ),
        width: screenWidth * 0.70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: chatMessage.isMessageSentByMe
                    ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor.withAlpha(30)
                    : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor.withAlpha(30),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  getImageHolder(
                      chatMessage.mediaChatMessage!.mediaFileName, 30),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: search.isEmpty
                        ? Text(chatMessage.mediaChatMessage!.mediaFileName,
                      style: TextStyle(
                        fontSize: 12,color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor), maxLines: 2,) /*textMessageSpannableText(
                            chatMessage.mediaChatMessage!.mediaFileName
                                .checkNull(),
                            maxLines: 2,
                          )*/
                        : chatSpannedText(
                        chatMessage.mediaChatMessage!.mediaFileName
                            .checkNull(),
                        search,
                        TextStyle(
                            color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor,
                            fontWeight: FontWeight.w400),chatMessage.isMessageSentByMe,
                        maxLines:
                        2), /*Text(
                    chatMessage.mediaChatMessage!.mediaFileName,
                    maxLines: 2,
                        style: const TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w400),
                  )*/
                  ),
                  getImageOverlay(context,chatMessage),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    Helper.formatBytes(
                        chatMessage.mediaChatMessage?.mediaFileSize ?? 0, 0),
                    style: TextStyle(
                        color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor,
                        fontSize: 7,
                        fontWeight: FontWeight.w400),
                  ),
                  const Spacer(),
                  chatMessage.isMessageStarred.value
                      ? SvgPicture.asset(starSmallIcon,package: package, colorFilter: ColorFilter.mode(chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn))
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  Obx(() {
                    return getMessageIndicator(chatMessage.messageStatus.value,
                        chatMessage.isMessageSentByMe, chatMessage.messageType,
                        chatMessage.isMessageRecalled.value,showChatDeliveryIndicator:showChatDeliveryIndicator);
                  }),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getChatTime(context, chatMessage.messageSentTime.toInt()),
                    style: TextStyle(
                        fontSize: 12,
                        color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}

Widget getImageHolder(String mediaFileName, double size) {
  debugPrint("mediaFileName--> $mediaFileName");
  return SvgPicture.asset(getDocAsset(mediaFileName),package: package,
      width: size, height: size);
}

class VideoMessageView extends StatelessWidget {
  const VideoMessageView({Key? key,
    required this.chatMessage,
    this.search = Constants.emptyString,
    required this.isSelected, required this.showChatDeliveryIndicator})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;
  final bool showChatDeliveryIndicator;

  onVideoClick(BuildContext context) {
    switch (chatMessage.isMessageSentByMe
        ? chatMessage.mediaChatMessage?.mediaUploadStatus
        : chatMessage.mediaChatMessage?.mediaDownloadStatus) {
      case Constants.mediaDownloaded:
      case Constants.mediaUploaded:
        if (chatMessage.messageType.toUpperCase() == Constants.mVideo) {
          if (checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatMessage.mediaChatMessage!.mediaDownloadStatus ==
                  Constants.mediaDownloaded ||
                  chatMessage.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaUploaded ||
                  chatMessage.isMessageSentByMe)) {
            Navigator.push(context, MaterialPageRoute(builder: (con)=>VideoPlayerView(videoPath: chatMessage.mediaChatMessage!.mediaLocalStoragePath,)));
            // OpenFile.open(chatMessage.mediaChatMessage!.mediaLocalStoragePath);
           /* Get.toNamed(Routes.videoPlay, arguments: {
              "filePath": chatMessage.mediaChatMessage!.mediaLocalStoragePath,
            });*/
          } else {
            debugPrint("file is video but condition failed");
          }
        } else {
          debugPrint("File is not video");
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaMessage = chatMessage.mediaChatMessage!;
    // var screenHeight = MediaQuery.of(context).size.height;
    // var screenWidth = MediaQuery
    //     .of(context)
    //     .size
    //     .width;
    return Container(
      width: Get.width * 0.60,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: isSelected
                    ? null
                    : () {
                  onVideoClick(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imageFromBase64String(
                      mediaMessage.mediaThumbImage, context, null, null),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      mVideoIcon,
                      package: package,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      Helper.durationToString(
                          Duration(milliseconds: mediaMessage.mediaDuration)),
                      style: TextStyle(fontSize: 11, color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor),
                    ),
                  ],
                ),
              ),
              getImageOverlay(context,chatMessage,
                  onVideo: isSelected ? null : ()=>onVideoClick(context)),
              mediaMessage.mediaCaptionText
                  .checkNull()
                  .isEmpty
                  ? Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chatMessage.isMessageStarred.value
                        ? SvgPicture.asset(starSmallIcon,package: package, colorFilter: ColorFilter.mode(chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn))
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 5,
                    ),
                    Obx(() {
                      return getMessageIndicator(
                          chatMessage.messageStatus.value,
                          chatMessage.isMessageSentByMe,
                          chatMessage.messageType,
                          chatMessage.isMessageRecalled.value,showChatDeliveryIndicator:showChatDeliveryIndicator);
                    }),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      getChatTime(
                          context, chatMessage.messageSentTime.toInt()),
                      style: TextStyle(
                          fontSize: 11,
                          color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor),
                    ),
                  ],
                ),
              )
                  : const SizedBox(),
            ],
          ),
          mediaMessage.mediaCaptionText
              .checkNull()
              .isNotEmpty
              ? setCaptionMessage(mediaMessage, chatMessage, context,
              search: search,showChatDeliveryIndicator)
              : const SizedBox()
        ],
      ),
    );
  }
}

class ImageMessageView extends StatelessWidget {
  const ImageMessageView({Key? key,
    required this.chatMessage,
    this.search = Constants.emptyString,
    required this.isSelected, required this.showChatDeliveryIndicator})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;
  final bool showChatDeliveryIndicator;

  @override
  Widget build(BuildContext context) {
    var mediaMessage = chatMessage.mediaChatMessage!;
    // var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
      width: screenWidth * 0.60,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: getImage(
                    mediaMessage.mediaLocalStoragePath,
                    mediaMessage.mediaThumbImage,
                    context,
                    mediaMessage.mediaFileName,
                    isSelected),
              ),
              getImageOverlay(context,chatMessage),
              mediaMessage.mediaCaptionText
                  .checkNull()
                  .isEmpty
                  ? Positioned(
                bottom: 8,
                right: 10,
                child: Stack(
                  children: [
                    // SvgPicture.asset(mediaBg,package: package,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        chatMessage.isMessageStarred.value
                            ? SvgPicture.asset(starSmallIcon,package: package,colorFilter: ColorFilter.mode(chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn))
                            : const SizedBox.shrink(),
                        const SizedBox(
                          width: 5,
                        ),
                        Obx(() {
                          return getMessageIndicator(
                              chatMessage.messageStatus.value,
                              chatMessage.isMessageSentByMe,
                              chatMessage.messageType,
                              chatMessage.isMessageRecalled.value,showChatDeliveryIndicator:showChatDeliveryIndicator);
                        }),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          getChatTime(context,
                              chatMessage.messageSentTime.toInt()),
                          style: TextStyle(
                              fontSize: 11,
                              color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  : const SizedBox(),
            ],
          ),
          mediaMessage.mediaCaptionText
              .checkNull()
              .isNotEmpty
              ? setCaptionMessage(mediaMessage, chatMessage, context,
              search: search,showChatDeliveryIndicator)
              : const SizedBox(),
        ],
      ),
    );
  }

  getImage(String mediaLocalStoragePath, String mediaThumbImage,
      BuildContext context, String mediaFileName, bool isSelected) {
    var screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    var screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    if (checkFile(mediaLocalStoragePath)) {
      return InkWell(
          onTap: isSelected
              ? null
              : () {
            Navigator.push(context, MaterialPageRoute(builder: (con)=>ImageViewView(imageName: mediaFileName,imagePath: mediaLocalStoragePath,)));
            /*Get.toNamed(Routes.imageView, arguments: {
              'imageName': mediaFileName,
              'imagePath': mediaLocalStoragePath
            });*/
          },
          child: Image(
            image: FileImage(File(mediaLocalStoragePath)),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                // return FutureBuilder(builder: (context, d) {
                  return child;
                // });
              }
              return Center(child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.primaryColor,));
            },
            width: screenWidth * 0.60,
            height: screenHeight * 0.4,
            fit: BoxFit.cover,
          ) /*Image.file(
            File(mediaLocalStoragePath),
            width: controller.screenWidth * 0.60,
            height: controller.screenHeight * 0.4,
            fit: BoxFit.cover,
          )*/
      );
    } else {
      return imageFromBase64String(mediaThumbImage, context, null, null);
    }
  }
}

Widget setCaptionMessage(MediaChatMessage mediaMessage,
    ChatMessageModel chatMessage, BuildContext context,bool showChatDeliveryIndicator,
    {String search = Constants.emptyString}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.isEmpty
            ? textMessageSpannableText(
            mediaMessage.mediaCaptionText.checkNull(),chatMessage.isMessageSentByMe)
            : chatSpannedText(
          mediaMessage.mediaCaptionText.checkNull(),
          search,
          TextStyle(fontSize: 14, color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor),chatMessage.isMessageSentByMe,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            chatMessage.isMessageStarred.value
                ? SvgPicture.asset(starSmallIcon,package: package,colorFilter: ColorFilter.mode(chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn))
                : const SizedBox.shrink(),
            const SizedBox(
              width: 5,
            ),
            Obx(() {
              return getMessageIndicator(chatMessage.messageStatus.value,
                  chatMessage.isMessageSentByMe, chatMessage.messageType,
                  chatMessage.isMessageRecalled.value,showChatDeliveryIndicator:showChatDeliveryIndicator);
            }),
            const SizedBox(
              width: 5,
            ),
            Text(
              getChatTime(context, chatMessage.messageSentTime.toInt()),
              style: TextStyle(
                  fontSize: 12,
                  color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor),
            ),
          ],
        ),
      ],
    ),
  );
}

class NotificationMessageView extends StatelessWidget {
  const NotificationMessageView({Key? key, required this.chatMessage})
      : super(key: key);
  final String? chatMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        decoration: BoxDecoration(
            color: MirrorflyUikit.getTheme?.secondaryColor.withOpacity(0.5),
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        child: Text(chatMessage ?? Constants.emptyString,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: MirrorflyUikit.getTheme?.textPrimaryColor)),
      ),
    );
  }
}

class ChatContainer extends StatelessWidget {
  const ChatContainer({Key? key, required this.chatMessage, required this.child}) : super(key: key);
  final ChatMessageModel chatMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
      BoxConstraints(maxWidth: Get.width * 0.80),
      decoration: BoxDecoration(
          borderRadius: chatMessage.isMessageSentByMe
              ? const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10))
              : const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          color:
          (chatMessage.isMessageSentByMe
              ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.color//chatSentBgColor
              : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.color),
          border: chatMessage
              .isMessageSentByMe
              ? Border.all(color: MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor.withOpacity(0.2))//chatSentBgColor)
              : Border.all(
              color:  MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor.withOpacity(0.2))),
      child: child,
    );
  }
}


class MessageContent extends StatelessWidget {
  const MessageContent({Key? key,
    required this.chatList,
    required this.index,
    this.search = Constants.emptyString,
    this.isSelected = false,
    required this.onPlayAudio,
    required this.onSeekbarChange, this.showChatDeliveryIndicator = true})
      : super(key: key);
  final List<ChatMessageModel> chatList;
  final int index;
  final Function() onPlayAudio;
  final Function(double) onSeekbarChange;
  final String search;
  final bool isSelected;
  final bool showChatDeliveryIndicator;

  @override
  Widget build(BuildContext context) {
    var chatMessage = chatList[index];
    //mirrorFlyLog("message==>", json.encode(chatMessage));
    // debugPrint("Message Type===> ${chatMessage.messageType}");
    if (chatList[index].isMessageRecalled.value) {
      return RecalledMessageView(
        chatMessage: chatMessage,
      );
    } else {
      if (chatList[index].messageType.toUpperCase() == Constants.mText) {
        return TextMessageView(
          chatMessage: chatMessage,
          search: search,
          showChatDeliveryIndicator: showChatDeliveryIndicator,
        );
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mNotification) {
        return NotificationMessageView(
            chatMessage: chatMessage.messageTextContent);
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mLocation) {
        if (chatList[index].locationChatMessage == null) {
          return const SizedBox.shrink();
        }
        return LocationMessageView(
          chatMessage: chatMessage,
          isSelected: isSelected,
          showChatDeliveryIndicator: showChatDeliveryIndicator,
        );
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mContact) {
        if (chatList[index].contactChatMessage == null) {
          return const SizedBox.shrink();
        }
        return ContactMessageView(
          chatMessage: chatMessage,
          search: search,
          isSelected: isSelected,
          showChatDeliveryIndicator: showChatDeliveryIndicator,
        );
      } else {
        if (chatList[index].mediaChatMessage == null) {
          return const SizedBox.shrink();
        } else {
          if (chatList[index].messageType.toUpperCase() == Constants.mImage) {
            return ImageMessageView(
                chatMessage: chatMessage,
                search: search,
                isSelected: isSelected, showChatDeliveryIndicator: showChatDeliveryIndicator);
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mVideo) {
            return VideoMessageView(
                chatMessage: chatMessage,
                search: search,
                isSelected: isSelected, showChatDeliveryIndicator : showChatDeliveryIndicator);
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mDocument ||
              chatList[index].messageType.toUpperCase() == Constants.mFile) {
            return DocumentMessageView(
              chatMessage: chatMessage,
              search: search, showChatDeliveryIndicator : showChatDeliveryIndicator
            );
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mAudio) {
            return AudioMessageView(
              chatMessage: chatMessage,
              onPlayAudio: onPlayAudio,
              onSeekbarChange: onSeekbarChange, showChatDeliveryIndicator: showChatDeliveryIndicator
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      }
    }
  }
}

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    Key? key,
    required this.chatMessage,
    this.search = Constants.emptyString,
    required this.showChatDeliveryIndicator,
  }) : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool showChatDeliveryIndicator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: chatMessage.replyParentChatMessage == null
            ? MainAxisSize.min
            : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: search.isEmpty
                ? textMessageSpannableText(chatMessage.messageTextContent ?? Constants.emptyString,chatMessage.isMessageSentByMe)
                : chatSpannedText(
              chatMessage.messageTextContent ?? Constants.emptyString,
              search,
              TextStyle(fontSize: 14, color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor),
                chatMessage.isMessageSentByMe
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                chatMessage.isMessageStarred.value
                    ? SvgPicture.asset(starSmallIcon,package: package,)
                    : const SizedBox.shrink(),
                const SizedBox(
                  width: 5,
                ),
                Obx(() {
                  return getMessageIndicator(chatMessage.messageStatus.value,
                      chatMessage.isMessageSentByMe, chatMessage.messageType,
                      chatMessage.isMessageRecalled.value,showChatDeliveryIndicator: showChatDeliveryIndicator);
                }),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  getChatTime(context, chatMessage.messageSentTime.toInt()),
                  style: TextStyle(
                      fontSize: 12,
                      color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textSecondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecalledMessageView extends StatelessWidget {
  const RecalledMessageView({Key? key, required this.chatMessage})
      : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: chatMessage.replyParentChatMessage == null
            ? MainAxisSize.min
            : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset(
                  disabledIcon,package: package,
                  width: 15,
                  height: 15,
                color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    chatMessage.isMessageSentByMe
                        ? AppConstants.youDeletedThisMessage
                        : AppConstants.thisMessageWasDeleted,
                    maxLines: 1,
                    style: TextStyle(fontSize: 14,color: chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme?.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme?.chatBubbleSecondaryColor.textPrimaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              getChatTime(context, chatMessage.messageSentTime.toInt()),
              style: TextStyle(
                  fontSize: 12,
                  color: chatMessage.isMessageSentByMe
                      ? durationTextColor
                      : textHintColor),
            ),
          ),
        ],
      ),
    );
  }
}

getMessageIndicator(String? messageStatus, bool isSender, String messageType,
    bool isRecalled,{bool showChatDeliveryIndicator =true}) {
  // debugPrint("Message Status ==>");
  // debugPrint("Message Status ==> $messageStatus");
  if(messageType.toUpperCase() != Constants.mNotification && showChatDeliveryIndicator) {
    if (isSender && !isRecalled) {
      if (messageStatus == 'A') {
        return SvgPicture.asset(acknowledgedIcon, package: package,);
      } else if (messageStatus == 'D') {
        return SvgPicture.asset(deliveredIcon, package: package);
      } else if (messageStatus == 'S') {
        return SvgPicture.asset(seenIcon, package: package);
      } else if (messageStatus == 'N') {
        return SvgPicture.asset(unSendIcon, package: package);
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }else{
    return const SizedBox.shrink();
  }
}

Widget getImageOverlay(BuildContext context,ChatMessageModel chatMessage,
    {Function()? onAudio, Function()? onVideo}) {
  // debugPrint(
  //     "getImageOverlay checkFile ${checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath)}");
  // debugPrint("getImageOverlay messageStatus ${chatMessage.messageStatus}");
  // debugPrint(
  //     "getImageOverlay ${(checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath) && chatMessage.messageStatus != 'N')}");
  if (checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath) &&
      chatMessage.messageStatus.value != 'N') {
    if (chatMessage.messageType.toUpperCase() == Constants.mVideo) {
      return FloatingActionButton.small(
        onPressed: onVideo,
        backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
        child:  Icon(
          Icons.play_arrow_rounded,
          color: MirrorflyUikit.getTheme?.colorOnPrimary,
        ),
      );
    } else if (chatMessage.messageType.toUpperCase() == Constants.mAudio) {
      return InkWell(
        onTap: onAudio,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: chatMessage.mediaChatMessage!.isPlaying
              ? SvgPicture.asset(
            pauseIcon,package: package,
            colorFilter: ColorFilter.mode(chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn),
            height: 17,
          ) //const Icon(Icons.pause)
              : SvgPicture.asset(
            playIcon,package: package,
            colorFilter: ColorFilter.mode(chatMessage.isMessageSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn),
            height: 17,
          ),
        ),
      ); //const Icon(Icons.play_arrow_sharp);
    } else {
      return const SizedBox.shrink();
    }
  } else {
    // debugPrint(
    //     "overlay status-->${chatMessage.isMessageSentByMe ? chatMessage.mediaChatMessage!.mediaUploadStatus : chatMessage.mediaChatMessage!.mediaDownloadStatus}");
    switch (chatMessage.isMessageSentByMe
        ? chatMessage.mediaChatMessage!.mediaUploadStatus
        : chatMessage.mediaChatMessage!.mediaDownloadStatus) {
      case Constants.mediaDownloaded:
      case Constants.mediaUploaded:
      case Constants.mediaDownloadedNotAvailable:
      case Constants.mediaUploadedNotAvailable:
        return const SizedBox.shrink();
      case Constants.mediaNotDownloaded:
        return InkWell(
          child: downloadView(
              chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize,
              chatMessage.messageType.toUpperCase(),chatMessage.isMessageSentByMe),
          onTap: () {
            downloadMedia(context,chatMessage.messageId);
          },
        );
      case Constants.mediaNotUploaded:
        return InkWell(
            onTap: () {
              uploadMedia(chatMessage.messageId);
            },
            child: uploadView(
                chatMessage.mediaChatMessage!.mediaDownloadStatus,
                chatMessage.mediaChatMessage!.mediaFileSize,
                chatMessage.messageType.toUpperCase(),chatMessage.isMessageSentByMe));

      case Constants.mediaDownloading:
      case Constants.mediaUploading:
        return InkWell(
            onTap: () {
              cancelMediaUploadOrDownload(chatMessage.messageId);
            },
            child: Obx(() {
              return downloadingOrUploadingView(chatMessage.messageType,
                  chatMessage.mediaChatMessage!.mediaProgressStatus.value,chatMessage.isMessageSentByMe);
            }));
      default:
        return const SizedBox.shrink();
    }
  }
}

uploadView(int mediaDownloadStatus, int mediaFileSize, String messageType,bool isSentByMe) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: messageType == Constants.mAudio || messageType == Constants.mDocument
        ? Container(
        decoration: BoxDecoration(
            border: Border.all(color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor),
            borderRadius: BorderRadius.circular(3)),
        padding: const EdgeInsets.all(5),
        child: SvgPicture.asset(
          uploadIcon,package: package,
          colorFilter: ColorFilter.mode(isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn), //playIconColor,
        ))
        : Container(
        width: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor,//textColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.color.withOpacity(0.2) : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.color.withOpacity(0.2),//Colors.black45,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(uploadIcon,package: package, colorFilter: ColorFilter.mode(isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textPrimaryColor, BlendMode.srcIn)),
            const SizedBox(
              width: 5,
            ),
            Text(
              AppConstants.retry.toUpperCase(),
              style: TextStyle(color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textPrimaryColor, fontSize: 10),
            ),
          ],
        )),
  );
}

void cancelMediaUploadOrDownload(String messageId) {
  Mirrorfly.cancelMediaUploadOrDownload(messageId);
}

void uploadMedia(String messageId) async {
  if (await AppUtils.isNetConnected()) {
    Mirrorfly.uploadMedia(messageId);
  } else {
    toToast(AppConstants.noInternetConnection);
  }
}

void downloadMedia(BuildContext context,String messageId) async {
  debugPrint("media download click");
  debugPrint("media download click--> $messageId");
  if (await AppUtils.isNetConnected()) {
    if(context.mounted) {
      AppPermission.getStoragePermission(context).then((value) {
        if (value) {
          // if (await askStoragePermission(context)) {
          debugPrint("media permission granted");
          Mirrorfly.downloadMedia(messageId);
        } else {
          debugPrint("storage permission not granted");
        }
      });
    }
  } else {
    toToast(AppConstants.noInternetConnection);
  }
}


Widget downloadView(int mediaDownloadStatus, int mediaFileSize,
    String messageType,bool isSentByMe) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: messageType == Constants.mAudio || messageType == Constants.mDocument
        ? Container(
        decoration: BoxDecoration(
            border: Border.all(color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor,),
            borderRadius: BorderRadius.circular(3)),
        padding: const EdgeInsets.all(5),
        child: SvgPicture.asset(
          downloadIcon,package: package,
          colorFilter: ColorFilter.mode(isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor, BlendMode.srcIn), //playIconColor,
        ))
        : Container(
        width: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor,//textColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.color.withOpacity(0.2) : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.color.withOpacity(0.2) ,//Colors.black38,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(downloadIcon,package: package,
              colorFilter: ColorFilter.mode(isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textPrimaryColor, BlendMode.srcIn),//playIconColor,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              Helper.formatBytes(mediaFileSize, 0),
              style: TextStyle(color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textPrimaryColor, fontSize: 10),
            ),
          ],
        )),
  );
}

downloadingOrUploadingView(String messageType, int progress,bool isSentByMe) {
  debugPrint('downloadingOrUploadingView progress $progress');
  if (messageType == Constants.mAudio || messageType == Constants.mDocument) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textPrimaryColor,//borderColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            // color: Colors.black45,
          ),
          child: Stack(
              alignment: Alignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  downloading,
                  package: package,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textPrimaryColor, BlendMode.srcIn), //playIconColor,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 1,
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textPrimaryColor,
                      ),
                      value: progress == 0 || progress == 100
                          ? null
                          : (progress / 100),
                      backgroundColor: Colors.transparent,
                      // minHeight: 1,
                    ),
                  ),
                ),
              ])),
    );
  } else {
    return Container(
        height: 30,
        width: 70,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textSecondaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textSecondaryColor,//textColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.color.withOpacity(0.2) : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.color.withOpacity(0.2),//Colors.black45,
        ),
        child: Stack(
            alignment: Alignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                downloading,
                package: package,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textPrimaryColor, BlendMode.srcIn),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isSentByMe ? MirrorflyUikit.getTheme!.chatBubblePrimaryColor.textPrimaryColor : MirrorflyUikit.getTheme!.chatBubbleSecondaryColor.textPrimaryColor,
                    ),
                    value: progress == 0 || progress == 100
                        ? null
                        : (progress / 100),
                    backgroundColor: Colors.transparent,
                    // minHeight: 1,
                  ),
                ),
              ),
            ]));
  }
}

class AttachmentsSheetView extends StatelessWidget {
  const AttachmentsSheetView({Key? key,
    required this.onDocument,
    required this.onCamera,
    required this.onGallery,
    required this.onAudio,
    required this.onContact,
    required this.onLocation})
      : super(key: key);
  final Function() onDocument;
  final Function() onCamera;
  final Function() onGallery;
  final Function() onAudio;
  final Function() onContact;
  final Function() onLocation;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MirrorflyUikit.getTheme!.primaryColor,//bottomSheetColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                iconCreation(documentImg, AppConstants.document, onDocument),
                iconCreation(cameraImg, AppConstants.camera, onCamera),
                iconCreation(galleryImg, AppConstants.gallery, onGallery),
              ],
            ),
            const SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                iconCreation(audioImg, AppConstants.audio, onAudio),
                iconCreation(contactImg, AppConstants.contact, onContact),
                iconCreation(locationImg, AppConstants.location, onLocation),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget iconCreation(String iconPath, String text, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        SvgPicture.asset(iconPath,package: package,),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: MirrorflyUikit.getTheme?.colorOnPrimary,fontWeight: FontWeight.bold),
        )
      ],
    ),
  );
}

Widget chatSpannedText(String text, String spannableText, TextStyle? style,bool isSentbyMe,
    {int? maxLines}) {
  var startIndex = text.toLowerCase().contains(spannableText.toLowerCase())
      ? text.toLowerCase().indexOf(spannableText.toLowerCase())
      : -1;
  var endIndex = startIndex + spannableText.length;
  if (startIndex != -1 && endIndex != -1) {
    var startText = text.substring(0, startIndex);
    var colorText = text.substring(startIndex, endIndex);
    var endText = text.substring(endIndex, text.length);
    return Text.rich(
      TextSpan(
          text: startText,
          children: [
            TextSpan(
                text: colorText, style: const TextStyle(color: Colors.orange)),
            TextSpan(text: endText)
          ],
          style: style),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  } else {
    return textMessageSpannableText(text,isSentbyMe,
        maxLines: maxLines); //Text(text, style: style);
  }
}


class AudioMessagePlayerController extends GetxController {
  final _obj = Constants.emptyString.obs;

  set obj(value) => _obj.value = value;

  get obj => _obj.value;
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var currentPlayingPosId = "0".obs;
  String currentPostLabel = "00:00";
  var audioPlayed = false.obs;
  AudioPlayer player = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    player.onPlayerComplete.listen((event) {
      playingChat!.mediaChatMessage!.isPlaying = false;
      playingChat!.mediaChatMessage!.currentPos = 0;
      player.stop();
      //chatList.refresh();
    });

    player.onDurationChanged.listen((Duration p) {
      playingChat?.mediaChatMessage!.currentPos = (p.inMilliseconds);
      //chatList.refresh();
    });
  }

  ChatMessageModel? playingChat;

  playAudio(ChatMessageModel chatMessage, String filePath) async {
    if (playingChat != null) {
      if (playingChat?.mediaChatMessage!.messageId != chatMessage.messageId) {
        player.stop();
        playingChat?.mediaChatMessage!.isPlaying = false;
        playingChat = chatMessage;
      }
    } else {
      playingChat = chatMessage;
    }
    if (!playingChat!.mediaChatMessage!.isPlaying) {
      await player.play(
          UrlSource(playingChat!.mediaChatMessage!.mediaLocalStoragePath),
          position:
          Duration(milliseconds: playingChat!.mediaChatMessage!.currentPos));
      // if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = true;
      // } else {
      //   mirrorFlyLog(Constants.emptyString, "Error while playing audio.");
      // }
    } else if (!playingChat!.mediaChatMessage!.isPlaying) {
      await player.resume();
      // if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = true;
      // } else {
      //   mirrorFlyLog(Constants.emptyString, "Error on resume audio.");
      // }
    } else {
      await player.pause();
      // if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = false;
      // } else {
      //   mirrorFlyLog(Constants.emptyString, "Error on pause audio.");
      // }
    }
  }
}

/// Checks the current header id with previous header id
/// @param position Position of the current item
/// @return boolean True if header changed, else false
bool isDateChanged(int position, List<ChatMessageModel> mChatData) {
  // try {
  var prePosition = position + 1;
  var size = mChatData.length - 1;
  if (position == size) {
    return true;
  } else {
    if (prePosition <= size && position <= size) {
      // debugPrint("position $position $size");
      // debugPrint("sentTime ${mChatData[position].messageSentTime}");
      // debugPrint("pre sentTime ${mChatData[prePosition].messageSentTime}");
      var currentHeaderId = mChatData[position].messageSentTime.toInt();
      var previousHeaderId = mChatData[prePosition].messageSentTime.toInt();
      return currentHeaderId != previousHeaderId;
    }
  }
  // }catch(e){
  //   return false;
  // }
  return false; //currentHeaderId != previousHeaderId;
}

String? groupedDateMessage(int index, List<ChatMessageModel> chatList) {
  if (index == chatList.length - 1) {
    return addDateHeaderMessage(chatList.last);
  } else {
    return (isDateChanged(index, chatList) &&
        (addDateHeaderMessage(chatList[index + 1]) !=
            addDateHeaderMessage(chatList[index])))
        ? addDateHeaderMessage(chatList[index])
        : null;
  }
}

String addDateHeaderMessage(ChatMessageModel item) {
  var calendar = DateTime.now();
  var messageDate = getDateFromTimestamp(item.messageSentTime, "MMMM dd, yyyy");
  var monthNumber = calendar.month - 1;
  var month = getMonthForInt(monthNumber);
  var yesterdayDate = DateTime
      .now()
      .subtract(const Duration(days: 1))
      .day;
  var today = "$month ${checkTwoDigitsForDate(calendar.day)}, ${calendar.year}";
  var yesterday =
      "$month ${checkTwoDigitsForDate(yesterdayDate)}, ${calendar.year}";
  // var dateHeaderMessage = ChatMessage()
  // debugPrint("messageDate $messageDate");
  // debugPrint("today $today");
  // debugPrint("yesterday $yesterday");
  if (messageDate.toString() == (today).toString()) {
    return AppConstants.today;
    //dateHeaderMessage = createDateHeaderMessageWithDate(date, item)
  } else if (messageDate == yesterday) {
    return AppConstants.yesterday;
    //dateHeaderMessage = createDateHeaderMessageWithDate(date, item)
  } else if (!messageDate.contains("1970")) {
    //dateHeaderMessage = createDateHeaderMessageWithDate(messageDate, item)
    return messageDate;
  }
  return Constants.emptyString;
}

String checkTwoDigitsForDate(int date) {
  if (date
      .toString()
      .length != 2) {
    return "0$date";
  } else {
    return date.toString();
  }
}

String getMonthForInt(int num) {
  var month = Constants.emptyString;
  var dateFormatSymbols = DateFormat().dateSymbols.STANDALONEMONTHS;
  var months = dateFormatSymbols;
  if (num <= 11) {
    month = months[num];
  }
  return month;
}
