import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_uikit_plugin/app/extensions/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/model/reply_hash_map.dart';

import 'app/common/main_controller.dart';
import 'app/data/session_management.dart';
import 'app/data/utils.dart';
import 'mirrorfly_uikit_plugin_platform_interface.dart';

class MirrorflyUikit {
  // static MirrorFlyAppTheme? getTheme = MirrorFlyTheme.mirrorFlyLightTheme;
  bool showMobileNumberOnList = true;
  bool showStatusOption = true;
  bool enableLocalNotification = true;
  // String googleMapKey = '';
  bool isSDKInitialized = false;

  // var instance = MirrorflyUikit();

  // Private constructor
  MirrorflyUikit._internal();

  // Singleton instance
  static final MirrorflyUikit _instance = MirrorflyUikit._internal();

  // Public accessor for the singleton instance
  static MirrorflyUikit get instance => _instance;

  // Initialize the NavigationManager in the constructor
  // final NavigationManager navigationManager = NavigationManager();

  GlobalKey<NavigatorState>? globalNavigatorKey;

  Future<String?> getPlatformVersion() {
    return MirrorflyUikitPluginPlatform.instance.getPlatformVersion();
  }

  ///Used as a initUIKIT class for [MirrorflyUikit]
  /// * [licenseKey] provide the License Key
  /// * [iOSContainerID] provide the App Group of the iOS Project
  /// * [storageFolderName] provide the Local Storage Folder Name
  /// * [chatHistoryEnable]: Flag indicating whether chat history should be enabled. Defaults to true.
  /// * [enableMobileNumberLogin]: Flag indicating whether mobile number login should be enabled. Defaults to false.
  /// * [enableDebugLog]: Flag indicating whether debug logs should be enabled. Defaults to false.
  /// * [NavigatorState] provide GlobalKey for NavigatorState ex: GlobalKey<[NavigatorState]> navigatorKey = GlobalKey<[NavigatorState]>();
  Future<Map> initUIKIT(
      {required GlobalKey<NavigatorState> navigatorKey,
      required String licenseKey,
      required String iOSContainerID,
      String storageFolderName = "Mirrorfly",
      bool enableDebugLog = true,
      bool chatHistoryEnable = true,
      bool enableMobileNumberLogin = false,
      @Deprecated('Enabling local notifications will no longer work. '
          'Instead, use Mirrorfly.showOrUpdateOrCancelNotification.listen((event) { }); '
          'to listen for foreground notifications from MirrorFly Plugin.')
      bool enableLocalNotification = true}) async {
    Completer<Map<String, dynamic>> completer = Completer();

    this.enableLocalNotification = enableLocalNotification;

    globalNavigatorKey = navigatorKey;

    Mirrorfly.initializeSDK(
        licenseKey: licenseKey,
        iOSContainerID: iOSContainerID,
        storageFolderName: storageFolderName,
        chatHistoryEnable: chatHistoryEnable,
        enableDebugLog: enableDebugLog,
        enableMobileNumberLogin: enableMobileNumberLogin,
        flyCallback: (response) async {
          if (response.isSuccess) {
            LogMessage.d("initUIKIT onSuccess", response.message);
            isSDKInitialized = true;
            _initialiseUIKITDependencies();
            completer.complete(setResponse(
                true, 'SDK Initialized Successfully', response.message));
          } else {
            isSDKInitialized = false;
            _initialiseUIKITDependencies();
            LogMessage.d(
                "initUIKIT onFailure", response.errorMessage.toString());
            completer.complete(setResponse(false, 'SDK Initialization Failed',
                response.errorMessage.toString()));
          }
        });

    return completer.future;
  }

  _initialiseUIKITDependencies() {
    SessionManagement.onInit().then((value) {
      _getMediaEndpoint();
      // SessionManagement.setBool(AppConstants.enableLocalNotification, enableLocalNotification);
      Get.put<MainController>(MainController());
    });
    ReplyHashMap.init();
  }

  ///Used as a register class for [MirrorflyUikit]
  ///
  ///* [userIdentifier] provide the Unique Id to Register the User
  ///* [fcmToken] provide the FCM token this is an optional
  ///sample response {'status': true, 'message': 'Register Success};
  @Deprecated('Instead of use login() method')
  Future<Map> registerUser(
      {required String userIdentifier, String fcmToken = ""}) async {
    if (!isSDKInitialized) {
      return setResponse(false, 'SDK Not Initialized',
          'Try Initialising UIKIT using await MirrorflyUikit.instance.initUIKIT()');
    }
    if (await AppUtils.isNetConnected()) {
      var value = "";
      await Mirrorfly.registerUser(
          userIdentifier: userIdentifier,
          fcmToken: fcmToken,
          flyCallback: (FlyResponse response) {
            value = response.data;
          });
      try {
        var userData = registerModelFromJson(value); //message
        if (userData.data != null) {
          SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
          SessionManagement.setUser(userData.data!);
          Mirrorfly.enableDisableArchivedSettings(
              enable: true, flyCallBack: (_) {});
          SessionManagement.setUserIdentifier(userIdentifier);
          await _setUserJID(userData.data!.username!);
          return setResponse(true, 'Registration Success', '');
        } else {
          return setResponse(
              false, 'Registration Failed', userData.message.toString());
        }
      } catch (e) {
        return setResponse(false, 'Registration Success', '$e');
      }
    } else {
      return Future.value(setResponse(false, 'Connectivity Issue',
          'Check your internet connection and try again'));
    }
  }

