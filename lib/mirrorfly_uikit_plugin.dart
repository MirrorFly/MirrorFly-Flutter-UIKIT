
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/model/callback.dart';
import 'package:mirrorfly_plugin/model/register_model.dart';
import 'package:mirrorfly_uikit_plugin/app/extensions/extensions.dart';

import 'app/common/main_controller.dart';

import 'app/data/helper.dart';
import 'app/data/session_management.dart';
import 'app/model/reply_hash_map.dart';
import 'app/modules/chat/views/chat_view.dart';
import 'mirrorfly_uikit_plugin_platform_interface.dart';

class MirrorflyUikit {
  bool isTrialLicenceKey = true;
  bool showMobileNumberOnList = true;
  bool showStatusOption = true;
  bool enableLocalNotification = true;
  String googleMapKey = '';
  static bool isSDKInitialized = false;
  static String theme = "light";

  static var instance = MirrorflyUikit();

  static Future<String?> getPlatformVersion() {
    return MirrorflyUikitPluginPlatform.instance.getPlatformVersion();
  }

  ///Used as a initUIKIT class for [MirrorflyUikit]
  /// * [baseUrl] provide the base url for making api calls
  /// * [licenseKey] provide the License Key
  /// * [googleMapKey] provide the googleMap Key for location messages
  /// * [iOSContainerID] provide the App Group of the iOS Project
  /// * [isTrialLicenceKey] to provide trial/live register and contact sync
  /// * [showMobileNumberOnList] to show mobile on contact list
  /// * [storageFolderName] provide the Local Storage Folder Name
  @Deprecated('Instead of use initialize() method')
  initUIKIT(
      {required baseUrl,
      required String licenseKey,
      String? googleMapKey,
      required String iOSContainerID,
      String? storageFolderName,
      bool isTrialLicenceKey = true,
        bool showMobileNumberOnList = true,
        bool showStatusOption = true,
        bool enableLocalNotification = true}) async {
    Mirrorfly.init(
        baseUrl: baseUrl,
        licenseKey: licenseKey,
        iOSContainerID: iOSContainerID,
        storageFolderName: storageFolderName,
        enableMobileNumberLogin: true,
        isTrialLicenceKey: isTrialLicenceKey,
        chatHistoryEnable: false,
        enableDebugLog: true);
    isSDKInitialized = true;
    this.isTrialLicenceKey = isTrialLicenceKey;
    this.showMobileNumberOnList = showMobileNumberOnList;
    this.showStatusOption = showStatusOption;
    this.enableLocalNotification = enableLocalNotification;
    this.googleMapKey = googleMapKey ?? '';
    ReplyHashMap.init();

    SessionManagement.onInit().then((value) {
      Get.put<MainController>(MainController());
    });
  }

  ///Used as a register class for [MirrorflyUikit]
  ///
  ///* [userIdentifier] provide the Unique Id to Register the User
  ///* [fcmToken] provide the FCM token this is an optional
  ///sample response {'status': true, 'message': 'Register Success};
  @Deprecated('Instead of use login() method')
  static Future<Map> registerUser({required String userIdentifier,
      String fcmToken = ""}) async {
    if (!isSDKInitialized) {
      return setResponse(false, 'SDK Not Initialized');
    }
    // if (await AppUtils.isNetConnected()) {
    await Mirrorfly.registerUser(userIdentifier: userIdentifier, fcmToken: fcmToken, flyCallback: (FlyResponse response) {
        if (response.isSuccess) {
          if (response.hasData) {
            var userData = registerModelFromJson(response.data);
            if (userData.data != null) {
              SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
              SessionManagement.setUser(userData.data!);
              Mirrorfly.enableDisableArchivedSettings(enable: true, flyCallBack: (FlyResponse response) {  });
              SessionManagement.setUserIdentifier(userIdentifier);
              // Mirrorfly.setRegionCode(regionCode ?? 'IN');///if its not set then error comes in contact sync delete from phonebook.
              // SessionManagement.setCountryCode((countryCode ?? "").replaceAll('+', ''));
              // await _setUserJID(userData.data!.username!);
              return setResponse(true, 'Register Success');
            } else {
              return setResponse(false, userData.message.toString());
            }
          }else{
            return Future.value(
                setResponse(false, 'Registration Failed'));
          }
        }else{
          if (response.exception?.code == "403") {
            debugPrint("issue 403 ===> ${response.errorMessage }");
            // NavUtils.offAllNamed(Routes.adminBlocked);
            return Future.value(
                setResponse(false, 'Admin Blocked'));
          } else if (response.exception?.code  == "405") {
            debugPrint("issue 405 ===> ${response.errorMessage }");
            // sessionExpiredDialogShow(getTranslated("maximumLoginReached"));
            return Future.value(
                setResponse(false, 'Max User Reached'));
          } else {
            debugPrint("issue else code ===> ${response.exception?.code }");
            debugPrint("issue else ===> ${response.errorMessage }");
            // toToast(getErrorDetails(response));
            return Future.value(
                setResponse(false, getErrorDetails(response)));
          }

        }
      });
    return Future.value(setResponse(false, 'Unexpected error occurred'));
  }

  ///Used as a register class for [MirrorflyUikit]
  ///Use this Method to logout from our UIkit
  ///this will clear all the chat data.
  ///sample response {'status': true, 'message': 'Logout successfully};
  @Deprecated('Instead of use logout() method')
  static Future<Map<String, dynamic>> logoutFromUIKIT() async {
    try {
      await Mirrorfly.logoutOfChatSDK(flyCallBack: (FlyResponse response) {
        if (response.isSuccess) {
          var token = SessionManagement.getToken().checkNull();
          SessionManagement.clear().then((value) {
            SessionManagement.setToken(token);
          });
          return setResponse(true, 'Logout successfully');
        } else {
          return setResponse(false, 'Logout Failed');
        }
      });
      return setResponse(false, 'Logout Failed');
    } catch (e) {
      return setResponse(false, 'Logout Failed');
    }
  }

  static Map<String, dynamic> setResponse(bool status, String message) {
    return {'status': status, 'message': message};
  }

  // static _setUserJID(String username) async {
  //   Mirrorfly.getAllGroups(flyCallBack: (FlyResponse response) {  });
  //   await Mirrorfly.getJid(username: username).then((value) {
  //     if (value != null) {
  //       SessionManagement.setUserJID(value);
  //     }
  //   }).catchError((error) {});
  // }

  static ChatView chatPage() {
    // Get.put<ChatController>(ChatController());
    // return ChatView(
    //   jid: "",
    //   showChatDeliveryIndicator: false,
    // );
    return ChatView();
  }
}
