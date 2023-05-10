import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/model/app_config.dart';
import 'package:mirrorfly_uikit_plugin/app/model/reply_hash_map.dart';

import 'app/common/app_theme.dart';
import 'app/common/main_controller.dart';
import 'app/data/apputils.dart';
import 'app/data/session_management.dart';
import 'app/model/register_model.dart';
import 'app/modules/chat/controllers/chat_controller.dart';
import 'app/modules/chat/views/chat_view.dart';
import 'mirrorfly_uikit_plugin_platform_interface.dart';

class MirrorflyUikit {
  static MirrorFlyAppTheme? getTheme = MirrorFlyTheme.mirrorFlyLightTheme;
  static bool isTrialLicence = true;
  static String googleMapKey = '';
  static bool isSDKInitialized = false;
  static String theme = "light";

  static Future<String?> getPlatformVersion() {
    return MirrorflyUikitPluginPlatform.instance.getPlatformVersion();
  }

  ///Used as a initUIKIT class for [MirrorflyUikit]
  /// * [baseUrl] provides the base url for making api calls
  /// * [licenseKey] provides the License Key
  /// * [iOSContainerID] provides the App Group of the iOS Project
  /// * [isTrialLicenceKey] to provide trial/live register and contact sync
  /// * [storageFolderName] provides the Local Storage Folder Name
  /// * [enableDebugLog] provides the Debug Log.
  static initUIKIT() async {
    try {
      String configFile = await rootBundle.loadString('assets/mirrorfly_config.json');
      var config = AppConfig.fromJson(json.decode(configFile));
      Mirrorfly.init(
          baseUrl: config.projectInfo.serverAddress,
          licenseKey: config.projectInfo.licenseKey,
          iOSContainerID: config.projectInfo.iOSContainerId,
          storageFolderName: config.projectInfo.storageFolderName.isEmpty ? null : config.projectInfo.storageFolderName,
          enableMobileNumberLogin: config.projectInfo.enableMobileNumberLogin,
          isTrialLicenceKey: config.projectInfo.isTrialLicenceKey,
          enableDebugLog: false);

      googleMapKey = config.projectInfo.googleMapKey;
      theme = config.appTheme.theme;
      getTheme = config.appTheme.theme == "light"
          ? MirrorFlyTheme.mirrorFlyLightTheme
          : config.appTheme.theme == "dark"
              ? MirrorFlyTheme.mirrorFlyDarkTheme
              : MirrorFlyTheme.customTheme(
                  primaryColor: config.appTheme.customTheme.primaryColor,
                  secondaryColor: config.appTheme.customTheme.secondaryColor,
                  scaffoldColor: config.appTheme.customTheme.scaffoldColor,
                  colorOnPrimary: config.appTheme.customTheme.colorOnPrimary,
                  textPrimaryColor: config.appTheme.customTheme.textPrimaryColor,
                  textSecondaryColor: config.appTheme.customTheme.textSecondaryColor,
                  chatBubblePrimaryColor: config.appTheme.customTheme.chatBubblePrimaryColor,
                  chatBubbleSecondaryColor: config.appTheme.customTheme.chatBubbleSecondaryColor,
                  appBarColor: config.appTheme.customTheme.appBarColor,
                  colorOnAppbar: config.appTheme.customTheme.colorOnAppbar);
      isTrialLicence = config.projectInfo.isTrialLicenceKey;
      ReplyHashMap.init();
      isSDKInitialized = true;
    } catch (e) {
      isSDKInitialized = false;
      throw ("Mirrorfly config file not found in assets");
    }

    //commenting bcz used as a local variable
    SessionManagement.onInit().then((value) {
    //   SessionManagement.setIsTrailLicence(isTrialLicenceKey);
      Get.put<MainController>(MainController());
    });

  }

  ///Used as a register class for [MirrorflyUikit]
  ///
  ///* [userIdentifier] provide the Unique Id to Register the User
  ///* [token] provide the FCM token this is an optional
  static Future<Map> register(String userIdentifier, {String token = ""}) async {
    if(!isSDKInitialized){
      return setResponse(false,'SDK Not Initialized');
    }
    if (await AppUtils.isNetConnected()) {
      var value = await Mirrorfly.registerUser(userIdentifier, token: token);
      try {
        var userData = registerModelFromJson(value); //message
        if (userData.data != null) {
          SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
          SessionManagement.setUser(userData.data!);
          Mirrorfly.enableDisableArchivedSettings(true);
          // Mirrorfly.setRegionCode(regionCode ?? 'IN');///if its not set then error comes in contact sync delete from phonebook.
          // SessionManagement.setCountryCode((countryCode ?? "").replaceAll('+', ''));
          _setUserJID(userData.data!.username!);
          return setResponse(true,'Register Success');
        } else {
          return setResponse(false,userData.message.toString());
        }
      } catch (e) {
        return setResponse(false,'$e');
      }
    } else {
      return Future.value(setResponse(false, 'Check your internet connection and try again'));
    }
  }

  static Future<Map<String,dynamic>> logoutFromUIKIT() async {
    try {
      var value  = await Mirrorfly.logoutOfChatSDK();//.then((value) {
        if (value) {
          var token = SessionManagement.getToken().checkNull();
          SessionManagement.clear().then((value) {
            SessionManagement.setToken(token);
          });
          return setResponse(true,'Logout successfully');
        } else {
          return setResponse(false,'Logout Failed');
        }
      //});
    }catch(e){
      return setResponse(false,'Logout Failed');
    }
  }
   static Map<String,dynamic> setResponse(bool status,String message){
     return {'status': status, 'message': message};
   }

  static _setUserJID(String username) {
    Mirrorfly.getAllGroups(true);
    Mirrorfly.getJid(username).then((value) {
      if (value != null) {
        SessionManagement.setUserJID(value);
      }
    }).catchError((error) {});
  }

  static ChatView chatPage() {
    Get.put<ChatController>(ChatController());
    return const ChatView(jid: "",);
  }
}