  ///Used as a login class for [MirrorflyUikit]
  ///If the [userIdentifier] is new, the same method will register and login into Mirrorfly
  ///else it will act as a login method
  ///
  ///* [userIdentifier] provide the Unique Id to Register the User
  ///* [fcmToken] provide the FCM token this is an optional
  /// and specify whether to forcefully register the user if not already registered with [isForceRegister].to specify the app user type use [userType].
  /// The [identifierMetaData] parameter is optional and represents additional metadata associated with the User.
  ///sample response {'status': true, 'message': 'Login Success};
  Future<Map> login({
    required String userIdentifier,
    String fcmToken = "",
    String userType = "d",
    bool isForceRegister = true,
    List<IdentifierMetaData>? identifierMetaData,
  }) async {
    Completer<Map<String, dynamic>> completer = Completer();
    if (!isSDKInitialized) {
      completer.complete(setResponse(false, 'SDK Not Initialized',
          'Try Initialising UIKIT using await MirrorflyUikit.instance.initUIKIT()'));
    }
    Mirrorfly.login(
        userIdentifier: userIdentifier.removeAllWhitespace,
        fcmToken: fcmToken,
        userType: userType,
        isForceRegister: isForceRegister,
        identifierMetaData: identifierMetaData,
        flyCallback: (FlyResponse response) async {
          if (response.isSuccess) {
            if (response.hasData) {
              var userData = registerModelFromJson(response.data); //message
              if (userData.data != null) {
                SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
                SessionManagement.setUser(userData.data!);
                Mirrorfly.enableDisableArchivedSettings(
                    enable: true, flyCallBack: (_) {});
                SessionManagement.setUserIdentifier(userIdentifier);
                await _setUserJID(userData.data!.username!);
                completer.complete(setResponse(true, 'Login Success', ''));
              } else {
                completer.complete(setResponse(
                    false, 'Login Failed', userData.message.toString()));
              }
            }
          } else {
            // debugPrint("issue===> ${response.errorMessage.toString()}");
            if (response.exception?.code == "403") {
              debugPrint("issue 403 ===> ${response.errorMessage}");
              completer.complete(
                  setResponse(false, 'Login Failed', response.errorMessage));
            } else if (response.exception?.code == "405") {
              debugPrint("issue 405 ===> ${response.errorMessage}");
              completer.complete(setResponse(
                  false,
                  'Login failed. Try using `isForceRegister` with a value of `true`',
                  response.errorMessage));
            } else {
              // debugPrint("issue else code ===> ${response.exception?.code}");
              debugPrint("issue ===> ${response.errorMessage}");
              completer.complete(
                  setResponse(false, 'Login Failed', response.errorMessage));
            }
          }
        });
    return completer.future;
  }

  ///Used as a register class for [MirrorflyUikit]
  ///Use this Method to logout from our UIkit
  ///this will clear all the chat data.
  ///sample response {'status': true, 'message': 'Logout successfully};
  Future<Map<String, dynamic>> logoutFromUIKIT() async {
    Completer<Map<String, dynamic>> completer = Completer();

    Mirrorfly.logoutOfChatSDK(flyCallBack: (response) {
      if (response.isSuccess) {
        var token = SessionManagement.getToken().checkNull();
        SessionManagement.clear().then((value) {
          SessionManagement.setToken(token);
        });
        // return setResponse(true, 'Logout successfully');
        completer.complete(setResponse(true, 'Logout success', ''));
      } else {
        // return setResponse(false, 'Logout Failed');
        completer.complete(setResponse(false, 'Logout Failed', ''));
      }
    });
    return completer.future;
  }

  ///Used as a [isOnGoingCall] class for [MirrorflyUikit]
  ///used to check if there is an ongoing call
  ///this method works in [Android], in [iOS] returns always false
  ///returns the bool value
  Future<bool?> isOnGoingCall() async {
    return await Mirrorfly.isOnGoingCall();
  }

  Map<String, dynamic> setResponse(
      bool status, String message, String? details) {
    return {'status': status, 'message': message, 'details': details};
  }

  _setUserJID(String username) async {
    // Mirrorfly.getAllGroups(fetchFromServer: true, flyCallBack: (_) {});
    await Mirrorfly.getJid(username: username).then((value) {
      if (value != null) {
        SessionManagement.setUserJID(value);
      }
    }).catchError((error) {});
  }

  _getMediaEndpoint() async {
    Mirrorfly.mediaEndPoint().then((value) {
      LogMessage.d("media_endpoint", value.toString());
      if (value != null) {
        if (value.isNotEmpty) {
          SessionManagement.setMediaEndPoint(value);
        } else {
          LogMessage.d("failed to get media_endpoint", value.toString());
        }
      }
    });
  }

/*  static ChatView chatPage() {
    Get.put<ChatController>(ChatController());
    return const ChatView(
      jid: "",
      showChatDeliveryIndicator: false,
    );
  }*/
}
