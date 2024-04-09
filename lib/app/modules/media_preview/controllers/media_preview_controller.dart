import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/model/available_features.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';

import '../../../common/constants.dart';
import '../../../common/main_controller.dart';
import '../../../data/helper.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../gallery_picker/controllers/gallery_picker_controller.dart';
import '../../gallery_picker/src/data/models/picked_asset_model.dart';

class MediaPreviewController extends FullLifeCycleController
    with FullLifeCycleMixin {
  var userName = Constants.emptyString;//Get.arguments['userName'];
  Rx<ProfileDetails> profile = ProfileDetails().obs;//Get.arguments['profile'] as Profile;

  TextEditingController caption = TextEditingController();

  var filePath = <PickedAssetModel>[].obs;

  var captionMessage = <String>[].obs;
  var textMessage = Constants.emptyString;//Get.arguments['caption'];
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

  @override
  void onHidden() {
    // Your implementation here
  }

  void init(List<PickedAssetModel> filePath, String userName, ProfileDetails profile,
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
          captionMessage.add(Constants.emptyString);
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
    captionMessage[currentPageIndex.value] = caption.text.toString();
  }

  sendMedia(BuildContext context) async {
    debugPrint("send media");
    // var previousRoute = Get.previousRoute;
    // if (await AppUtils.isNetConnected()) {
    Platform.isIOS
        ? Helper.showLoading(
        message: AppConstants.compressingFiles, buildContext: context)
        : Helper.progressLoading(context: context);
    var featureNotAvailable = false;
    try {
      int i = 0;
      await Future.forEach(filePath, (data) async {
        debugPrint(data.type);
        if (data.type == 'image') {
          if (!availableFeatures.value.isImageAttachmentAvailable.checkNull()) {
            featureNotAvailable = true;
            return false;
          }
          debugPrint("sending image");
          var response = await Get.find<ChatController>()
              .sendImageMessage(data.path, captionMessage[i], Constants.emptyString, context);
          debugPrint("Preview View ==> $response");
          if (response != null) {
            debugPrint("Image send Success");
          }
        } else if (data.type == 'video') {
          if (!availableFeatures.value.isVideoAttachmentAvailable.checkNull()) {
            featureNotAvailable = true;
            return false;
          }
          debugPrint("sending video");
          var response = await Get.find<ChatController>()
              .sendVideoMessage(data.path!, captionMessage[i], Constants.emptyString, context);
          debugPrint("Preview View ==> $response");
          if (response != null) {
            debugPrint("Video send Success");
          }
        }
        i++;
      });
    } finally {
      if (context.mounted) Helper.hideLoading(context: context);
      if (!featureNotAvailable) {
        if (isFromGalleryPicker) {
          // Get.back();
          if (context.mounted) Navigator.pop(context);
        }
        // Get.back();
        if (context.mounted) Navigator.pop(context);
      } else {
        if (context.mounted) Helper.showFeatureUnavailable(context);
      }
    }
  }

  void deleteMedia() {
    LogMessage.d("currentPageIndex : ",currentPageIndex);
    var provider = Get.find<GalleryPickerController>().provider;
    provider.unPick(currentPageIndex.value);
    filePath.removeAt(currentPageIndex.value);
    captionMessage.removeAt(currentPageIndex.value);
    if(currentPageIndex.value > 0) {
      currentPageIndex(currentPageIndex.value - 1);
      LogMessage.d("currentPageIndex.value.toDouble()", currentPageIndex.value.toDouble());
      pageViewController.animateToPage(currentPageIndex.value, duration: const Duration(milliseconds: 5), curve: Curves.easeInOut);
      caption.text = captionMessage[currentPageIndex.value];
    }else if (currentPageIndex.value == 0){
      caption.text = captionMessage[currentPageIndex.value];
    }
  }

  void onMediaPreviewPageChanged(int value) {
    LogMessage.d("onMediaPreviewPageChanged ",value.toString());
    currentPageIndex(value);
    caption.text = captionMessage[value];
    captionFocusNode.unfocus();
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

  var availableFeatures = Get.find<MainController>().availableFeature;
  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("MediaPreview", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }
}
