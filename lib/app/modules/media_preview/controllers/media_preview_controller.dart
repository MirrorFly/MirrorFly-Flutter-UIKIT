import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../../models.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../chat/controllers/chat_controller.dart';

class MediaPreviewController extends FullLifeCycleController
    with FullLifeCycleMixin {
  var userName = "";//Get.arguments['userName'];
  Rx<Profile> profile = Profile().obs;//Get.arguments['profile'] as Profile;

  TextEditingController caption = TextEditingController();

  var filePath = [].obs;

  var captionMessage = <String>[].obs;
  var textMessage = "";//Get.arguments['caption'];
  var showAdd = true;
  var currentPageIndex = 0.obs;
  var isFocused = false.obs;
  var showEmoji = false.obs;
  late bool isFromGalleryPicker;

  FocusNode captionFocusNode = FocusNode();
  PageController pageViewController =
      PageController(initialPage: 0, keepPage: false);

  /*@override
  void onInit() {
    super.onInit();

  }*/

  void init(List filePath, String userName, Profile profile,
      String textMessage, bool showAdd, bool isFromGalleryPicker) {
    this.userName= userName;
    this.profile(profile);
    this.filePath(filePath);
    this.textMessage= textMessage;
    this.showAdd= showAdd;
    this.isFromGalleryPicker = isFromGalleryPicker;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // filePath(Get.arguments['filePath']);
      var index = 0;
      for (var _ in filePath) {
        if (index == 0) {
          captionMessage.add(textMessage);
          index = index + 1;
        } else {
          captionMessage.add("");
        }
      }
    });
    caption.text = textMessage;
    captionFocusNode.addListener(() {
      if (captionFocusNode.hasFocus) {
        showEmoji(false);
      }
    });
  }

  onChanged() {
    // count(139 - addStatusController.text.length);
  }

  sendMedia(BuildContext context) async {
    debugPrint("send media");
    // var previousRoute = Get.previousRoute;
    // if (await AppUtils.isNetConnected()) {
    try {
      int i = 0;
      Platform.isIOS
          ? Helper.showLoading(
              message: "Compressing files", buildContext: context)
          : null;
      for (var data in filePath) {
        /// show image
        debugPrint(data.type);
        if (data.type == 'image') {
          debugPrint("sending image");
          var response = await Get.find<ChatController>()
              .sendImageMessage(data.path, captionMessage[i], "", context);
          debugPrint("Preview View ==> $response");
          if (response != null) {
            debugPrint("Image send Success");
          }
        } else if (data.type == 'video') {
          debugPrint("sending video");
          var response = await Get.find<ChatController>()
              .sendVideoMessage(data.path, captionMessage[i], "", context);
          debugPrint("Preview View ==> $response");
          if (response != null) {
            debugPrint("Video send Success");
          }
        }
        i++;
      }
    } finally {
      Platform.isIOS ? Helper.hideLoading(context: context) : null;
      if (isFromGalleryPicker) {
        // Get.back();
        Navigator.pop(context);
      }
      // Get.back();
      Navigator.pop(context);
    }
    // Get.back();
    /*} else {
      toToast(Constants.noInternetConnection);
    }*/
    // debugPrint("caption text-> $captionMessage");
  }

  void deleteMedia() {
    filePath.removeAt(currentPageIndex.value);
    captionMessage.removeAt(currentPageIndex.value);
    // captionMessage.refresh();
    // filePath.refresh();
    caption.text = captionMessage[currentPageIndex.value];
  }

  void onCaptionTyped(String value) {
    debugPrint("length--> ${captionMessage.length}");
    captionMessage[currentPageIndex.value] = value;
  }

  @override
  void onPaused() {}

  @override
  void onResumed() {
    mirrorFlyLog("LifeCycle", "onResumed");
    if (!KeyboardVisibilityController().isVisible) {
      if (captionFocusNode.hasFocus) {
        captionFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          captionFocusNode.requestFocus();
        });
      }
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}
}
