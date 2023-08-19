import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/AppConstants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

import '../../../../data/apputils.dart';
import '../../../../data/helper.dart';
import '../../../../data/permissions.dart';

class ChatSettingsController extends GetxController {

  final _archiveEnabled = false.obs;
  final lastSeenPreference = false.obs;
  final busyStatusPreference = false.obs;
  final busyStatus = Constants.emptyString.obs;
  bool get archiveEnabled => _archiveEnabled.value;

  final _autoDownloadEnabled = false.obs;
  bool get autoDownloadEnabled => _autoDownloadEnabled.value;

  final _translationEnabled = false.obs;
  bool get translationEnabled => _translationEnabled.value;

  final _translationLanguage = "English".obs;
  String get translationLanguage => _translationLanguage.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    getArchivedSettingsEnabled();
    _translationEnabled(SessionManagement.isGoogleTranslationEnable());
    _translationLanguage(SessionManagement.getTranslationLanguage());
    _autoDownloadEnabled(await Mirrorfly.getMediaAutoDownload());
    getLastSeenSettingsEnabled();
    getBusyStatusPreference();
    getMyBusyStatus();

  }
  Future<void> getArchivedSettingsEnabled() async {
    await Mirrorfly.isArchivedSettingsEnabled().then((value) => _archiveEnabled(value));

  }

  Future<void> getLastSeenSettingsEnabled() async {
    // boolean lastSeenStatus = FlyCore.isHideLastSeenEnabled();
    await Mirrorfly.isHideLastSeenEnabled().then((value) => lastSeenPreference(value));
  }


  void enableArchive() async{
    if(await AppUtils.isNetConnected()) {
      Mirrorfly.enableDisableArchivedSettings(!archiveEnabled);
      _archiveEnabled(!archiveEnabled);
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  Future<void> enableDisableAutoDownload(BuildContext context) async {
    AppPermission.getStoragePermission(context).then((value) {
      if(value){
      // if (await askStoragePermission(context)) {
        var enable = !_autoDownloadEnabled.value;//SessionManagement.isAutoDownloadEnable();
        Mirrorfly.setMediaAutoDownload(enable);
        _autoDownloadEnabled(enable);
      }
    });
  }

  Future<void> enableDisableTranslate() async {
    //if (await AppUtils.isNetConnected() && SessionManagement.isGoogleTranslationEnable()) {
    var enable = !SessionManagement.isGoogleTranslationEnable();
      SessionManagement.setGoogleTranslationEnable(enable);
      _translationEnabled(enable);
    /*}else{
      toToast(AppConstants.noInternetConnection);
    }*/
  }

  void chooseLanguage(){
    /*Get.toNamed(Routes.languages,arguments: translationLanguage)?.then((value){
      if(value!=null){
        var language = value as String;
        _translationLanguage(language);
      }
    });*/
  }

  void clearAllConversation(BuildContext context){
    Helper.showAlert(message: AppConstants.areYouClearAllChat,actions: [
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
          },
          child: Text(AppConstants.no.toUpperCase(), style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
            clearAllConv();
          },
          child: Text(AppConstants.yes.toUpperCase(), style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
    ], context: context);
  }

  Future<void> clearAllConv() async {
    if (await AppUtils.isNetConnected()) {
      var result = await Mirrorfly.clearAllConversation();
      if(result.checkNull()){
        toToast(AppConstants.allChatsCleared);
      }else{
        toToast(AppConstants.serverError);
      }
    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  lastSeenEnableDisable() async{
    if(await AppUtils.isNetConnected()) {
      Mirrorfly.enableDisableHideLastSeen(!lastSeenPreference.value).then((value) {
        debugPrint("enableDisableHideLastSeen--> $value");
        if(value != null && value) {
          lastSeenPreference(!lastSeenPreference.value);
        }
      });
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  busyStatusEnable() async {
    bool busyStatusVal = !busyStatusPreference.value;
    debugPrint("busy_status_val ${busyStatusVal.toString()}");
    busyStatusPreference(busyStatusVal);
    await Mirrorfly.enableDisableBusyStatus(busyStatusVal).then((value) => getMyBusyStatus());
  }

  void getMyBusyStatus() {
    Mirrorfly.getMyBusyStatus().then((value) {
      var userBusyStatus = json.decode(value);
      debugPrint("Busy Status ${userBusyStatus["status"]}");
      // var busyStatus = userBusyStatus["status"];
      // if(busyStatus)
      busyStatus(userBusyStatus["status"]);

    });
  }

  Future<void> getBusyStatusPreference() async {
    bool? busyStatusPref = await Mirrorfly.isBusyStatusEnabled();
    busyStatusPreference(busyStatusPref);
    debugPrint("busyStatusPref ${busyStatusPref.toString()}");
  }
}