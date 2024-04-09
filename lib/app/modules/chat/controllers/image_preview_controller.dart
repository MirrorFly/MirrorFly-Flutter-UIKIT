import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import 'chat_controller.dart';

class ImagePreviewController extends GetxController {
  // var filePath = Get.arguments['filePath'];
  var userName = Get.arguments['userName'];

  TextEditingController caption = TextEditingController();

  var filePath = Constants.emptyString.obs;

  var textMessage = Constants.emptyString;

  @override
  void onInit() {
    super.onInit();

    textMessage = Get.arguments['caption'];
    // debugPrint("caption text received--> $textMessage");
    caption.text = textMessage;
    SchedulerBinding.instance
        .addPostFrameCallback((_) => filePath(Get.arguments['filePath']));
  }

  sendImageMessage(BuildContext context) async {
    if (File(filePath.value).existsSync()) {
      // if(await AppUtils.isNetConnected()) {
      var response = await Get.find<ChatController>().sendImageMessage(
          filePath.value, caption.text, Constants.emptyString, context);
      // debugPrint("Preview View ==> $response");
      if (response != null) {
        // Get.back();
        Navigator.pop(context);
      }
      // }else{
      //   toToast(AppConstants.noInternetConnection);
      // }
    } else {
      debugPrint("File Not Found For Image Upload");
    }
  }
}
