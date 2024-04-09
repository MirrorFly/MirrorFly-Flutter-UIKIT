import 'dart:convert';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/model/status_model.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import 'package:mirrorfly_plugin/flychat.dart';

class StatusListController extends FullLifeCycleController with FullLifeCycleMixin{
  var statusList = List<StatusData>.empty(growable: true).obs;
  var selectedStatus = "".obs;
  var loading =false.obs;

  //add new status
  var addStatusController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count= 139.obs;

  onChanged(){
    count(139 - addStatusController.text.characters.length);
  }

  onEmojiBackPressed(){
    var text = addStatusController.text;
    var cursorPosition = addStatusController.selection.base.offset;

    // If cursor is not set, then place it at the end of the textfield
    if (cursorPosition < 0) {
      addStatusController.selection = TextSelection(
        baseOffset: addStatusController.text.length,
        extentOffset: addStatusController.text.length,
      );
      cursorPosition = addStatusController.selection.base.offset;
    }

    if (cursorPosition >= 0) {
      final selection = addStatusController.value.selection;
      final newTextBeforeCursor =
      selection.textBefore(text).characters.skipLast(1).toString();
      LogMessage.d("newTextBeforeCursor", newTextBeforeCursor);
      addStatusController
        ..text = newTextBeforeCursor + selection.textAfter(text)
        ..selection = TextSelection.fromPosition(
            TextPosition(offset: newTextBeforeCursor.length));
    }
    count((139 - addStatusController.text.characters.length));
  }

  onEmojiSelected(Emoji emoji){
    if(addStatusController.text.characters.length < 139){
      final controller = addStatusController;
      final text = controller.text;
      final selection = controller.selection;
      final cursorPosition = controller.selection.base.offset;

      if (cursorPosition < 0) {
        controller.text += emoji.emoji;
        // widget.onEmojiSelected?.call(category, emoji);
        return;
      }

      final newText =
      text.replaceRange(selection.start, selection.end, emoji.emoji);
      final emojiLength = emoji.emoji.length;
      controller
        ..text = newText
        ..selection = selection.copyWith(
          baseOffset: selection.start + emojiLength,
          extentOffset: selection.start + emojiLength,
        );
    }
    count((139 - addStatusController.text.characters.length));
  }


  void init(String status) {
    selectedStatus.value = status;
    addStatusController.text = selectedStatus.value;
    // onChanged();
    getStatusList();
    onChanged();
  }

  getStatusList(){
    loading.value=true;
    Mirrorfly.getProfileStatusList().then((value){
      loading.value=false;
      if(value!=null){
        statusList.clear();
        statusList.value = statusDataFromJson(value);
        statusList.refresh();

      }
    }).catchError((onError){
      loading.value=false;
    });
  }

  updateStatus(BuildContext context, [String? statusText, String? statusId]) async {
    debugPrint("updating item details--> $statusId");
    if(await AppUtils.isNetConnected()) {
      if(context.mounted)Helper.showLoading(buildContext: context);
      Mirrorfly.setMyProfileStatus(status: statusText!, statusId: statusId!, flyCallBack: (response){
        if(response.isSuccess) {
          selectedStatus.value = statusText;
          addStatusController.text = statusText;
          var data = json.decode(response.data);
          toToast(AppConstants.statusUpdated);
          Navigator.pop(context);
          if (data['status']) {
            getStatusList();
          }
        }
      });
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  insertStatus(BuildContext context) async{
    if(await AppUtils.isNetConnected()){
      if(context.mounted)Helper.showLoading(buildContext: context);
        Mirrorfly.insertNewProfileStatus(status: addStatusController.text.trim().toString())
            .then((value) {
          selectedStatus.value = addStatusController.text.trim().toString();
          addStatusController.text = addStatusController.text.trim().toString();
          // var data = json.decode(value.toString());
          toToast(AppConstants.statusUpdated);
          // Helper.hideLoading();
          Navigator.pop(context);
          if (value.checkNull()) {
            getStatusList();
          }
        }).catchError((er) {
          toToast(er);
        });
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  validateAndFinish(BuildContext context)async{
    if(addStatusController.text.trim().isNotEmpty) {
      if(await AppUtils.isNetConnected()) {
        // Get.back(result: addStatusController.text
        //     .trim().toString());
        if (context.mounted) Navigator.pop(context, addStatusController.text.trim().toString());
      }else{
        toToast(AppConstants.noInternetConnection);
        // Get.back();
        if (context.mounted) Navigator.pop(context);
      }
    }else{
      toToast(AppConstants.statusCantEmpty);
    }
  }

  @override
  void onDetached() {
  }

  @override
  void onInactive() {
  }

  @override
  void onPaused() {
  }

  @override
  void onResumed() {
    if(!KeyboardVisibilityController().isVisible) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
      }
    }
  }

  void deleteStatus(StatusData item, BuildContext context) {
    debugPrint("item delete status-->${item.isCurrentStatus}");
    debugPrint("item delete status-->${item.id}");
    debugPrint("item delete status-->${item.status}");
    if(!item.isCurrentStatus!){
      Helper.showButtonAlert(actions: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 10),
          title: Text(AppConstants.delete,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal)),

          onTap: () {
            Navigator.pop(context);
            Future.delayed(const Duration(milliseconds: 10), ()
            {
              statusDeleteConfirmation(item, context);
            });

          },
        ),
      ], context: context);
    }
  }

  void statusDeleteConfirmation(StatusData item, BuildContext context) {
    Helper.showAlert(message: AppConstants.deleteStatus, actions: [
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
          },
          child: Text(AppConstants.no)),
      TextButton(
          onPressed: () async {
            if (await AppUtils.isNetConnected()) {
              // Get.back();
              if(context.mounted) Navigator.pop(context);
              if(context.mounted)Helper.showLoading(message: AppConstants.deletingStatus, buildContext: context);
              Mirrorfly.deleteProfileStatus(id: item.id!, status: item.status!, isCurrentStatus: item.isCurrentStatus!)
                  .then((value) {
                statusList.remove(item);
                // Helper.hideLoading();
                Navigator.pop(context);
              }).catchError((error) {
                // Helper.hideLoading();
                Navigator.pop(context);
                toToast(AppConstants.unableToDeleteProfileStatus);
              });
            } else {
              toToast(AppConstants.noInternetConnection);
            }
          },
          child: Text(AppConstants.yes)),
    ], context: context);
  }

  @override
  void onHidden() {
    // Your implementation here
  }

  onBackPressed(BuildContext context, [String? result]) {
    debugPrint("result $result");
    showEmoji(false);
    addStatusController.text = selectedStatus.value;
    if(result != null){
      Navigator.pop(context,result);
      // Get.back(result: result);
    }else {
      Navigator.pop(context);
      // Get.back();
    }
  }

}