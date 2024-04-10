import 'dart:convert';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/model/callback.dart';
import 'package:mirrorfly_plugin/model/status_model.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import '../../../../mirrorfly_uikit_plugin.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import '../../settings/views/chat_settings/chat_settings_controller.dart';

class BusyStatusController extends GetxController with WidgetsBindingObserver {
  final busyStatus = Constants.emptyString.obs;
  var busyStatusList = List<StatusData>.empty(growable: true).obs;
  var selectedStatus = Constants.emptyString.obs;
  var loading = false.obs;

  var addStatusController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count = 139.obs;

  onChanged() {
    count(139 - addStatusController.text.characters.length);
  }

  onEmojiBackPressed() {
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

  onEmojiSelected(Emoji emoji) {
    if (addStatusController.text.characters.length < 139) {
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

  void init(String? status) {
    WidgetsBinding.instance.addObserver(this);
    if (status != null) {
      selectedStatus.value = status;
      addStatusController.text = selectedStatus.value;
    }
    onChanged();
    getMyBusyStatus();
    getMyBusyStatusList();
  }

  void getMyBusyStatus() {
    Mirrorfly.getMyBusyStatus().then((value) {
      var userBusyStatus = json.decode(value);
      debugPrint("Busy Status ${userBusyStatus["status"]}");
      busyStatus(userBusyStatus["status"]);
    });
  }

  void getMyBusyStatusList() {
    loading.value = true;
    Mirrorfly.getBusyStatusList().then((value) {
      debugPrint("status list $value");
      loading.value = false;
      if (value != null) {
        busyStatusList(statusDataFromJson(value));
        busyStatusList.refresh();
      }
    }).catchError((onError) {
      loading.value = false;
    });
  }

  void updateBusyStatus(int position, String status) {
    for (var statusItem in busyStatusList) {
      if (statusItem.status == status) {
        statusItem.isCurrentStatus = true;
        busyStatus(statusItem.status);
      } else {
        statusItem.isCurrentStatus = false;
      }
    }
    busyStatusList.refresh();

    setCurrentStatus(status);
  }

  void deleteBusyStatus(StatusData item, BuildContext context) {
    if (!item.isCurrentStatus!) {
      Helper.showButtonAlert(actions: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 10),
          title: Text(AppConstants.delete,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
          onTap: () {
            // Get.back();
            Navigator.pop(context);
            busyDeleteConfirmation(item, context);
          },
        ),
      ], context: context);
    }
  }

  insertBusyStatus(String newBusyStatus) {
    for (var statusItem in busyStatusList) {
      if (statusItem.status == newBusyStatus) {
        statusItem.isCurrentStatus = true;
        busyStatus(statusItem.status);
        busyStatusList.refresh();
        setCurrentStatus(newBusyStatus);
        return;
      }
    }

    Mirrorfly.insertBusyStatus(busyStatus: newBusyStatus).then((value) {
      busyStatus(newBusyStatus);
      setCurrentStatus(newBusyStatus);
    });
  }

  validateAndFinish(BuildContext context) async {
    if (addStatusController.text.trim().isNotEmpty) {
      Navigator.pop(context, addStatusController.text.trim().toString());
    } else {
      toToast(AppConstants.statusCantEmpty);
    }
  }

  void setCurrentStatus(String status) {
    Mirrorfly.setMyBusyStatus(
        busyStatus: status,
        flyCallBack: (FlyResponse response) {
          debugPrint("status value $response");
          var settingController = Get.find<ChatSettingsController>();
          settingController.busyStatus(status);
          getMyBusyStatusList();
        });
  }

  void busyDeleteConfirmation(StatusData item, BuildContext context) {
    Helper.showAlert(
        message: AppConstants.youWantDeleteStatus,
        actions: [
          TextButton(
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
              },
              child: Text(AppConstants.no,
                  style:
                      TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))),
          TextButton(
              onPressed: () async {
                if (await AppUtils.isNetConnected()) {
                  // Get.back();
                  if (context.mounted) Navigator.pop(context);
                  if (context.mounted)
                    Helper.showLoading(
                        message: AppConstants.deletingBusyStatus,
                        buildContext: context);
                  Mirrorfly.deleteBusyStatus(
                          id: item.id!,
                          status: item.status!,
                          isCurrentStatus: item.isCurrentStatus!)
                      .then((value) {
                    busyStatusList.remove(item);
                    Helper.hideLoading(context: context);
                  }).catchError((error) {
                    Helper.hideLoading(context: context);
                    toToast(AppConstants.unableDeleteBusyStatus);
                  });
                } else {
                  toToast(AppConstants.noInternetConnection);
                }
              },
              child: Text(AppConstants.yes,
                  style:
                      TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))),
        ],
        context: context);
  }

  // @override
  // void onDetached() {
  // }
  //
  // @override
  // void onInactive() {
  // }
  //
  // @override
  // void onPaused() {
  // }

  // @override
  // void onResumed() {
  //   if(!KeyboardVisibilityController().isVisible) {
  //     if (focusNode.hasFocus) {
  //       focusNode.unfocus();
  //       Future.delayed(const Duration(milliseconds: 100), () {
  //         focusNode.requestFocus();
  //       });
  //     }
  //   }
  // }

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // This code will be executed when the app is resumed
      debugPrint('App resumed');
    }
  }

  void close() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
