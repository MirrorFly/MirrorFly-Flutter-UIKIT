import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/view_all_media_preview/views/view_all_media_preview_view.dart';
import '../../../models.dart';

import '../../../common/constants.dart';
import '../../chat/controllers/chat_controller.dart';

class ViewAllMediaController extends GetxController {
  final _medialist = <String, List<MessageItem>>{}.obs;
  set medialist(Map<String, List<MessageItem>> value) =>
      _medialist.value = value;
  Map<String, List<MessageItem>> get medialistdata => _medialist;

  final _docslist = <String, List<MessageItem>>{}.obs;
  set docslist(Map<String, List<MessageItem>> value) => _docslist.value = value;
  Map<String, List<MessageItem>> get docslistdata => _docslist;

  final _linklist = <String, List<MessageItem>>{}.obs;
  set linklist(Map<String, List<MessageItem>> value) => _linklist.value = value;
  Map<String, List<MessageItem>> get linklistdata => _linklist;

  var name = Constants.emptyString;
  var jid = Constants.emptyString;
  var isGroup = false;

  var imageCount = 0.obs;
  var audioCount = 0.obs;
  var videoCount = 0.obs;
  var documentCount = 0.obs;
  var linkCount = 0.obs;
  var previewMediaList = List<ChatMessageModel>.empty(growable: true).obs;
  var newLinkMessages = List<ChatMessageModel>.empty(growable: true).obs;

  void init(String name, String jid, bool isGroup) {
    this.name = name;
    this.jid = jid;
    this.isGroup = isGroup;

    getMediaMessages();
    getDocsMessages();
    getLinkMessages();

    _medialist.bindStream(_medialist.stream);
    ever(_medialist, (callback) {
      mirrorFlyLog("media list", medialistdata.length.toString());
    });
    _docslist.bindStream(_docslist.stream);
    ever(_docslist, (callback) {
      mirrorFlyLog("docs list", docslistdata.length.toString());
    });
    _linklist.bindStream(_linklist.stream);
    ever(_linklist, (callback) {
      mirrorFlyLog("link list", linklistdata.length.toString());
    });
  }

  void onMessageReceived(ChatMessageModel chatMessageModel) {
    mirrorFlyLog("View All Media Controller", "onMessageReceived");
    getLinkMessages();
  }

  void onMediaStatusUpdated(ChatMessageModel chatMessageModel) {
    if (chatMessageModel.isFileMessage()) {
      getDocsMessages();
    } else {
      getMediaMessages();
    }
  }

  getMediaMessages() {
    Mirrorfly.getMediaMessages(jid: jid).then((value) async {
      if (value != null) {
        var data = chatMessageModelFromJson(value);
        /*previewMediaList.clear();
        previewMediaList.addAll(data);
        imageCount(previewMediaList.where((chatItem) => chatItem.isImageMessage()).toList().length);
        videoCount(previewMediaList.where((chatItem) => chatItem.isVideoMessage()).toList().length);
        audioCount(previewMediaList.where((chatItem) => chatItem.isAudioMessage()).toList().length);
        if (data.isNotEmpty) {
          _medialist(await getMapGroupedMediaList(data, true));
          // debugPrint("_media list length--> ${_medialist.length}");
        }*/
        previewMediaList(data);
        if (data.isNotEmpty) {
          _medialist(await getMapGroupedMediaList(data, true));
          imageCount(0);
          videoCount(0);
          audioCount(0);
          medialistdata.forEach((key, List<MessageItem> value) {
            var imgCount = value
                .where((MessageItem chatItem) =>
                    chatItem.chatMessage.isImageMessage())
                .toList()
                .length;
            imageCount(imageCount.value + imgCount);
            var vidCount = value
                .where((MessageItem chatItem) =>
                    chatItem.chatMessage.isVideoMessage())
                .toList()
                .length;
            videoCount(videoCount.value + vidCount);
            var adiCount = value
                .where((MessageItem chatItem) =>
                    chatItem.chatMessage.isAudioMessage())
                .toList()
                .length;
            audioCount(audioCount.value + adiCount);
          });
          // debugPrint("_media list length--> ${_medialist.length}");
        }
      }
    });
  }

  //getDocsMessages
  getDocsMessages() {
    Mirrorfly.getDocsMessages(jid: jid).then((value) async {
      if (value != null) {
        var data = chatMessageModelFromJson(value);
        documentCount(data.length);
        if (data.isNotEmpty) {
          _docslist(await getMapGroupedMediaList(data, false));
        }
      }
    });
  }

  //getLinkMessages
  getLinkMessages() {
    Mirrorfly.getLinkMessages(jid: jid).then((value) async {
      if (value != null) {
        var data = chatMessageModelFromJson(value);
        linkCount(data.length);
        if (data.isNotEmpty) {
          _linklist(await getMapGroupedMediaList(data, false, true));
        }
      }
    });
  }

