import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart' as lib_phone_number;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/model/export_model.dart';
import 'package:mirrorfly_plugin/model/group_members_model.dart';
import 'package:mirrorfly_plugin/model/message_object.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/de_bouncer.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/app/data/permissions.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/camera_pick/views/camera_pick_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/views/chat_search_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/views/location_sent_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chatInfo/views/chat_info_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/group/views/group_info_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/media_preview/views/media_preview_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/message_info/views/message_info_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';

import 'package:mirrorfly_plugin/flychat.dart';
import '../../../models.dart';

import '../../gallery_picker/src/data/models/picked_asset_model.dart';
import '../../gallery_picker/views/gallery_picker_view.dart';
import '../../local_contact/views/local_contact_view.dart';
import '../../notification/notification_builder.dart';
import '../chat_widgets.dart';
import '../views/forwardchat_view.dart';

class ChatController extends FullLifeCycleController
    with FullLifeCycleMixin, GetTickerProviderStateMixin {
  // final translator = Translation(apiKey: Constants.googleTranslateKey);
  late final BuildContext context;
  late final bool showChatDeliveryIndicator;
  var chatList = List<ChatMessageModel>.empty(growable: true).obs;
  late AnimationController controller;

  // ScrollController scrollController = ScrollController();

  ItemScrollController newScrollController = ItemScrollController();
  ItemPositionsListener newitemPositionsListener =
      ItemPositionsListener.create();
  ItemScrollController searchScrollController = ItemScrollController();

  late ChatMessageModel replyChatMessage;

  var isReplying = false.obs;

  var isUserTyping = false.obs;
  var isAudioRecording = Constants.audioRecordInitial.obs;
  late Timer? _audioTimer;
  var timerInit = "00:00".obs;
  DateTime? startTime;

  // double screenHeight = 0.0;
  // double screenWidth = 0.0;

  // AudioPlayer player = AudioPlayer();

  late String audioSavePath;
  late String recordedAudioPath;
  late Record record;

  TextEditingController messageController = TextEditingController();

  FocusNode focusNode = FocusNode();
  FocusNode searchfocusNode = FocusNode();

  var calendar = DateTime.now();
  var profile_ = Profile().obs;

  Profile get profile => profile_.value;
  var base64img = Constants.emptyString.obs;
  var imagePath = Constants.emptyString.obs;
  var filePath = Constants.emptyString.obs;

  var showEmoji = false.obs;

  // var isLive = false;

  var isSelected = false.obs;

  var isBlocked = false.obs;

  var selectedChatList = List<ChatMessageModel>.empty(growable: true).obs;

  // var keyboardVisibilityController = KeyboardVisibilityController();

  // late StreamSubscription<bool> keyboardSubscription;

  final RxBool _isMemberOfGroup = false.obs;

  set isMemberOfGroup(value) => _isMemberOfGroup.value = value;

  bool get isMemberOfGroup =>
      profile.isGroupProfile ?? false ? _isMemberOfGroup.value : true;

  var profileDetail = Profile();

  var isKeyboardVisible = false.obs;

  String? nJid;
  String? starredChatMessageId;

  bool get isTrail => MirrorflyUikit.instance.isTrialLicenceKey;

  final deBouncer = DeBouncer(milliseconds: 1000);

  init(
    BuildContext context, {
    String? jid,
    bool isUser = false,
    bool isFromStarred = false,
    String? messageId, required bool showChatDeliveryIndicator,
  }) async {
    this.context = context;
    this.showChatDeliveryIndicator = showChatDeliveryIndicator;
    var userJid = SessionManagement.getChatJid().checkNull();
    if (jid != null) {
      nJid = jid;
      debugPrint("parameter :$jid");
      if (nJid != null) {
        userJid = jid;
      }
      if (isFromStarred && messageId != null) {
        starredChatMessageId = messageId;
      }
    }

    debugPrint('userJid $userJid');

    getProfileDetails(userJid).then((value) {
      if (value.jid != null) {
        SessionManagement.setChatJid(Constants.emptyString);
        profile_(value);
        ready();
        checkAdminBlocked();
      }
    }).catchError((o) {
      debugPrint('error $o');
    });

    setAudioPath();

    filteredPosition.bindStream(filteredPosition.stream);
    ever(filteredPosition, (callback) {
      lastPosition(callback.length);
      //chatList.refresh();
    });

    chatList.bindStream(chatList.stream);
    ever(chatList, (callback) {});
    isUserTyping.bindStream(isUserTyping.stream);
    ///Commenting this, bcz this executed only when value is changed to true or false. if started typing value changed to true.
    ///Then after some interval, if we type again the value remains true so this is not calling
    ///Changing to below messageController.addListener()
    /*ever(isUserTyping, (callback) {
      mirrorFlyLog("typing ", callback.toString());
      if (callback) {
        sendUserTypingStatus();
        DeBouncer(milliseconds: 2100).run(() {
          sendUserTypingGoneStatus();
        });
      } else {
        sendUserTypingGoneStatus();
      }
    });*/
    messageController.addListener(() {
      mirrorFlyLog("typing", "typing..");
      sendUserTypingStatus();
      debugPrint('User is typing');
      deBouncer.cancel();
      deBouncer.run(() {
        debugPrint("DeBouncer");
        sendUserTypingGoneStatus();
      });
    });
  }

  var showHideRedirectToLatest = false.obs;

  void ready() {
    cancelNotification();
    // debugPrint("isBlocked===> ${profile.isBlocked}");
    // debugPrint("profile detail===> ${profile.toJson().toString()}");
    getUnsentMessageOfAJid();
    isBlocked(profile.isBlocked);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Member(jid: profile.jid.checkNull())
        .getProfileDetails()
        .then((value) => profileDetail = value);
    memberOfGroup();
    setChatStatus();
    // isLive = true;
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });

    itemPositionsListener.itemPositions.addListener(() {
      debugPrint('scrolled : ${findTopFirstVisibleItemPosition()}');
      // j=findLastVisibleItemPosition();
    });
    newitemPositionsListener.itemPositions.addListener(() {
      var pos = findLastVisibleItemPositionForChat();
      if (pos >= 1) {
        showHideRedirectToLatest(true);
      } else {
        showHideRedirectToLatest(false);
        unreadCount(0);
      }
    });

    Mirrorfly.setOnGoingChatUser(profile.jid!);
    SessionManagement.setCurrentChatJID(profile.jid.checkNull());
    getChatHistory();
    // compute(getChatHistory, profile.jid);
    debugPrint("==================");
    debugPrint(profile.image);
    setOnGoingUserAvail();
  }

  scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      /*if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }*/
      if (newScrollController.isAttached) {
        newScrollController.scrollTo(
            index: 0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear);
        unreadCount(0);
      }
    });
  }

  scrollToEnd() {
    /*if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    }*/
    newScrollController.jumpTo(index: 0);
    showHideRedirectToLatest(false);
  }

  @override
  void onClose() {
    // scrollController.dispose();
    debugPrint("onClose");
    saveUnsentMessage();
    setOnGoingUserGone();
    // isLive = false;
    // player.stop();
    // player.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    debugPrint("dispose");
    super.dispose();
  }

  clearMessage() {
    if (profile.jid.checkNull().isNotEmpty) {
      messageController.text = Constants.emptyString;
      Mirrorfly.saveUnsentMessage(profile.jid.checkNull(), Constants.emptyString);
      ReplyHashMap.saveReplyId(profile.jid.checkNull(), Constants.emptyString);
    }
  }

  saveUnsentMessage() {
    if (profile.jid.checkNull().isNotEmpty) {
      Mirrorfly.saveUnsentMessage(
          profile.jid.checkNull(), messageController.text.trim().toString());
    }
    if (isReplying.value) {
      ReplyHashMap.saveReplyId(
          profile.jid.checkNull(), replyChatMessage.messageId);
    }
  }

  getUnsentMessageOfAJid() async {
    if (profile.jid.checkNull().isNotEmpty) {
      Mirrorfly.getUnsentMessageOfAJid(profile.jid.checkNull()).then((value) {
        if (value != null) {
          messageController.text = value;
        } else {
          messageController.text = Constants.emptyString;
        }
        if (value.checkNull().trim().isNotEmpty) {
          isUserTyping(true);
        }
      });
    }
  }

  getUnsentReplyMessage() {
    var replyMessageId = ReplyHashMap.getReplyId(profile.jid.checkNull());
    if (replyMessageId.isNotEmpty) {
      var replyChatMessage =
          chatList.firstWhere((element) => element.messageId == replyMessageId);
      handleReplyChatMessage(replyChatMessage);
    }
  }

  showAttachmentsView(BuildContext context) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      //if (await AppUtils.isNetConnected()) {
      focusNode.unfocus();
      if (context.mounted) showBottomSheetAttachment(context);
      /*} else {
        toToast(AppConstants.noInternetConnection);
      }*/
    } else {
      //show busy status popup
      if (context.mounted) {
        showBusyStatusAlert(showBottomSheetAttachment(context), context);
      }
    }
  }

  showBottomSheetAttachment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.only(right: 18.0, left: 18.0, bottom: 18.0),
          child: BottomSheet(
              onClosing: () {},
              enableDrag: false,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              builder: (builder) => AttachmentsSheetView(onDocument: () {
                    Navigator.pop(context);
                    documentPickUpload(context);
                  }, onCamera: () {
                    Navigator.pop(context);
                    onCameraClick();
                  }, onGallery: () {
                    Navigator.pop(context);
                    onGalleryClick();
                  }, onAudio: () {
                    Navigator.pop(context);
                    onAudioClick(context);
                  }, onContact: () {
                    Navigator.pop(context);
                    onContactClick();
                  }, onLocation: () {
                    Navigator.pop(context);
                    onLocationClick(context);
                  })),
        );
      },
      useSafeArea: true,
    );
  }

  MessageObject? messageObject;

  sendMessage(Profile profile, BuildContext context) async {
    removeUnreadSeparator();
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var replyMessageId = Constants.emptyString;

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      if (messageController.text.trim().isNotEmpty) {
        Mirrorfly.sendTextMessage(
                messageController.text.trim(), profile.jid.toString(), replyMessageId)
            .then((value) {
          mirrorFlyLog("text message", value);
          messageController.text = Constants.emptyString;
          isUserTyping(false);
          clearMessage();
          ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
          mirrorFlyLog(
              "inserting chat message",
              chatMessageModel.replyParentChatMessage?.messageType ??
                  "value is null");
          chatList.insert(0, chatMessageModel);
          scrollToBottom();
        });
      }
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : Constants.emptyString,
          messageType: Constants.mText,
          textMessage: messageController.text.trim());
      if (context.mounted) showBusyStatusAlert(disableBusyChatAndSend, context);
    }
  }

  showBusyStatusAlert(Function? function, BuildContext context) {
    Helper.showAlert(
        message: AppConstants.disableBusy,
        actions: [
          TextButton(
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
              },
              child: Text(
                AppConstants.no,
                style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
              )),
          TextButton(
              onPressed: () async {
                // Get.back();
                Navigator.pop(context);
                await Mirrorfly.enableDisableBusyStatus(false);
                if (function != null) {
                  function();
                }
              },
              child: Text(
                AppConstants.yes,
                style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
              )),
        ],
        context: context);
  }

  disableBusyChatAndSend(BuildContext context) async {
    if (messageObject != null) {
      switch (messageObject!.messageType) {
        case Constants.mText:
          sendMessage(profile, context);
          break;
        case Constants.mImage:
          sendImageMessage(messageObject!.file!, messageObject!.caption!,
              messageObject!.replyMessageId!, context);
          break;
        case Constants.mLocation:
          sendLocationMessage(profile, messageObject!.latitude!,
              messageObject!.longitude!, context);
          break;
        case Constants.mContact:
          sendContactMessage(messageObject!.contactNumbers!,
              messageObject!.contactName!, context);
          break;
        case Constants.mAudio:
          sendAudioMessage(
              messageObject!.file!,
              messageObject!.isAudioRecorded!,
              messageObject!.audioDuration!,
              context);
          break;
        case Constants.mDocument:
          sendDocumentMessage(
              messageObject!.file!, messageObject!.replyMessageId!, context);
          break;
        case Constants.mVideo:
          sendVideoMessage(messageObject!.file!, messageObject!.caption!,
              messageObject!.replyMessageId!, context);
          break;
      }
    }
  }

  sendLocationMessage(Profile profile, double latitude, double longitude,
      BuildContext context) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var replyMessageId = Constants.emptyString;
      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);

      Mirrorfly.sendLocationMessage(
              profile.jid.toString(), latitude, longitude, replyMessageId)
          .then((value) {
        mirrorFlyLog("Location_msg", value.toString());
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.insert(0, chatMessageModel);
        scrollToBottom();
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : Constants.emptyString,
          messageType: Constants.mLocation,
          latitude: latitude,
          longitude: longitude);
      if (context.mounted) showBusyStatusAlert(disableBusyChatAndSend, context);
    }
  }

  String getTime(int? timestamp) {
    DateTime now = DateTime.now();
    final DateTime date1 = timestamp == null
        ? now
        : DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('hh:mm a').format(date1); //yyyy-MM-dd –
    // var fm1 = DateFormat('hh:mm a').parse(formattedDate, true);
    return formattedDate;
  }

  String getChatTime(BuildContext context, int? epochTime) {
    if (epochTime == null) return Constants.emptyString;
    if (epochTime == 0) return Constants.emptyString;
    var convertedTime = epochTime;
    var hourTime = manipulateMessageTime(
        context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    return hourTime;
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
    var hours = calendar.hour; //calendar[Calendar.HOUR]
    calendar = messageDate;
    var dateHourFormat = setDateHourFormat(format, hours);
    return DateFormat(dateHourFormat).format(messageDate);
  }

  String setDateHourFormat(int format, int hours) {
    var dateHourFormat = (format == 12)
        ? (hours < 10)
            ? "hh:mm aa"
            : "h:mm aa"
        : (hours < 10)
            ? "HH:mm"
            : "H:mm";
    return dateHourFormat;
  }

  RxBool chatLoading = false.obs;

  getChatHistory() {
    chatLoading(true);
    Mirrorfly.getMessagesOfJid(profile.jid.checkNull()).then((value) {
      // debugPrint("=====chat=====");
      // debugPrint("history--> $value");

      if (value == Constants.emptyString || value == null) {
        debugPrint("Chat List is Empty");
      } else {
        // debugPrint("parsing the value");
        try {
          // mirrorFlyLog("chat parsed history before", value);
          List<ChatMessageModel> chatMessageModel =
              chatMessageModelFromJson(value);
          // mirrorFlyLog("chat parsed history", chatMessageModelToJson(chatMessageModel));
          chatList(chatMessageModel.reversed.toList());
          Future.delayed(const Duration(milliseconds: 200), () {
            if (starredChatMessageId != null) {
              debugPrint('starredChatMessageId $starredChatMessageId');
              var chat = chatList.indexWhere(
                  (element) => element.messageId == starredChatMessageId);
              debugPrint('chat $chat');
              if (!chat.isNegative) {
                navigateToMessage(chatList[chat]);
                starredChatMessageId = null;
              } else {
                toToast(AppConstants.messageNotFound);
              }
            }
            getUnsentReplyMessage();
          });
          /*for (var index =0;index<=chatMessageModel.reversed.toList().length;index++) {
          debugPrint("isDateChanged ${isDateChanged(index,chatMessageModel.reversed.toList())}");

        }*/
        } catch (error) {
          debugPrint("chatHistory parsing error--> $error");
        }
      }
      chatLoading(false);
    }).catchError((e) {
      chatLoading(false);
    });
  }

  /*getMedia(String mid) {
    return Mirrorfly.getMessageOfId(mid).then((value) {
      CheckModel chatMessageModel = checkModelFromJson(value);
      String thumbImage = chatMessageModel.mediaChatMessage.mediaThumbImage;
      thumbImage = thumbImage.replaceAll("\n", Constants.emptyString);
      return thumbImage;
    });

    // return imageFromBase64String(chatMessageModel.mediaChatMessage!.mediaThumbImage!);
    // // return media;
    // return base64Decode(chatMessageModel.mediaChatMessage.mediaThumbImage);
  }*/

  Image imageFromBase64String(String base64String, BuildContext context,
      double? width, double? height) {
    var decodedBase64 = base64String.replaceAll("\n", Constants.emptyString);
    Uint8List image = const Base64Decoder().convert(decodedBase64);
    return Image.memory(
      image,
      width: width ?? MediaQuery.of(context).size.width * 0.60,
      height: height ?? MediaQuery.of(context).size.height * 0.4,
      fit: BoxFit.cover,
    );
  }

  sendImageMessage(String? path, String? caption, String? replyMessageID,
      BuildContext context) async {
    debugPrint("Path ==> $path");
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (isReplying.value) {
        replyMessageID = replyChatMessage.messageId;
      }
      isReplying(false);
      if (File(path!).existsSync()) {
        return Mirrorfly.sendImageMessage(
                profile.jid!, path, caption, replyMessageID)
            .then((value) {
          clearMessage();
          ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
          chatList.insert(0, chatMessageModel);
          scrollToBottom();
          return chatMessageModel;
        });
      } else {
        debugPrint("file not found for upload");
      }
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : Constants.emptyString,
          messageType: Constants.mImage,
          file: path,
          caption: caption);
      if (context.mounted) showBusyStatusAlert(disableBusyChatAndSend, context);
    }
  }


  documentPickUpload(BuildContext context) {
    AppPermission.getStoragePermission(context).then((permission) {
      if (permission) {
        setOnGoingUserGone();
        FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: ['pdf', 'ppt', 'xls', 'doc', 'docx', 'xlsx', 'txt'],
        ).then((result) {
          if (result != null && File(result.files.single.path!).existsSync()) {
            if (checkFileUploadSize(
                result.files.single.path!, Constants.mDocument)) {
              debugPrint("doc path${result.files.single.path!}");
              filePath.value = (result.files.single.path!);
              // if(context.mounted){
              sendDocumentMessage(filePath.value, Constants.emptyString, context);
              // }else{
              //   debugPrint("context is not mounted");
              // }
            } else {
              toToast(
                  "${AppConstants.fileSizeExceed} ${Constants.maxDocFileSize} MB");
            }
          } else {
            // User canceled the picker
          }
          setOnGoingUserAvail();
        });
      }
    });

  }

  sendReadReceipt() {
    Mirrorfly.markAsReadDeleteUnreadSeparator(profile.jid!).then((value) {
      debugPrint("Chat Read Receipt Response ==> $value");
    });
  }

  sendVideoMessage(String videoPath, String caption, String replyMessageID,
      BuildContext context) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (isReplying.value) {
        replyMessageID = replyChatMessage.messageId;
      }
      isReplying(false);
      if (context.mounted) {
        if (Platform.isIOS) {
          Helper.showLoading(
              message: AppConstants.compressingVideo, buildContext: context);
        }
      }
      return Mirrorfly.sendVideoMessage(
              profile.jid!, videoPath, caption, replyMessageID)
          .then((value) {
        clearMessage();
        if (Platform.isIOS) {
          Helper.hideLoading(context: context);
        }
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.insert(0, chatMessageModel);
        scrollToBottom();
        return chatMessageModel;
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : Constants.emptyString,
          messageType: Constants.mVideo,
          file: videoPath,
          caption: caption);
      if (context.mounted) showBusyStatusAlert(disableBusyChatAndSend, context);
    }
  }

  checkFile(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty &&
        File(mediaLocalStoragePath).existsSync();
  }

  ChatMessageModel? playingChat;

  playAudio(ChatMessageModel chatMessage) async {
    /*setPlayingChat(chatMessage);
    if (!playingChat!.mediaChatMessage!.isPlaying) {
      int result = await player.play(
          playingChat!.mediaChatMessage!.mediaLocalStoragePath,
          position:
              Duration(milliseconds: playingChat!.mediaChatMessage!.currentPos),
          isLocal: true);
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = true;
      } else {
        mirrorFlyLog(Constants.emptyString, "Error while playing audio.");
      }
    } else if (!playingChat!.mediaChatMessage!.isPlaying) {
      int result = await player.resume();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = true;
        chatList.refresh();
      } else {
        mirrorFlyLog(Constants.emptyString, "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = false;
        chatList.refresh();
      } else {
        mirrorFlyLog(Constants.emptyString, "Error on pause audio.");
      }
    }*/
  }

  void setPlayingChat(ChatMessageModel chatMessage) {
    /*if (playingChat != null) {
      if (playingChat?.mediaChatMessage!.messageId != chatMessage.messageId) {
        player.stop();
        playingChat?.mediaChatMessage!.isPlaying = false;
        playingChat = chatMessage;
      }
    } else {
      playingChat = chatMessage;
    }
    if (isAudioRecording.value == Constants.audioRecording) {
      stopRecording();
    }*/
  }

  void onSeekbarChange(double value, ChatMessageModel chatMessage) {
    /*debugPrint('onSeekbarChange $value');
    if (playingChat != null) {
      player.seek(Duration(milliseconds: value.toInt()));
    }else{
      chatMessage.mediaChatMessage?.currentPos=value.toInt();
      //chatList.refresh();
    }*/
  }

  Future<void> playerPause() async {
    /* if (playingChat != null) {
      if (playingChat!.mediaChatMessage!.isPlaying) {
        int result = await player.pause();
        if (result == 1) {
          playingChat!.mediaChatMessage!.isPlaying = false;
          chatList.refresh();
        } else {
          mirrorFlyLog(Constants.emptyString, "Error on pause audio.");
        }
      }
    }*/
  }

  sendContactMessage(List<String> contactList, String contactName,
      BuildContext context) async {
    debugPrint("sendingName--> $contactName");
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    debugPrint("sendContactMessage busyStatus--> $busyStatus");
    if (!busyStatus.checkNull()) {
      debugPrint("busy status not enabled");
      var replyMessageId = Constants.emptyString;

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      return Mirrorfly.sendContactMessage(
              contactList, profile.jid!, contactName, replyMessageId)
          .then((value) {
        debugPrint("response--> $value");
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.insert(0, chatMessageModel);
        scrollToBottom();
        return chatMessageModel;
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : Constants.emptyString,
          messageType: Constants.mContact,
          contactNumbers: contactList,
          contactName: contactName);
      if (context.mounted) showBusyStatusAlert(disableBusyChatAndSend, context);
    }
  }

  sendDocumentMessage(
      String documentPath, String replyMessageId, BuildContext context) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      debugPrint("documentPath $documentPath");
      Mirrorfly.sendDocumentMessage(profile.jid!, documentPath, replyMessageId)
          .then((value) {
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.insert(0, chatMessageModel);
        scrollToBottom();
        return chatMessageModel;
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : Constants.emptyString,
          messageType: Constants.mText,
          file: documentPath);
      if (context.mounted) showBusyStatusAlert(disableBusyChatAndSend, context);
    }
  }

  pickAudio(BuildContext context) async {
    AppPermission.getStoragePermission(context).then((permission) async {
      if (permission) {
        setOnGoingUserGone();
        if (Platform.isIOS) {
          FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              'wav',
              'aiff',
              'alac',
              'flac',
              'mp3',
              'aac',
              'wma',
              'ogg'
            ],
          ).then((result) {
            if (result != null &&
                File(result.files.single.path!).existsSync()) {
              debugPrint(result.files.first.extension);
              if (checkFileUploadSize(
                  result.files.single.path!, Constants.mAudio)) {
                AudioPlayer player = AudioPlayer();

                player.setSourceDeviceFile(
                    result.files.single.path ?? Constants.emptyString);
                player.onDurationChanged.listen((Duration duration) {
                  mirrorFlyLog(Constants.emptyString,
                      'max duration: ${duration.inMilliseconds}');
                  filePath.value = (result.files.single.path!);
                  sendAudioMessage(filePath.value, false,
                      duration.inMilliseconds.toString(), context);
                });
              } else {
                toToast("File Size should not exceed ${Constants
                    .maxAudioFileSize} MB");
              }
            } else {
              // User canceled the picker
            }
            setOnGoingUserAvail();
          });
        }
      }else{
        await Mirrorfly.openAudioFilePicker().then((value) {
          if(value!=null){
            if (checkFileUploadSize(value, Constants.mAudio)) {
              AudioPlayer player = AudioPlayer();
              player.setSourceDeviceFile(value);
              player.onDurationChanged.listen((Duration duration) {
                mirrorFlyLog("", 'max duration: ${duration.inMilliseconds}');
                filePath.value = (value);
                sendAudioMessage(
                    filePath.value, false, duration.inMilliseconds.toString(), context);
              });
            } else {
              toToast("File Size should not exceed ${Constants.maxAudioFileSize} MB");
            }
          }else{
            setOnGoingUserAvail();
          }
        }).catchError((onError){
          LogMessage.d("openAudioFilePicker",onError);
          setOnGoingUserAvail();
        });
      }
    });
  }

  sendAudioMessage(String filePath, bool isRecorded, String duration,
      BuildContext context) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var replyMessageId = Constants.emptyString;

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }

      isUserTyping(false);
      isReplying(false);
      debugPrint("Sending Audio path $filePath");
      var file = File(filePath);
      var fileExists = await file.exists();
      debugPrint("filepath exists $fileExists");
      Mirrorfly.sendAudioMessage(
              profile.jid!, filePath, isRecorded, duration, replyMessageId)
          .then((value) {
        mirrorFlyLog("Audio Message sent", value);
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.insert(0, chatMessageModel);
        scrollToBottom();
        return chatMessageModel;
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : Constants.emptyString,
          messageType: Constants.mAudio,
          file: filePath,
          isAudioRecorded: isRecorded,
          audioDuration: duration);
      if (context.mounted) showBusyStatusAlert(disableBusyChatAndSend, context);
    }
  }

  void isTyping([String? typingText]) {
    messageController.text.isNotEmpty
        ? isUserTyping(true)
        : isUserTyping(false);
  }

  clearChatHistory(bool isStarredExcluded) {
    Mirrorfly.clearChat(profile.jid!, "chat", isStarredExcluded).then((value) {
      if (value) {
        // var chatListrev = chatList.reversed;

        isStarredExcluded
            ? chatList.removeWhere((p0) => p0.isMessageStarred.value == false)
            : chatList.clear();
        cancelReplyMessage();
        chatList.refresh();
      }
    });
  }

  void handleReplyChatMessage(ChatMessageModel chatListItem) {
    if (!chatListItem.isMessageRecalled.value &&
        !chatListItem.isMessageDeleted) {
      debugPrint(chatListItem.messageType);
      if (isReplying.value) {
        isReplying(false);
      }
      replyChatMessage = chatListItem;
      isReplying(true);
      if (!KeyboardVisibilityController().isVisible) {
        focusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
      }
    }
  }

  cancelReplyMessage() {
    isReplying(false);
    ReplyHashMap.saveReplyId(profile.jid.checkNull(), Constants.emptyString);
  }

  clearChatSelection(ChatMessageModel chatList) {
    selectedChatList.remove(chatList);
    chatList.isSelected(false);
    if (selectedChatList.isEmpty) {
      isSelected(false);
      selectedChatList.clear();
    }
    this.chatList.refresh();
  }

  clearAllChatSelection() {
    isSelected(false);
    for (var chatItem in chatList) {
      chatItem.isSelected(false);
    }
    selectedChatList.clear();
    chatList.refresh();
  }

  void addChatSelection(ChatMessageModel item) {
    if (item.messageType.toUpperCase() != Constants.mNotification) {
      selectedChatList.add(item);
      item.isSelected(true);
      // chatList.refresh();
    } else {
      debugPrint("Unable to Select Notification Banner");
    }
    getMessageActions();
  }


  reportChatOrUser(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () async {
      var chatMessage =
          selectedChatList.isNotEmpty ? selectedChatList[0] : null;
      Helper.showAlert(
          title: "${AppConstants.report} ${profile.getName()}?",
          message:
              selectedChatList.isNotEmpty ? AppConstants.thisMessageForwardToAdmin : AppConstants.last5Message,
          actions: [
            TextButton(
                onPressed: () async {
                  // Get.back();
                  Navigator.pop(context);
                  if (await AppUtils.isNetConnected()) {
                    Mirrorfly.reportUserOrMessages(
                            profile.jid!,
                            chatMessage?.messageChatType ?? "chat",
                            chatMessage?.messageId ?? Constants.emptyString)
                        .then((value) {
                      //report success
                      debugPrint(value.toString());
                      if (value.checkNull()) {
                        toToast(AppConstants.reportSent);
                      } else {
                        toToast(AppConstants.noMessagesAvailable);
                      }
                    }).catchError((onError) {
                      //report failed
                      debugPrint(onError.toString());
                    });
                  } else {
                    toToast(AppConstants.noInternetConnection);
                  }
                },
                child: Text(
                  AppConstants.report.toUpperCase(),
                  style:
                      TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
                )),
            TextButton(
                onPressed: () {
                  // Get.back();
                  Navigator.pop(context);
                },
                child: Text(
                  AppConstants.cancel.toUpperCase(),
                  style:
                      TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
                )),
          ],
          context: context);
    });
  }

  copyTextMessages() {
    // PlatformRepo.copyTextMessages(selectedChatList[0].messageId);
    debugPrint('Copy text ==> ${selectedChatList[0].messageTextContent}');
    Clipboard.setData(
        ClipboardData(text: selectedChatList[0].messageTextContent.toString()));
    // selectedChatList.clear();
    // isSelected(false);
    clearChatSelection(selectedChatList[0]);
    toToast(AppConstants.textCopied);
  }

  Map<bool, bool> isMessageCanbeRecalled() {
    var recallTimeDifference =
        ((DateTime.now().millisecondsSinceEpoch - 30000) * 1000);
    return {
      selectedChatList.any((element) =>
              element.isMessageSentByMe &&
              !element.isMessageRecalled.value &&
              (element.messageSentTime > recallTimeDifference)):
          selectedChatList.any((element) =>
              !element.isMessageRecalled.value &&
              (element.isMediaMessage() &&
                  element.mediaChatMessage!.mediaLocalStoragePath
                      .checkNull()
                      .isNotEmpty))
    };
  }

  void deleteMessages(BuildContext context) {
    var isRecallAvailable = isMessageCanbeRecalled().keys.first;
    var isCheckBoxShown = isMessageCanbeRecalled().values.first;
    var deleteChatListID = List<String>.empty(growable: true);
    for (var element in selectedChatList) {
      deleteChatListID.add(element.messageId);
    }
    /*for (var chatList in selectedChatList) {
      deleteChatListID.add(chatList.messageId);
      if ((chatList.messageSentTime > (DateTime.now().millisecondsSinceEpoch - 30000) * 1000) && chatList.isMessageSentByMe) {
        isRecallAvailable = true;
      } else {
        isRecallAvailable = false;
        break;
      }
    }*/
    if (deleteChatListID.isEmpty) {
      return;
    }
    var isMediaDelete = false.obs;
    var chatType = profile.isGroupProfile ?? false ? "groupchat" : "chat";
    Helper.showAlert(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
        selectedChatList.length > 1 ? AppConstants.deleteSelectedMessages : AppConstants.deleteSelectedMessage,
              // "Are you sure you want to delete selected Message${selectedChatList.length > 1 ? "s" : Constants.emptyString}?",
              style:
                  TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor),
            ),
            isCheckBoxShown
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          isMediaDelete(!isMediaDelete.value);
                          mirrorFlyLog(
                              "isMediaDelete", isMediaDelete.value.toString());
                        },
                        child: Row(
                          children: [
                            Obx(() {
                              return Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors.grey,
                                ),
                                child: Checkbox(
                                    value: isMediaDelete.value,
                                    activeColor: MirrorflyUikit
                                        .getTheme!.primaryColor, //Colors.white,
                                    checkColor:
                                        MirrorflyUikit.getTheme?.colorOnPrimary,
                                    onChanged: (value) {
                                      isMediaDelete(!isMediaDelete.value);
                                      mirrorFlyLog(
                                          "isMediaDelete", value.toString());
                                    }),
                              );
                            }),
                            Expanded(
                              child: Text(
                                AppConstants.deleteMediaFromPhone,
                                style: TextStyle(
                                    color: MirrorflyUikit
                                        .getTheme?.textSecondaryColor),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                : const SizedBox(),
          ],
        ),
        message: Constants.emptyString,
        actions: [
          TextButton(
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
              },
              child: Text(
                AppConstants.cancel.toUpperCase(),
                style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
              )),
          TextButton(
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
                //Helper.showLoading(message: 'Deleting Message');
                Mirrorfly.deleteMessagesForMe(profile.jid!, chatType,
                        deleteChatListID, isMediaDelete.value)
                    .then((value) {
                  debugPrint(value.toString());
                  //Helper.hideLoading();
                  /*if (value!=null && value) {
                  removeChatList(selectedChatList);
                }
                isSelected(false);
                selectedChatList.clear();*/
                });
                removeChatList(selectedChatList);
                isSelected(false);
                selectedChatList.clear();
              },
              child: Text(
                AppConstants.deleteForMe.toUpperCase(),
                style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
              )),
          isRecallAvailable
              ? TextButton(
                  onPressed: () {
                    // Get.back();
                    Navigator.pop(context);
                    //Helper.showLoading(message: 'Deleting Message for Everyone');
                    Mirrorfly.deleteMessagesForEveryone(profile.jid!, chatType,
                            deleteChatListID, isMediaDelete.value)
                        .then((value) {
                      debugPrint("delete for everyone ==>${value.toString()}");
                      //Helper.hideLoading();
                      if (value != null && value) {
                        // removeChatList(selectedChatList);//
                        for (var chatList in selectedChatList) {
                          chatList.isMessageRecalled(true);
                          chatList.isSelected(false);
                          // this.chatList.refresh();
                        }
                      }
                      if (!value) {
                        toToast(AppConstants.unableToDelete);
                        for (var chatList in selectedChatList) {
                          chatList.isSelected(false);
                          // this.chatList.refresh();
                        }
                      }
                      isSelected(false);
                      selectedChatList.clear();
                    });
                  },
                  child: Text(
                    AppConstants.deleteForEveryone,
                    style:
                        TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
                  ))
              : const SizedBox.shrink(),
        ],
        context: context);
  }

  removeChatList(RxList<ChatMessageModel> selectedChatList) {
    for (var chatList in selectedChatList) {
      this.chatList.remove(chatList);
    }
  }

  messageInfo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      debugPrint("sending mid ===> ${selectedChatList[0].messageId}");
      var selected = selectedChatList[0];
      setOnGoingUserGone();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (cont) => MessageInfoView(
                  // messageID: selectedChatList[0].messageId,
                  chatMessage: selected,
                  isGroupProfile: profile.isGroupProfile.checkNull(),
                  jid: profile.jid.checkNull(),
                  showChatDeliveryIndicator: showChatDeliveryIndicator,))).then((value) =>  setOnGoingUserAvail());
      clearChatSelection(selectedChatList[0]);
    });
  }

  favouriteMessage() {
    for (var item in selectedChatList) {
      Mirrorfly.updateFavouriteStatus(item.messageId, item.chatUserJid,
          !item.isMessageStarred.value, item.messageChatType);
      var msg =
          chatList.firstWhere((element) => item.messageId == element.messageId);
      msg.isMessageStarred(!item.isMessageStarred.value);
      msg.isSelected(false);
    }
    isSelected(false);
    selectedChatList.clear();
    // chatList.refresh();
  }

  blockUser(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () async {
      Helper.showAlert(
          message: "${AppConstants.youWantBlock} ${profile.getName()}?",
          actions: [
            TextButton(
                onPressed: () {
                  // Get.back();
                  Navigator.pop(context);
                },
                child: Text(
                  AppConstants.cancel.toUpperCase(),
                  style:
                      TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
                )),
            TextButton(
                onPressed: () async {
                  if (await AppUtils.isNetConnected()) {
                    // Get.back();
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      Helper.showLoading(
                          message: AppConstants.blockingUser, buildContext: context);
                    }
                    Mirrorfly.blockUser(profile.jid!).then((value) {
                      debugPrint(value);
                      profile.isBlocked = true;
                      isBlocked(true);
                      profile_.refresh();
                      saveUnsentMessage();
                      Helper.hideLoading(context: context);
                      toToast('${profile.getName()} ${AppConstants.hasBlocked}');
                    }).catchError((error) {
                      Helper.hideLoading(context: context);
                      debugPrint(error);
                    });
                  } else {
                    toToast(AppConstants.noInternetConnection);
                  }
                },
                child: Text(
                  AppConstants.block.toUpperCase(),
                  style:
                      TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
                )),
          ],
          context: context);
    });
  }

  clearUserChatHistory(BuildContext context) {
    if (chatList.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        var starred =
            chatList.indexWhere((element) => element.isMessageStarred.value);
        Helper.showAlert(
            message: AppConstants.areYouClearChat,
            actions: [
              Visibility(
                visible: !starred.isNegative,
                child: TextButton(
                    onPressed: () {
                      // Get.back();
                      Navigator.pop(context);
                      clearChatHistory(false);
                    },
                    child: Text(
                      AppConstants.clearAll.toUpperCase(),
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.primaryColor),
                    )),
              ),
              TextButton(
                  onPressed: () {
                    // Get.back();
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppConstants.cancel.toUpperCase(),
                    style:
                        TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
                  )),
              Visibility(
                visible: starred.isNegative,
                child: TextButton(
                    onPressed: () {
                      // Get.back();
                      Navigator.pop(context);
                      clearChatHistory(false);
                    },
                    child: Text(
                      AppConstants.clear.toUpperCase(),
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.primaryColor),
                    )),
              ),
              Visibility(
                visible: !starred.isNegative,
                child: TextButton(
                    onPressed: () {
                      // Get.back();
                      clearChatHistory(true);
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppConstants.clearExceptStarred.toUpperCase(),
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.primaryColor),
                    )),
              ),
            ],
            context: context);
      });
    } else {
      toToast(AppConstants.noConversation);
    }
  }

  unBlockUser(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Helper.showAlert(
          message: "${AppConstants.unblock} ${profile.getName()}?",
          actions: [
            TextButton(
                onPressed: () {
                  // Get.back();
                  Navigator.pop(context);
                },
                child: Text(
                  AppConstants.cancel.toUpperCase(),
                  style:
                      TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
                )),
            TextButton(
                onPressed: () async {
                  if (await AppUtils.isNetConnected()) {
                    // Get.back();
                    if (context.mounted) Navigator.pop(context);
                    // if (context.mounted) Helper.showLoading(message: "Unblocking User",buildContext: context);
                    Mirrorfly.unblockUser(profile.jid!).then((value) {
                      debugPrint(value.toString());
                      profile.isBlocked = false;
                      isBlocked(false);
                      getUnsentMessageOfAJid();
                      // Helper.hideLoading(context: context);
                      toToast('${profile.getName()} ${AppConstants.hasUnBlocked}');
                    }).catchError((error) {
                      // Helper.hideLoading();
                      debugPrint(error);
                    });
                  } else {
                    toToast(AppConstants.noInternetConnection);
                  }
                },
                child: Text(AppConstants.unblock.toUpperCase())),
          ],
          context: context);
    });
  }

  var filteredPosition = <int>[].obs;
  var searchedText = TextEditingController();
  String lastInputValue = Constants.emptyString;

  setSearch(String text) {
    if (lastInputValue != text.trim()) {
      lastInputValue = text.trim();
      filteredPosition.clear();
      if (searchedText.text.trim().isNotEmpty) {
        for (var i = 0; i < chatList.length; i++) {
          if (chatList[i].messageType.toUpperCase() == Constants.mText &&
              chatList[i]
                  .messageTextContent
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          } else if (chatList[i].messageType.toUpperCase() ==
                  Constants.mImage &&
              chatList[i].mediaChatMessage!.mediaCaptionText.isNotEmpty &&
              chatList[i]
                  .mediaChatMessage!
                  .mediaCaptionText
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          } else if (chatList[i].messageType.toUpperCase() ==
                  Constants.mVideo &&
              chatList[i].mediaChatMessage!.mediaCaptionText.isNotEmpty &&
              chatList[i]
                  .mediaChatMessage!
                  .mediaCaptionText
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          } else if (chatList[i].messageType.toUpperCase() ==
                  Constants.mDocument &&
              chatList[i].mediaChatMessage!.mediaFileName.isNotEmpty &&
              chatList[i]
                  .mediaChatMessage!
                  .mediaFileName
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          } else if (chatList[i].messageType.toUpperCase() ==
                  Constants.mContact &&
              chatList[i].contactChatMessage!.contactName.isNotEmpty &&
              chatList[i]
                  .contactChatMessage!
                  .contactName
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          }
        }
      }
      chatList.refresh();
    }
  }

  var lastPosition = (-1).obs;
  var searchedPrev = Constants.emptyString;
  var searchedNxt = Constants.emptyString;

  searchInit() {
    lastPosition = (-1).obs;
    j = -1;
    searchedPrev = Constants.emptyString;
    searchedNxt = Constants.emptyString;
    filteredPosition.clear();
    searchedText.clear();
  }

  var j = -1;

  scrollUp() {
    if (filteredPosition.isNotEmpty) {
      var visiblePos = findTopFirstVisibleItemPosition();
      mirrorFlyLog("visiblePos", visiblePos.toString());
      mirrorFlyLog(
          "visiblePos2", findBottomLastVisibleItemPosition().toString());
      var g = getNextPosition(findTopFirstVisibleItemPosition(),
          findBottomLastVisibleItemPosition(), j);
      if (g != null) j = g;
      mirrorFlyLog("scrollUp", g.toString());
      if (j >= 0 && g != null) {
        _scrollToPosition(j);
      } else {
        toToast(AppConstants.noResultsFound);
      }
    } else {
      toToast(AppConstants.noResultsFound);
    }
  }

  scrollDown() {
    if (filteredPosition.isNotEmpty) {
      var visiblePos = findTopFirstVisibleItemPosition();
      mirrorFlyLog("visiblePos", visiblePos.toString());
      var g = getPreviousPosition(findTopFirstVisibleItemPosition(),
          findBottomLastVisibleItemPosition(), j);
      if (g != null) j = g;
      mirrorFlyLog("scrollDown", j.toString());
      if (j >= 0 && g != null) {
        _scrollToPosition(j);
      } else {
        toToast(AppConstants.noResultsFound);
      }
    } else {
      toToast(AppConstants.noResultsFound);
    }
  }

  var color = Colors.transparent.obs;

  _scrollToPosition(int position) {
    // mirrorFlyLog("position", position.toString());
    if (!position.isNegative) {
      var currentPosition = position;
      // filteredPosition[position]; //(chatList.length - (position));
      mirrorFlyLog("currentPosition", currentPosition.toString());
      chatList[currentPosition].isSelected(true);
      searchScrollController.jumpTo(index: currentPosition);
      Future.delayed(const Duration(milliseconds: 800), () {
        currentPosition = (currentPosition);
        chatList[currentPosition].isSelected(false);
        chatList.refresh();
      });
    } else {
      toToast(AppConstants.noResultsFound);
    }
  }

  int? getPreviousPosition(int end, int start, int previousPos) {
    var previousClicked =
        previousPos; //!previousPos.isNegative ? filteredPosition[previousPos] : -1;
    debugPrint(
        'start : $start end : $end previousClickedPos : $previousClicked');
    debugPrint('previousPos : $previousPos');
    var isNotInTheView = (previousClicked <= end && previousClicked >= start);
    if (previousClicked == filteredPosition.first && isNotInTheView) {
      return null;
    }
    var reversedList = filteredPosition.reversed.toList();
    var findBetweenOrBelow = reversedList.firstWhere((y) =>
        ((y <= end && y >= start) && !previousClicked.isNegative
            ? (previousClicked != y)
            : true) &&
        start > y);
    if (!findBetweenOrBelow.isNegative) {
      debugPrint('findBetweenOrBelow : $findBetweenOrBelow}');
    }
    debugPrint('filteredPosition : ${reversedList.join(',')}');
    return findBetweenOrBelow;
  }

  //returns the position of filtered position
  int? getNextPosition(int end, int start, int previousPos) {
    var previousClicked =
        previousPos; //!previousPos.isNegative ? filteredPosition[previousPos] : -1;
    debugPrint(
        'start : $start end : $end previousClickedPos : $previousClicked');
    debugPrint('previousPos : $previousPos');
    var isNotInTheView = (previousClicked <= end && previousClicked >= start);
    if (previousClicked == filteredPosition.last && isNotInTheView) {
      return null;
    }
    var findBetweenOrAbove = filteredPosition.firstWhere((y) =>
        ((y >= end && y <= start) && !previousClicked.isNegative
            ? (previousClicked != y)
            : true) &&
        start < y);
    if (!findBetweenOrAbove.isNegative) {
      debugPrint('findbetweenorabove : $findBetweenOrAbove');
    }
    debugPrint('filteredPosition : ${filteredPosition.join(',')}');
    return findBetweenOrAbove;
  }

  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  /*int findLastVisibleItemPosition() {
    var r = itemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
    position.itemTrailingEdge > min.itemTrailingEdge ? position : min)
        .index;
    return r<chatList.length ? r+1 : r;
  }*/

  int findTopFirstVisibleItemPosition() {
    var r = itemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge > min.itemTrailingEdge ? position : min)
        .index;
    return r; //< chatList.length ? r + 1 : r;
  }

  int findBottomLastVisibleItemPosition() {
    var r = itemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;
    return r; // < chatList.length ? r + 1 : r;
  }

  exportChat() async {
    if (chatList.isNotEmpty) {
      var permission = await AppPermission.getStoragePermission(context);
      if (permission) {
        Mirrorfly.exportChatConversationToEmail(profile.jid.checkNull())
            .then((value) async {
          debugPrint("exportChatConversationToEmail $value");
          var data = exportModelFromJson(value);
          if (data.mediaAttachmentsUrl != null) {
            if (data.mediaAttachmentsUrl!.isNotEmpty) {
              var xfiles = <XFile>[];
              data.mediaAttachmentsUrl
                  ?.forEach((element) => xfiles.add(XFile(element)));
              await Share.shareXFiles(xfiles);
            }
          }
        });
      } else {
        toToast(AppConstants.permissionDenied);
      }
    } else {
      toToast(AppConstants.noConversation);
    }
  }

  checkBusyStatusForForward(BuildContext context) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      forwardMessage();
    } else {
      if (context.mounted) showBusyStatusAlert(forwardMessage, context);
    }
  }

  forwardMessage() {
    var messageIds = List<String>.empty(growable: true);
    for (var chatItem in selectedChatList) {
      messageIds.add(chatItem.messageId);
      debugPrint(messageIds.length.toString());
      debugPrint(selectedChatList.length.toString());
    }
    if (messageIds.length == selectedChatList.length) {
      clearAllChatSelection();
      setOnGoingUserGone();
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (con) =>
                      ForwardChatView(forwardMessageIds: messageIds)))
          .then((value) {
        if (value != null) {
          // (value as Profile);
          debugPrint("result of forward ==> ${value.toJson().toString()}");
          profile_.value = value;
          isBlocked(profile.isBlocked);
        }
        setChatStatus();
        checkAdminBlocked();
        memberOfGroup();
        getChatHistory();
        setOnGoingUserAvail();
      });
    }
  }

  void closeKeyBoard() {
    FocusManager.instance.primaryFocus!.unfocus();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    startTime = DateTime.now();
    _audioTimer = Timer.periodic(
      oneSec,
      (Timer timer) {
        final minDur = DateTime.now().difference(startTime!).inMinutes;
        final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
        String min = minDur < 10 ? "0$minDur" : minDur.toString();
        String sec = secDur < 10 ? "0$secDur" : secDur.toString();
        timerInit("$min:$sec");
      },
    );
  }

  Future<void> cancelRecording() async {
    var filePath = await record.stop();
    File(filePath!).delete();
    _audioTimer?.cancel();
    record.dispose();
    _audioTimer = null;
    isAudioRecording(Constants.audioRecordDelete);

    Future.delayed(const Duration(milliseconds: 1500),
        () => isAudioRecording(Constants.audioRecordInitial));
  }

  startRecording(BuildContext context) async {
    if (playingChat != null) {
      playingChat!.mediaChatMessage!.isPlaying = false;
      playingChat = null;
      // player.stop();
      chatList.refresh();
    }
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (context.mounted) {
        var permission = await AppPermission.getStoragePermission(context);
        if (permission) {
          if (await Record().hasPermission()) {
            record = Record();
            timerInit("00:00");
            isAudioRecording(Constants.audioRecording);
            startTimer();
            await record.start(
              path:
              "$audioSavePath/audio_${DateTime
                  .now()
                  .millisecondsSinceEpoch}.m4a",
              ///If Change the Encode Format, kindly keep in mind to check the iOS record and send Audio.
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
              samplingRate: 44100,
            );
            Future.delayed(const Duration(seconds: 300), () {
              if (isAudioRecording.value == Constants.audioRecording) {
                stopRecording();
              }
            });
          }
        }
      }
    } else {
      //show busy status popup
      if (context.mounted) showBusyStatusAlert(startRecording, context);
    }
  }

  Future<void> stopRecording() async {
    isAudioRecording(Constants.audioRecordDone);
    isUserTyping(true);
    _audioTimer?.cancel();
    _audioTimer = null;
    await Record().stop().then((filePath) async {
      if (File(filePath!).existsSync()) {
        recordedAudioPath = filePath;
      } else {
        debugPrint("File Not Found For Audio");
      }
      debugPrint(filePath);
    });
  }

  Future<void> deleteRecording() async {
    var filePath = await record.stop();
    File(filePath!).delete();
    isUserTyping(false);
    isAudioRecording(Constants.audioRecordInitial);
    timerInit("00:00");
    record.dispose();
  }

  Future<void> setAudioPath() async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory(); //FOR iOS
    if (directory != null) {
      audioSavePath = directory.path;
      debugPrint(audioSavePath);
    } else {
      debugPrint("=======Unable to set Audio Path=========");
    }
  }

  sendRecordedAudioMessage(BuildContext context) {
    if (timerInit.value != "00:00") {
      final format = DateFormat('mm:ss');
      final dt = format.parse(timerInit.value, true);
      final recordDuration = dt.millisecondsSinceEpoch;
      sendAudioMessage(
          recordedAudioPath, true, recordDuration.toString(), context);
    } else {
      toToast(AppConstants.audioTooShort);
    }
    isUserTyping(false);
    isAudioRecording(Constants.audioRecordInitial);
    timerInit("00:00");
    record.dispose();
  }

  infoPage(BuildContext context) {
    setOnGoingUserGone();
    if (profile.isGroupProfile ?? false) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (con) =>
                  GroupInfoView(jid: profile.jid.checkNull()))).then((value) {
        if (value != null) {
          profile_(value as Profile);
          isBlocked(profile.isBlocked);
          debugPrint("value--> ${profile.isGroupProfile}");
        }
        checkAdminBlocked();
        memberOfGroup();
        getChatHistory();
        setChatStatus();
        setOnGoingUserAvail();
      });
      /*Get.toNamed(Routes.groupInfo, arguments: profile)?.then((value) {
        if (value != null) {
          profile_(value as Profile);
          isBlocked(profile.isBlocked);
          checkAdminBlocked();
          memberOfGroup();
          Mirrorfly.setOnGoingChatUser(profile.jid!);
          SessionManagement.setCurrentChatJID(profile.jid.checkNull());
          getChatHistory();
          sendReadReceipt();
          setChatStatus();
          debugPrint("value--> ${profile.isGroupProfile}");
        }
      });*/
    } else {
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (con) => ChatInfoView(jid: profile.jid.checkNull())))
          .then((value) {
        setOnGoingUserAvail();
      });
      /*Get.toNamed(Routes.chatInfo, arguments: profile)?.then((value) {
        debugPrint("chat info-->$value");
        // Mirrorfly.setOnGoingChatUser(profile.jid!);
        // SessionManagement.setCurrentChatJID(profile.jid.checkNull());
      });*/
    }
  }

  gotoSearch() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (con) => ChatSearchView(showChatDeliveryIndicator: showChatDeliveryIndicator,)));

    });
  }

  sendUserTypingStatus() {
    Mirrorfly.sendTypingStatus(profile.jid.checkNull(), profile.getChatType());
  }

  sendUserTypingGoneStatus() {
    Mirrorfly.sendTypingGoneStatus(
        profile.jid.checkNull(), profile.getChatType());
  }

  var unreadCount = 0.obs;

  void onMessageReceived(chatMessageModel) {
    mirrorFlyLog("chatController", "onMessageReceived");

    if (chatMessageModel.chatUserJid == profile.jid) {
      removeUnreadSeparator();
      final index = chatList.indexWhere((message) => message.messageId == chatMessageModel.messageId);
      debugPrint("message received index $index");
      if (index.isNegative) {
        chatList.insert(0, chatMessageModel);
        unreadCount.value++;
        //scrollToBottom();
        if(SessionManagement.getCurrentChatJID() != Constants.emptyString){
          setOnGoingUserAvail();
        }
      }
    }
  }

  void onMessageStatusUpdated(ChatMessageModel chatMessageModel) {
    if (chatMessageModel.chatUserJid == profile.jid) {
      final index = chatList.indexWhere(
          (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("ChatScreen Message Status Update index of search $index");
      debugPrint("messageID--> $index");
      if (!index.isNegative) {
        debugPrint("messageID--> replacing the value");
        // Helper.hideLoading();
        // chatMessageModel.isSelected=chatList[index].isSelected;
        chatList[index] = chatMessageModel;
        chatList.refresh();
      } else {
        debugPrint("messageID--> Inserting the value");
        // chatList.insert(0, chatMessageModel);
        // unreadCount.value++;
        // scrollToBottom();
      }
    }
    if (isSelected.value) {
      var selectedIndex = selectedChatList.indexWhere(
          (element) => chatMessageModel.messageId == element.messageId);
      if (!selectedIndex.isNegative) {
        chatMessageModel
            .isSelected(true); //selectedChatList[selectedIndex].isSelected;
        selectedChatList[selectedIndex] = chatMessageModel;
        selectedChatList.refresh();
        getMessageActions();
      }
    }
  }

  void onMediaStatusUpdated(chatMessageModel) {
    if (chatMessageModel.chatUserJid == profile.jid) {
      final index = chatList.indexWhere(
          (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("Media Status Update index of search $index");
      if (index != -1) {
        // chatMessageModel.isSelected=chatList[index].isSelected;
        chatList[index] = chatMessageModel;
      }
    }
    if (isSelected.value) {
      var selectedIndex = selectedChatList.indexWhere(
          (element) => chatMessageModel.messageId == element.messageId);
      if (!selectedIndex.isNegative) {
        chatMessageModel.isSelected =
            true; //selectedChatList[selectedIndex].isSelected;
        selectedChatList[selectedIndex] = chatMessageModel;
        selectedChatList.refresh();
        getMessageActions();
      }
    }
  }

  void onGroupProfileUpdated(groupJid) {
    if (profile.jid.checkNull() == groupJid.toString()) {
      getProfileDetails(profile.jid.checkNull()).then((value) {
        if (value.jid != null) {
          // var member = profileDataFromJson(value).data ?? ProfileData();
          // var member = Profile.fromJson(json.decode(value.toString()));
          profile_.value = value;
          profile_.refresh();
          checkAdminBlocked();
        }
      });
    }
  }

  void onLeftFromGroup({required String groupJid, required String userJid}) {
    if (profile.isGroupProfile ?? false) {
      if (groupJid == profile.jid &&
          userJid == SessionManagement.getUserJID()) {
        //current user leave from the group
        _isMemberOfGroup(false);
      } else if (groupJid == profile.jid) {
        setChatStatus();
      }
    }
  }

  void setTypingStatus(
      String singleOrgroupJid, String userId, String typingStatus) {
    if (profile.jid.checkNull() == singleOrgroupJid) {
      var jid = profile.isGroupProfile ?? false ? userId : singleOrgroupJid;
      if (!typingList.contains(jid)) {
        typingList.add(jid);
      }
      if (typingStatus.toLowerCase() == Constants.composing) {
        if (profile.isGroupProfile ?? false) {
          groupParticipantsName(Constants.emptyString);
          getProfileDetails(jid)
              .then((value) => userPresenceStatus("${value.name} typing..."));
        } else {
          //if(!profile.isGroupProfile!){//commented if due to above if condition works
          userPresenceStatus(AppConstants.typing);
        }
      } else {
        if (typingList.isNotEmpty && typingList.contains(jid)) {
          typingList.remove(jid);
          userPresenceStatus(Constants.emptyString);
        }
        setChatStatus();
      }
    }
  }

  memberOfGroup() {
    if (profile.isGroupProfile ?? false) {
      Mirrorfly.isMemberOfGroup(profile.jid.checkNull(), null)
          .then((bool? value) {
        if (value != null) {
          _isMemberOfGroup(value);
        }
      });
    }
  }

  var userPresenceStatus = Constants.emptyString.obs;
  var typingList = <String>[].obs;

  setChatStatus() async {
    if (await AppUtils.isNetConnected()) {
      if (profile.isGroupProfile.checkNull()) {
        debugPrint("value--> show group list");
        if (typingList.isNotEmpty) {
          var typ = await Member(jid: typingList.last).getUsername();
          userPresenceStatus("$typ ${AppConstants.typing}");
          //"${Member(jid: typingList.last).getUsername()} typing...");
        } else {
          getParticipantsNameAsCsv(profile.jid.checkNull());
        }
      } else {
        if (!profile.isBlockedMe.checkNull() ||
            !profile.isAdminBlocked.checkNull()) {
          Mirrorfly.getUserLastSeenTime(profile.jid.toString()).then((value) {
            debugPrint("date time flutter--->");
            var lastSeen = convertSecondToLastSeen(value!);
            groupParticipantsName(Constants.emptyString);
            userPresenceStatus(lastSeen.toString());
          }).catchError((er) {
            groupParticipantsName(Constants.emptyString);
            userPresenceStatus(Constants.emptyString);
          });
        } else {
          groupParticipantsName(Constants.emptyString);
          userPresenceStatus(Constants.emptyString);
        }
      }
    } else {
      userPresenceStatus(Constants.emptyString);
    }
  }

  var groupParticipantsName = Constants.emptyString.obs;

  getParticipantsNameAsCsv(String jid) {
    Mirrorfly.getGroupMembersList(jid, false).then((value) {
      if (value != null) {
        var str = <String>[];
        mirrorFlyLog("getGroupMembersList-->", value);
        var groupsMembersProfileList = memberFromJson(value);
        for (var it in groupsMembersProfileList) {
          if (it.jid.checkNull() !=
              SessionManagement.getUserJID().checkNull()) {
            str.add(getMemberName(it).checkNull());
          }
        }
        str.sort((a, b) {
          return a.toLowerCase().compareTo(b.toLowerCase());
        });
        groupParticipantsName(str.join(","));
      }
    });
  }

  String get subtitle => userPresenceStatus.isEmpty
      ? /*groupParticipantsName.isNotEmpty
          ? groupParticipantsName.toString()
          :*/
      Constants.emptyString
      : userPresenceStatus.toString();

  // final ImagePicker _picker = ImagePicker();

  onCameraClick() async {
    // if (await AppPermission.askFileCameraAudioPermission()) {
    var cameraPermissionStatus = await AppPermission.checkPermission(context,
        Permission.camera, cameraPermission, AppConstants.cameraPermission);
    debugPrint("Camera Permission Status---> $cameraPermissionStatus");
    if (cameraPermissionStatus) {
      if (context.mounted) {
        setOnGoingUserGone();
        Navigator.push(
                context, MaterialPageRoute(builder: (con) => CameraPickView()))
            .then((photo) {
          photo as XFile?;
          if (photo != null) {
            mirrorFlyLog("photo", photo.name.toString());
            mirrorFlyLog("caption text sending-->", messageController.text);
            var file = PickedAssetModel(
              path: photo.path,
              type: !photo.name.endsWith(".mp4") ? "image" : "video",
            );
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (con) => MediaPreviewView(
                          filePath: [file],
                          userName: profile.name.checkNull(),
                          profile: profile,
                          caption: messageController.text.trim(),
                          showAdd: false,
                        ))).then((value) => setOnGoingUserAvail());
          }else{
            setOnGoingUserAvail();
          }
        });
      }
      /*Get.toNamed(Routes.cameraPick)?.then((photo) {
        photo as XFile?;
        if (photo != null) {
          mirrorFlyLog("photo", photo.name.toString());
          mirrorFlyLog("caption text sending-->", messageController.text);
          */ /*if (photo.name.endsWith(".mp4")) {
            Get.toNamed(Routes.videoPreview, arguments: {
              "filePath": photo.path,
              "userName": profile.name!,
              "profile": profile,
              "caption": messageController.text
            });
          } else {
            Get.toNamed(Routes.imagePreview, arguments: {
              "filePath": photo.path,
              "userName": profile.name!,
              "profile": profile,
              "caption": messageController.text
            });
          }*/ /*
          var file = PickedAssetModel(
            path: photo.path,
            type: !photo.name.endsWith(".mp4") ? "image" : "video",
          );
          Get.toNamed(Routes.mediaPreview, arguments: {
            "filePath": [file],
            "userName": profile.name!,
            'profile': profile,
            'caption': messageController.text,
            'showAdd': false
          });
        }
      });*/
    }
    /*final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Get.toNamed(Routes.imagePreview,
          arguments: {"filePath": photo.path, "userName": profile.name!});
    }*/
  }

  // Future<bool> askMicrophonePermission() async {
  //   final permission = await AppPermission.getAudioPermission();
  //   switch (permission) {
  //     case PermissionStatus.granted:
  //       return true;
  //     case PermissionStatus.permanentlyDenied:
  //       return false;
  //     default:
  //       debugPrint("Contact Permission default");
  //       return false;
  //   }
  // }

  onAudioClick(BuildContext context) {
    // Get.back();
    AppPermission.getStoragePermission(context).then((value) {
      if (value) {
        pickAudio(context);
      }
    });
    /*if (await AppPermission.checkPermission(
        context,Permission.storage, filePermission, Constants.filePermission)) {
      if (context.mounted) pickAudio(context);
    }*/
  }

  onGalleryClick() async {
    // if (await askStoragePermission()) {
    AppPermission.getStoragePermission(context).then((value) {
      if (value) {
        try {
          // imagePicker();
          // Get.toNamed(Routes.galleryPicker, arguments: {
          //   "userName": getName(profile),
          //   'profile': profile,
          //   'caption': messageController.text
          // });
          if (context.mounted) {
            setOnGoingUserGone();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (con) => GalleryPickerView(
                        senderJid: profile.jid.checkNull(),
                        caption: messageController.text.trim()))).then((value) =>  setOnGoingUserAvail());
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    });
    /*if (await AppPermission.checkPermission(context, Permission.storage, filePermission, Constants.filePermission)) {
      try {
        // imagePicker();
        // Get.toNamed(Routes.galleryPicker, arguments: {
        //   "userName": getName(profile),
        //   'profile': profile,
        //   'caption': messageController.text
        // });
        if(context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (con) =>
              GalleryPickerView(
                  senderJid: profile.jid.checkNull(),
                  caption: messageController.text)));
        }

      } catch (e) {
        debugPrint(e.toString());
      }
    }*/
  }

  onContactClick() async {
    AppPermission.checkPermission(context, Permission.contacts,
            contactPermission, AppConstants.contactPermission)
        .then((value) {
      if (value) {
        if (context.mounted) {
          setOnGoingUserGone();
          Navigator.push(context,
              MaterialPageRoute(builder: (con) => const LocalContactView())).then((value) =>  setOnGoingUserAvail());
        }
      }
    });
    /*if (await AppPermission.checkPermission(
        context,Permission.contacts, contactPermission, Constants.contactPermission)) {
      // Get.toNamed(Routes.localContact);
      if(context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (con) => const LocalContactView()));
      }
    } else {
      // AppPermission.permissionDeniedDialog(content: "Permission is permanently denied. Please enable Contact permission from settings");
    }*/
  }

  // Future<bool> askLocationPermission() async {
  //   final permission = await AppPermission.getLocationPermission();
  //   debugPrint("Permission$permission");
  //   switch (permission) {
  //     case PermissionStatus.granted:
  //       return true;
  //     case PermissionStatus.permanentlyDenied:
  //       Helper.showAlert(
  //           message:
  //               "Permission is permanently denied. Please enable location permission from settings",
  //           title: "Permission Denied",
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   Get.back();
  //                 },
  //                 child: const Text("OK")),
  //           ]);
  //
  //       return false;
  //     default:
  //       debugPrint("Location Permission default");
  //       return false;
  //   }
  // }

  onLocationClick(BuildContext context) async {
    if (await AppUtils.isNetConnected()) {
      if (context.mounted) {
        setOnGoingUserGone();
        AppPermission.checkPermission(context, Permission.location,
                locationPinPermission, AppConstants.locationPermission)
            .then((value) {
          if (value) {
            if (context.mounted) {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (con) => const LocationSentView()))
                  .then((value) {
                if (value != null) {
                  value as LatLng;
                  sendLocationMessage(
                      profile, value.latitude, value.longitude, context);
                }
                setOnGoingUserAvail();
              });
            }
          }
        });
      }
      /*if (await AppPermission.checkPermission(context,Permission.location,
          locationPinPermission, Constants.locationPermission)) {
        if(context.mounted) {
          Navigator.push(
              context, MaterialPageRoute(builder: (con) => LocationSentView()))
              .then((value) {
            if (value != null) {
              value as LatLng;
              sendLocationMessage(
                  profile, value.latitude, value.longitude, context);
            }
          });
        }
        // Get.toNamed(Routes.locationSent)?.then((value) {
        //   if (value != null) {
        //     value as LatLng;
        //     sendLocationMessage(
        //         profile, value.latitude, value.longitude, context);
        //   }
        // });
      } else {
        // AppPermission.permissionDeniedDialog(content: "Permission is permanently denied. Please enable location permission from settings");
      }*/
    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  checkAdminBlocked() {
    if (profile.isGroupProfile.checkNull()) {
      if (profile.isAdminBlocked.checkNull()) {
        toToast(AppConstants.groupNoLonger);
        // Get.back();
        Navigator.pop(context);
      }
    } else {
      if (profile.isAdminBlocked.checkNull()) {
        toToast(AppConstants.chatNoLonger);
        // Get.back();
        Navigator.pop(context);
      }
    }
  }

  /*@override
  void onAdminBlockedUser(String jid, bool status) {
    super.onAdminBlockedUser(jid, status);
    mirrorFlyLog("chat onAdminBlockedUser", "$jid, $status");
    Get.find<MainController>().handleAdminBlockedUser(jid, status);
  }*/

  /*makeVoiceCall(){
    Mirrorfly.makeVoiceCall(profile.jid.checkNull()).then((value){
      mirrorFlyLog("makeVoiceCall", value.toString());
    });
  }*/

  Future<void> translateMessage(int index) async {
    /*if (SessionManagement.isGoogleTranslationEnable()) {
      var text = chatList[index].messageTextContent!;
      debugPrint("customField : ${chatList[index].messageCustomField.isEmpty}");
      if (chatList[index].messageCustomField.isNotEmpty) {
      } else {
        await translator
            .translate(
                text: text, to: SessionManagement.getTranslationLanguageCode())
            .then((translation) {
          var map = <String, dynamic>{};
          map["is_message_translated"] = true;
          map["translated_language"] =
              SessionManagement.getTranslationLanguage();
          map["translated_message_content"] = translation.translatedText;
          debugPrint(
              "translation source : ${translation.detectedSourceLanguage}");
          debugPrint("translation text : ${translation.translatedText}");
        }).catchError((onError) {
          debugPrint("exception : $onError");
        });
      }
    }*/
  }

  bool forwardMessageVisibility(ChatMessageModel chat) {
    if (!chat.isMessageRecalled.value && !chat.isMessageDeleted) {
      if (chat.isMediaMessage()) {
        if (chat.mediaChatMessage!.mediaDownloadStatus ==
                Constants.mediaDownloaded ||
            chat.mediaChatMessage!.mediaUploadStatus ==
                Constants.mediaUploaded) {
          return true;
        }
      } else {
        if (chat.messageType == Constants.mLocation ||
            chat.messageType == Constants.mContact) {
          return true;
        }
      }
    }
    return false;
  }

  forwardSingleMessage(String messageId) {
    setOnGoingUserGone();
    var messageIds = <String>[];
    messageIds.add(messageId);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (con) =>
                ForwardChatView(forwardMessageIds: messageIds))).then((value) {
      if (value != null) {
        // (value as Profile);
        // getUserProfile(value.toString()).then((value) {
        debugPrint("result of forward ==> ${value.toJson().toString()}");
        profile_.value = value;
        isBlocked(profile.isBlocked);
        // });
      }
      checkAdminBlocked();
      memberOfGroup();
      setOnGoingUserAvail();
      getChatHistory();
      sendReadReceipt();
    });
    /*Get.toNamed(Routes.forwardChat, arguments: {
      "forward": true,
      "group": false,
      "groupJid": Constants.emptyString,
      "messageIds": messageIds
    })?.then((value) {
      if (value != null) {
        debugPrint(
            "result of forward ==> ${(value as Profile).toJson().toString()}");
        profile_.value = value;
        isBlocked(profile.isBlocked);
        checkAdminBlocked();
        memberOfGroup();
        Mirrorfly.setOnGoingChatUser(profile.jid!);
        SessionManagement.setCurrentChatJID(profile.jid.checkNull());
        getChatHistory();
        sendReadReceipt();
      }
    });*/
  }

  var containsRecalled = false.obs;
  var canBeStarred = false.obs;
  var canBeStarredSet = false;
  var canBeUnStarred = false.obs;
  var canBeUnStarredSet = false;
  var canBeShared = false.obs;
  var canBeSharedSet = false;
  var canBeForwarded = false.obs;
  var canBeForwardedSet = false;
  var canBeCopied = false.obs;
  var canBeCopiedSet = false;
  var canBeReplied = false.obs;
  var canShowInfo = false.obs;
  var canShowReport = false.obs;

  getMessageActions() {
    if (selectedChatList.isEmpty) {
      return;
    }

    containsRecalled(false);
    canBeStarred(true);
    canBeStarredSet = false;
    canBeUnStarred(true);
    canBeUnStarredSet = false;
    canBeShared(true);
    canBeSharedSet = false;
    canBeForwarded(true);
    canBeForwardedSet = false;
    canBeCopied(true);
    canBeCopiedSet = false;
    canBeReplied(true);
    canShowInfo(true);
    canShowReport(true);

    for (var message in selectedChatList) {
      //Recalled Validation
      if (message.isMessageRecalled.value) {
        containsRecalled(true);
        break;
      }
      //Copy Validation
      if (!canBeCopiedSet && (!message.isTextMessage())) {
        canBeCopied(false);
        canBeCopiedSet = true;
      }
      setMessageActionValidations(message);
    }
    getMessagesActionDetails();
  }

  setMessageActionValidations(ChatMessageModel message) {
    //Forward Validation - can be added for forwarding more than one messages
    if (!canBeForwardedSet &&
        ((message.isMessageSentByMe && message.messageStatus.value == "N") ||
            (message.isMediaMessage() &&
                !checkFile(message.mediaChatMessage!.mediaLocalStoragePath)))) {
      canBeForwarded(false);
      canBeForwardedSet = true;
    }
    //Share Validation
    if (!canBeSharedSet &&
        (!message.isMediaMessage() ||
            (message.isMediaMessage() &&
                !checkFile(message.mediaChatMessage!.mediaLocalStoragePath)))) {
      canBeShared(false);
      canBeSharedSet = true;
    }
    //Starred Validation
    if (!canBeStarredSet && message.isMessageStarred.value ||
        (message.isMediaMessage() &&
            !checkFile(message.mediaChatMessage!.mediaLocalStoragePath))) {
      canBeStarred(false);
      canBeStarredSet = true;
    }
    //UnStarred Validation
    if (!canBeUnStarredSet && !message.isMessageStarred.value) {
      canBeUnStarred(false);
      canBeUnStarredSet = true;
    }
  }

  getMessagesActionDetails() {
    switch (selectedChatList.length) {
      case 1:
        var message = selectedChatList.first;
        setMenuItemsValidations(message);
        break;
      default:
        canBeReplied(false);
        canShowInfo(false);
        canBeCopied(false);
        canShowReport(false);
    }

    canBeStarred(!canBeStarred.value && !canBeUnStarred.value ||
        canBeStarred.value && !canBeUnStarred.value);

    if (containsRecalled.value) {
      canBeCopied(false);
      canBeForwarded(false);
      canBeShared(false);
      canBeStarred(false);
      canBeUnStarred(false);
      canBeReplied(false);
      canShowInfo(false);
      canShowReport(false);
    }
    // return messageActions;
    mirrorFlyLog("action_menu canBeCopied", canBeCopied.toString());
    mirrorFlyLog("action_menu canBeForwarded", canBeForwarded.toString());
    mirrorFlyLog("action_menu canBeShared", canBeShared.toString());
    mirrorFlyLog("action_menu canBeStarred", canBeStarred.toString());
    mirrorFlyLog("action_menu canBeUnStarred", canBeUnStarred.toString());
    mirrorFlyLog("action_menu canBeReplied", canBeReplied.toString());
    mirrorFlyLog("action_menu canShowInfo", canShowInfo.toString());
    mirrorFlyLog("action_menu canShowReport", canShowReport.toString());
  }

  setMenuItemsValidations(ChatMessageModel message) {
    if (!containsRecalled.value) {
      //Reply Validation
      if (message.isMessageSentByMe && message.messageStatus.value == "N") {
        canBeReplied(false);
      }
      //Info Validation
      if (!message.isMessageSentByMe ||
          message.messageStatus.value == "N" ||
          message.isMessageRecalled.value ||
          (message.isMediaMessage() &&
              !checkFile(message.mediaChatMessage!.mediaLocalStoragePath))) {
        canShowInfo(false);
      }
      //Report validation
      if (message.isMessageSentByMe) {
        canShowReport(false);
      } else {
        canShowReport(true);
      }
    }
  }

  void navigateToMessage(ChatMessageModel chatMessage, {int? index}) {
    var messageID = chatMessage.messageId;
    var chatIndex = index ??
        chatList.indexWhere((element) => element.messageId == messageID);
    if (!chatIndex.isNegative) {
      newScrollController.scrollTo(
          index: chatIndex, duration: const Duration(milliseconds: 10));
      Future.delayed(const Duration(milliseconds: 15), () {
        chatList[chatIndex].isSelected(true);
        chatList.refresh();
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        chatList[chatIndex].isSelected(false);
        chatList.refresh();
      });
    }
  }

  int findLastVisibleItemPositionForChat() {
    /*var r = newitemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;
    return r < chatList.length ? r + 1 : r;*/
    return newitemPositionsListener.itemPositions.value.first.index;
  }

  void share() {
    var mediaPaths = <XFile>[];
    for (var item in selectedChatList) {
      if (item.isMediaMessage()) {
        if ((item.isMediaDownloaded() || item.isMediaUploaded()) &&
            item.mediaChatMessage!.mediaLocalStoragePath
                .checkNull()
                .isNotEmpty) {
          mediaPaths.add(
              XFile(item.mediaChatMessage!.mediaLocalStoragePath.checkNull()));
        }
      }
    }
    clearAllChatSelection();
    Share.shareXFiles(mediaPaths);
  }

  @override
  void onPaused() {
    mirrorFlyLog("chat controller LifeCycle", "onPaused");
    setOnGoingUserGone();
    playerPause();
    saveUnsentMessage();
    sendUserTypingGoneStatus();
  }

  @override
  void onResumed() {
    mirrorFlyLog("LifeCycle", "onResumed");
    AppPermission.requestNotificationPermission();
    setChatStatus();
    if (!KeyboardVisibilityController().isVisible) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
      }
      if (searchfocusNode.hasFocus) {
        searchfocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          searchfocusNode.requestFocus();
        });
      }
    }
    setOnGoingUserAvail();
  }

  @override
  void onDetached() {
    mirrorFlyLog("LifeCycle", "onDetached");
  }

  @override
  void onInactive() {
    mirrorFlyLog("LifeCycle", "onInactive");
  }

  void userUpdatedHisProfile(String jid) {
    updateProfile(jid);
  }

  void unblockedThisUser(String jid) {
    updateProfile(jid);
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty && jid == profile.jid) {
      if (!profile.isGroupProfile.checkNull()) {
        getProfileDetails(jid).then((value) {
          debugPrint("update Profile contact sync $value");
          SessionManagement.setChatJid(Constants.emptyString);
          profile_(value);
          checkAdminBlocked();
          isBlocked(profile.isBlocked);
          setChatStatus();
          profile_.refresh();
        });
      } else {
        debugPrint("unable to update profile due to group chat");
      }
    }
  }

  void userCameOnline(jid) {
    if (jid.isNotEmpty &&
        profile.jid == jid &&
        !profile.isGroupProfile.checkNull()) {
      debugPrint("userCameOnline : $jid");
      Future.delayed(const Duration(milliseconds: 3000), () {
        setChatStatus();
      });
    }
  }

  void userWentOffline(jid) {
    if (jid.isNotEmpty &&
        profile.jid == jid &&
        !profile.isGroupProfile.checkNull()) {
      debugPrint("userWentOffline : $jid");
      Future.delayed(const Duration(milliseconds: 3000), () {
        setChatStatus();
      });
    }
  }

  void networkConnected() {
    mirrorFlyLog("networkConnected", 'true');
    Future.delayed(const Duration(milliseconds: 2000), () {
      setChatStatus();
    });
  }

  void networkDisconnected() {
    mirrorFlyLog('networkDisconnected', 'false');
    setChatStatus();
  }

  void removeUnreadSeparator() async {
    if (!profile.isGroupProfile.checkNull()) {
      chatList.removeWhere(
          (chatItem) => chatItem.messageType == Constants.mNotification);
    }
  }

  void onContactSyncComplete(bool result) {
    userUpdatedHisProfile(profile.jid.checkNull());
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  void onNewMemberAddedToGroup(
      {required String groupJid,
      required String newMemberJid,
      required String addedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      if (profile.jid == groupJid) {
        debugPrint('onNewMemberAddedToGroup $newMemberJid');
        getParticipantsNameAsCsv(groupJid);
      }
    }
  }

  void onMemberRemovedFromGroup(
      {required String groupJid,
      required String removedMemberJid,
      required String removedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      if (profile.jid == groupJid) {
        debugPrint('onMemberRemovedFromGroup $removedMemberJid');
        if (removedMemberJid != profile.jid) {
          getParticipantsNameAsCsv(groupJid);
        } else {
          //removed me
          onLeftFromGroup(groupJid: groupJid, userJid: removedMemberJid);
        }
      }
    }
  }

  Future<void> saveContact() async {
    var phone = profile.mobileNumber.checkNull().isNotEmpty
        ? profile.mobileNumber.checkNull()
        : getMobileNumberFromJid(profile.jid.checkNull());
    var userName = profile.nickName.checkNull().isNotEmpty
        ? profile.nickName.checkNull()
        : profile.name.checkNull();
    if (phone.isNotEmpty) {
      lib_phone_number.init();
      var formatNumberSync = lib_phone_number.formatNumberSync(phone);
      var parse = await lib_phone_number.parse(formatNumberSync);
      debugPrint("parse-----> $parse");
      Mirrorfly.addContact(parse["international"], userName).then((value) {
        if (value ?? false) {
          toToast(AppConstants.contactSaved);
          if (!MirrorflyUikit.instance.isTrialLicenceKey) {
            syncContacts();
          }
        }
      });
    } else {
      mirrorFlyLog('mobile number', phone.toString());
    }
  }

  void syncContacts() async {
    if (await Permission.contacts.isGranted) {
      if (await AppUtils.isNetConnected() &&
          !await Mirrorfly.contactSyncStateValue()) {
        final permission = await Permission.contacts.status;
        if (permission == PermissionStatus.granted) {
          if (SessionManagement.getLogin()) {
            Mirrorfly.syncContacts(
                !SessionManagement.isInitialContactSyncDone());
          }
        }
      }
    } else {
      debugPrint("Contact sync permission is not granted");
      if (SessionManagement.isInitialContactSyncDone()) {
        Mirrorfly.revokeContactSync().then((value) {
          onContactSyncComplete(true);
          mirrorFlyLog("checkContactPermission isSuccess", value.toString());
        });
      }
    }
  }

  void userBlockedMe(String jid) {
    updateProfile(jid);
  }

  void showHideEmoji(BuildContext context) {
    if (!showEmoji.value) {
      focusNode.unfocus();
    } else {
      focusNode.requestFocus();
      return;
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      showEmoji(!showEmoji.value);
    });
  }

  void onUploadDownloadProgressChanged(
      String messageId, String progressPercentage) {
    if (messageId.isNotEmpty) {
      final index =
          chatList.indexWhere((message) => message.messageId == messageId);
      debugPrint(
          "Media Status Onprogress changed---> onUploadDownloadProgressChanged $index $messageId $progressPercentage");
      if (!index.isNegative) {
        // chatMessageModel.isSelected=chatList[index].isSelected;
        // debugPrint("Media Status Onprogress changed---> flutter conversion ${int.parse(progressPercentage)}");
        chatList[index]
            .mediaChatMessage
            ?.mediaProgressStatus(int.parse(progressPercentage));
        // chatList.refresh();
      }
    }
  }
  void cancelNotification() {
    NotificationBuilder.cancelNotification(profile.jid.hashCode);
  }

  void setOnGoingUserGone(){
    Mirrorfly.setOnGoingChatUser(Constants.emptyString);
    SessionManagement.setCurrentChatJID(Constants.emptyString);
  }
  void setOnGoingUserAvail(){
    Mirrorfly.setOnGoingChatUser(profile.jid.checkNull());
    SessionManagement.setCurrentChatJID(profile.jid.checkNull());
    sendReadReceipt();
    cancelNotification();
  }
}
