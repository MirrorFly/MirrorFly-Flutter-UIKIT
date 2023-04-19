
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';

import 'app/common/main_controller.dart';
import 'app/data/apputils.dart';
import 'app/data/session_management.dart';
import 'app/model/register_model.dart';
import 'app/modules/chat/controllers/chat_controller.dart';
import 'app/modules/chat/views/chat_view.dart';
import 'mirrorfly_uikit_plugin_platform_interface.dart';

class MirrorflyUikit {

  static Future<String?> getPlatformVersion() {
    return MirrorflyUikitPluginPlatform.instance.getPlatformVersion();
  }
  static chatUIKIT({required String baseUrl,
    required String licenseKey,
    required String iOSContainerID,
    String? storageFolderName,
    bool enableMobileNumberLogin = true,
    bool isTrialLicenceKey = true,
    // int? maximumRecentChatPin,
    // GroupConfig? groupConfig,
    // String? ivKey,
    bool enableDebugLog = false}){
    Mirrorfly.init(
        baseUrl: baseUrl,
        licenseKey: licenseKey,//ckIjaccWBoMNvxdbql8LJ2dmKqT5bp//2sdgNtr3sFBSM3bYRa7RKDPEiB38Xo
        iOSContainerID: iOSContainerID,storageFolderName: storageFolderName,enableMobileNumberLogin: enableMobileNumberLogin,isTrialLicenceKey: isTrialLicenceKey,enableDebugLog: enableDebugLog);
    SessionManagement.onInit().then((value) {
      SessionManagement.setIsTrailLicence(isTrialLicenceKey);
      Get.put<MainController>(MainController());
      if(!SessionManagement.getLogin()) {
        // register('919894940560', token: '');
      }
    });

  }

  static Future<bool> register(String userIdentifier,
      {String token = ""}) async {
    bool response = false;
    if(!SessionManagement.getLogin()) {
      // Mirrorfly.registerUser(userIdentifier,token: token);
      /*Mirrorfly.registerUser(
          userIdentifier, token: SessionManagement.getToken() ?? "")
          .then((value) {
        mirrorFlyLog("registerUser", value);
        if (value.contains("data")) {
          var userData = registerModelFromJson(value); //message
          SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
          SessionManagement.setUser(userData.data!);
          // if(AppUtils.isNetConnected()) {
          Mirrorfly.enableDisableArchivedSettings(true);
          // }
          // Mirrorfly.setRegionCode(regionCode ?? 'IN');///if its not set then error comes in contact sync delete from phonebook.
          // SessionManagement.setCountryCode((countryCode ?? "").replaceAll('+', ''));
          _setUserJID(userData.data!.username!);
          return response;
        }
      }).catchError((error) {
        mirrorFlyLog("issue===>", error);
      //   if(error.code == 403){
      //   Get.offAllNamed(Routes.adminBlocked);
      // }else{
      //   toToast(error.message);
      // }
        return response;
      });*/
      var value  = await Mirrorfly.registerUser(userIdentifier,token: token);
      if (value.contains("data")) {
        var userData = registerModelFromJson(value); //message
        SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
        SessionManagement.setUser(userData.data!);
        // if(AppUtils.isNetConnected()) {
        Mirrorfly.enableDisableArchivedSettings(true);
        // }
        // Mirrorfly.setRegionCode(regionCode ?? 'IN');///if its not set then error comes in contact sync delete from phonebook.
        // SessionManagement.setCountryCode((countryCode ?? "").replaceAll('+', ''));
        _setUserJID(userData.data!.username!);
        return response;
      }else{
        return response;
      }
    }else{
      return Future.value(false);
    }
  }
  static _setUserJID(String username) {
    Mirrorfly.getAllGroups(true);
    Mirrorfly.getJid(username).then((value) {
      if (value != null) {
        SessionManagement.setUserJID(value);
      }
    }).catchError((error) {
    });
  }

  static ChatView chatPage(){
    Get.put<ChatController>(ChatController());
    return const ChatView();
  }
}
