import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/session_management.dart';

class SettingsController extends GetxController {
  PackageInfo? packageInfo;

  @override
  void onInit() {
    super.onInit();
    getPackageInfo();
  }

  getPackageInfo() async {
    packageInfo.obs.value = await PackageInfo.fromPlatform();
  }

  logout(BuildContext context) {
    // Get.back();
    Navigator.pop(context);
    if (SessionManagement.getEnablePin()) {
      // Get.toNamed(Routes.pin)?.then((value){
      //   if(value!=null && value){
      //     logoutFromSDK(context);
      //   }
      // });
    } else {
      logoutFromSDK(context);
    }
  }

  logoutFromSDK(BuildContext context) async {
    if (await AppUtils.isNetConnected()) {
      if (context.mounted) Helper.progressLoading(context: context);
      Mirrorfly.logoutOfChatSDK(flyCallBack: (response) {
        Helper.hideLoading(context: context);
        if (response.isSuccess) {
          clearAllPreferences();
        } else {
          Get.snackbar("Logout", "Logout Failed");
        }
      }).catchError((er) {
        Helper.hideLoading(context: context);
        SessionManagement.clear().then((value) {
          // SessionManagement.setToken(token);
          // Get.offAllNamed(Routes.login);
        });
      });
    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  void clearAllPreferences() {
    var token = SessionManagement.getToken().checkNull();
    var cameraPermissionAsked =
        SessionManagement.getBool(Constants.cameraPermissionAsked);
    var audioRecordPermissionAsked =
        SessionManagement.getBool(Constants.audioRecordPermissionAsked);
    var readPhoneStatePermissionAsked =
        SessionManagement.getBool(Constants.readPhoneStatePermissionAsked);
    var bluetoothPermissionAsked =
        SessionManagement.getBool(Constants.bluetoothPermissionAsked);
    SessionManagement.clear().then((value) {
      SessionManagement.setToken(token);
      SessionManagement.setBool(
          Constants.cameraPermissionAsked, cameraPermissionAsked);
      SessionManagement.setBool(
          Constants.audioRecordPermissionAsked, audioRecordPermissionAsked);
      SessionManagement.setBool(Constants.readPhoneStatePermissionAsked,
          readPhoneStatePermissionAsked);
      SessionManagement.setBool(
          Constants.bluetoothPermissionAsked, bluetoothPermissionAsked);
    });
  }

/*  getReleaseDate() async {
    var releaseDate = "Nov";
    String pathToYaml =
        join(dirname(Platform.script.toFilePath()), '../pubspec.yaml');
    File file = File(pathToYaml);
    file.readAsString().then((String content) {
      Map yaml = loadYaml(content);
      debugPrint(yaml['build_release_date']);
      releaseDate = yaml['build_release_date'];
    });
    return releaseDate;
  }*/
}
