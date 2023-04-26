import 'package:get/get.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_theme.dart';

import 'app/common/main_controller.dart';
import 'app/data/apputils.dart';
import 'app/data/session_management.dart';
import 'app/model/register_model.dart';
import 'app/modules/chat/controllers/chat_controller.dart';
import 'app/modules/chat/views/chat_view.dart';
import 'mirrorfly_uikit_plugin_platform_interface.dart';

class MirrorflyUikit {
  static MirrorflyTheme myTheme = MirrorflyTheme.lightTheme;
  static bool isTrial = true;

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
  static initUIKIT(
      {required String baseUrl,
      required String licenseKey,
      required String iOSContainerID,
      MirrorflyTheme theme = MirrorflyTheme.lightTheme,
      String? storageFolderName,
      bool enableMobileNumberLogin = true,
      bool isTrialLicenceKey = true,
      bool enableDebugLog = false}) {
    Mirrorfly.init(
        baseUrl: baseUrl,
        licenseKey: licenseKey,
        //ckIjaccWBoMNvxdbql8LJ2dmKqT5bp//2sdgNtr3sFBSM3bYRa7RKDPEiB38Xo
        iOSContainerID: iOSContainerID,
        storageFolderName: storageFolderName,
        enableMobileNumberLogin: enableMobileNumberLogin,
        isTrialLicenceKey: isTrialLicenceKey,
        enableDebugLog: enableDebugLog);
    myTheme = theme;
    isTrial = isTrialLicenceKey;
    SessionManagement.onInit().then((value) {
      SessionManagement.setIsTrailLicence(isTrialLicenceKey);
      Get.put<MainController>(MainController());
    });
  }

  static MirrorflyTheme get getTheme => myTheme;
  static bool get isTrialLicence => isTrial;

  ///Used as a register class for [MirrorflyUikit]
  ///
  ///* [userIdentifier] provide the Unique Id to Register the User
  ///* [token] provide the FCM token this is an optional
  static Future<Map> register(String userIdentifier,
      {String token = ""}) async {
    if (await AppUtils.isNetConnected()) {
      var value = await Mirrorfly.registerUser(userIdentifier, token: token);
      try {
        var userData = registerModelFromJson(value); //message
        if(userData.data != null) {
          SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
          SessionManagement.setUser(userData.data!);
          Mirrorfly.enableDisableArchivedSettings(true);
          // Mirrorfly.setRegionCode(regionCode ?? 'IN');///if its not set then error comes in contact sync delete from phonebook.
          // SessionManagement.setCountryCode((countryCode ?? "").replaceAll('+', ''));
          _setUserJID(userData.data!.username!);
          return {'status': true, 'message': ''};
        }else{
          return {'status': false, 'message': '${userData.message}'};
        }
      } catch(e) {
        return {'status': false, 'message': '$e'};
      }
    } else {
      return Future.value({'status': false, 'message': 'Check your internet connection and try again'});
    }
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
    return const ChatView();
  }
}