  navigateMessage(ChatMessageModel linkChatItem, BuildContext context) {
    // Get.toNamed(Routes.chat,parameters: {'isFromStarred':'true',"userJid":linkChatItem.chatUserJid,"messageId":linkChatItem.messageId});
    // Get.back();
    // Get.back();
    Navigator.pop(context);
    Navigator.pop(context);
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().navigateToMessage(linkChatItem);
    }
  }

  Future<Map<String, List<MessageItem>>> getMapGroupedMediaList(
      List<ChatMessageModel> mediaMessages, bool isMedia,
      [bool isLinkMedia = false]) async {
    // debugPrint("media message length--> ${mediaMessages.length}");
    var calendarInstance = DateTime.now();
    var currentYear = calendarInstance.year;
    var currentMonth = calendarInstance.month;
    var currentDay = calendarInstance.day;
    var dateSymbols = DateFormat().dateSymbols.STANDALONEMONTHS;
    int year;
    int month;
    int day;
    //var viewAllMediaList = <GroupedMedia>[];
    Map<String, List<MessageItem>> mapMediaList = {};
    var previousCategoryType = 10;
    var messages = <MessageItem>[];
    for (var chatMessage in mediaMessages) {
      var date = chatMessage.messageSentTime.toInt();
      var calendar = DateTime.fromMicrosecondsSinceEpoch(date);
      year = calendar.year;
      month = calendar.month;
      day = calendar.day;

      var category = getCategoryName(
          dateSymbols, currentDay, currentMonth, currentYear, day, month, year);

      // debugPrint("getMapGroupedMediaList category--> $category");
      if (isLinkMedia) {
        if (previousCategoryType != category.key) {
          messages = [];
        }
        previousCategoryType = category.key;
        mapMediaList[category.value] =
            getMapMessageWithURLList(messages, chatMessage);
      } else {
        if (!chatMessage.isMessageRecalled.value &&
            (chatMessage.isMediaDownloaded() ||
                chatMessage.isMediaUploaded()) &&
            await isMediaAvailable(chatMessage, isMedia)) {
          if (previousCategoryType != category.key) {
            messages = [];
          }
          messages.add(MessageItem(chatMessage));
          mapMediaList[category.value] = messages;
          previousCategoryType = category.key;
        } else {
          debugPrint("getMapGroupedMediaList isMediaAvailable --> false");
        }
      }
    }
    return mapMediaList;
  }

  List<MessageItem> getMapMessageWithURLList(
      List<MessageItem> messageList, ChatMessageModel message) {
    var textContent = Constants.emptyString;
    if (message.isTextMessage()) {
      textContent = message.messageTextContent!;
    } else if (message.isImageMessage()) {
      textContent = message.mediaChatMessage!.mediaCaptionText;
    } else {
      textContent = Constants.emptyString;
    }
    if (textContent.isNotEmpty) {
      getUrlAndHostList(textContent).forEach((it) {
        var map = {};
        map["host"] = it.key;
        map["url"] = it.value;
        messageList.add(MessageItem(message, map));
        mirrorFlyLog("link msg", map.toString());
      });
    }
    return messageList;
  }

  List<MapEntry<String, String>> getUrlAndHostList(String text) {
    RegExp exp = RegExp("\\s+");
    var urls = <MapEntry<String, String>>[];
    var splitString = text.split(exp);
    for (var string in splitString) {
      try {
        var item = Uri.parse(string);
        if (item.host.isNotEmpty) {
          urls.add(MapEntry(item.host, item.toString()));
        }
      } catch (ignored) {
        mirrorFlyLog('$string url exception', ignored.toString());
      }
    }
    mirrorFlyLog("urls", urls.toString());
    return urls;
  }

  Future<bool> isMediaAvailable(
      ChatMessageModel chatMessage, bool isMedia) async {
    var mediaExist = await isMediaExists(
        chatMessage.mediaChatMessage!.mediaLocalStoragePath.value);
    return (!isMedia || mediaExist);
  }

  Future<bool> isMediaExists(String filePath) async {
    io.File file = io.File(filePath);
    var fileExists = file.absolute.existsSync();
    debugPrint("file exists---> ${fileExists.toString()}");
    var fileExists1 = File(filePath).existsSync() ||
        Directory(filePath).existsSync() ||
        Link(filePath).existsSync();
    debugPrint("file exists1---> ${fileExists1.toString()}");
    return await io.File(filePath).absolute.exists();
  }

  MapEntry<int, String> getCategoryName(
      List<String> dateSymbols,
      int currentDay,
      int currentMonth,
      int currentYear,
      int day,
      int month,
      int year) {
    if ((currentYear - year) == 1) {
      if (currentMonth < month) {
        return MapEntry(4, dateSymbols[month]);
      }
    } else if ((currentYear > year)) {
      return MapEntry(5, year.toString());
    } else if ((currentMonth - month) == 1) {
      if (day > currentDay) {
        return MapEntry(3, AppConstants.lastMonth);
      } else {
        return MapEntry(4, dateSymbols[month]);
      }
    } else if (currentMonth > month) {
      return MapEntry(4, dateSymbols[month]);
    } else if ((currentDay - day) > 7) {
      return MapEntry(2, AppConstants.lastMonth);
    } else if ((currentDay - day) > 2) {
      return MapEntry(1, AppConstants.lastWeek);
    }
    return MapEntry(0, AppConstants.recent);
  }

  Image imageFromBase64String(
      String base64String, double? width, double? height) {
    var decodedBase64 = base64String.replaceAll("\n", Constants.emptyString);
    Uint8List image = const Base64Decoder().convert(decodedBase64);
    return Image.memory(
      image,
      key: ValueKey<String>(base64String),
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }

  openFile(String path) async {
    openDocument(path);
  }

  openImage(BuildContext context, int gridIndex) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (con) => ViewAllMediaPreviewView(
                images: previewMediaList, index: gridIndex)));
    // Get.toNamed(Routes.viewAllMediaPreview, arguments: {"images" : previewMediaList, "index": gridIndex});
  }
}
