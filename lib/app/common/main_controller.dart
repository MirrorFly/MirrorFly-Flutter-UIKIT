import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:mirrorfly_uikit_plugin/app/base_controller.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/apputils.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/controllers/chat_controller.dart';

import 'package:mirrorfly_plugin/flychat.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../mirrorfly_uikit_plugin.dart';
import '../modules/chatInfo/controllers/chat_info_controller.dart';
import '../modules/notification/notification_service.dart';
import 'app_constants.dart';

class MainController extends FullLifeCycleController
    with BaseController, FullLifeCycleMixin /*with FullLifeCycleMixin */ {
  var authToken = "".obs;
  Rx<String> uploadEndpoint = "".obs;
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var isPlaying = false.obs;
  var audioPlayed = false.obs;
  AudioPlayer player = AudioPlayer();
  String currentPostLabel = "00:00";
  bool _notificationsEnabled = false;

  //network listener
  static StreamSubscription<InternetConnectionStatus>? listener;

  @override
  Future<void> onInit() async {
    super.onInit();
    //presentPinPage();
    initListeners();
    getMediaEndpoint();
    uploadEndpoint(SessionManagement.getMediaEndPoint().checkNull());
    authToken(SessionManagement.getAuthToken().checkNull());
    getAuthToken();
    startNetworkListen();

    if(SessionManagement.getBool(AppConstants.enableLocalNotification)) {
      NotificationService notificationService = NotificationService();
      await notificationService.init();
      _isAndroidPermissionGranted();
      _requestPermissions();
      // _configureSelectNotificationSubject();
    }
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ??
          false;

      // setState(() {
      _notificationsEnabled = granted;
      debugPrint("Notification Enabled--> $_notificationsEnabled");
      // });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      // setState(() {
      _notificationsEnabled = granted ?? false;
      // });
    }
  }

  /*void _configureSelectNotificationSubject() {
    debugPrint("_configureSelectNotificationSubject");
    final context = Get.context;
    selectNotificationStream.stream.listen((String? payload) async {

      debugPrint("#Mirrorfly Notification -> opening chat page--> $payload ${Get.currentRoute}");
      if(payload != null && payload.isNotEmpty){
        if (Get.isRegistered<ChatController>()) {
          // if(Get.currentRoute == Routes.forwardChat || Get.currentRoute == Routes.chatInfo || Get.currentRoute == Routes.groupInfo || Get.currentRoute == Routes.messageInfo){
          //   Get.back();
          // }
          if(Get.currentRoute.contains("from_notification=true")){
            // Get.offAllNamed("${AppPages.chat}?jid=$payload&from_notification=true");
            Navigator.pushAndRemoveUntil(
              context!,
              MaterialPageRoute(
                builder: (context) => ChatView(jid: payload),
              ),
                  (route) => false, // This removes all previous routes from the stack
            );

          }else {
            Navigator.pushAndRemoveUntil(
              context!,
              MaterialPageRoute(
                builder: (context) => ChatView(jid: payload),
              ),
                  (route) => false, // This removes all previous routes from the stack
            );
            // Get.offNamed(Routes.chat,
            //     parameters: {"chatJid": payload});
          }
        }else {
          // Get.toNamed(Routes.chat,
          //     parameters: {"chatJid": payload});
          Navigator.pushAndRemoveUntil(
            context!,
            MaterialPageRoute(
              builder: (context) => ChatView(jid: payload),
            ),
                (route) => false, // This removes all previous routes from the stack
          );
        }
      }
    });
  }*/

  getMediaEndpoint() async {
    if (SessionManagement.getMediaEndPoint().checkNull().isEmpty) {
      Mirrorfly.mediaEndPoint().then((value) {
        mirrorFlyLog("media_endpoint", value.toString());
        if (value != null) {
          if (value.isNotEmpty) {
            uploadEndpoint(value);
            SessionManagement.setMediaEndPoint(value);
          } else {
            uploadEndpoint(SessionManagement.getMediaEndPoint().checkNull());
          }
        }
      });
    }
  }

  getAuthToken() async {
    if (SessionManagement.getUsername().checkNull().isNotEmpty &&
        SessionManagement.getPassword().checkNull().isNotEmpty) {
      await Mirrorfly.refreshAndGetAuthToken().then((value) {
        mirrorFlyLog("RetryAuth", value.toString());
        if (value != null) {
          if (value.isNotEmpty) {
            authToken(value);
            SessionManagement.setAuthToken(value);
          } else {
            authToken(SessionManagement.getAuthToken().checkNull());
          }
          update();
        }
      });
    }
  }

  handleAdminBlockedUser(String jid, bool status) {
    if (SessionManagement.getUserJID().checkNull() == jid) {
      if (status) {
        //show Admin Blocked Activity
        SessionManagement.setAdminBlocked(status);
        // Get.toNamed(Routes.adminBlocked);
      }
    }
  }

  handleAdminBlockedUserFromRegister() {}

  void startNetworkListen() {
    final InternetConnectionChecker customInstance =
        InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 1),
      checkInterval: const Duration(seconds: 1),
    );
    listener = customInstance.onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            mirrorFlyLog("network", 'Data connection is available.');
            networkConnected();
            if (Get.isRegistered<ChatController>()) {
              Get.find<ChatController>().networkConnected();
            }
            if (Get.isRegistered<ChatInfoController>()) {
              Get.find<ChatInfoController>().networkConnected();
            }
            /*if (Get.isRegistered<ContactSyncController>()) {
              Get.find<ContactSyncController>().networkConnected();
            }*/
            break;
          case InternetConnectionStatus.disconnected:
            mirrorFlyLog("network", 'You are disconnected from the internet.');
            networkDisconnected();
            if (Get.isRegistered<ChatController>()) {
              Get.find<ChatController>().networkDisconnected();
            }
            if (Get.isRegistered<ChatInfoController>()) {
              Get.find<ChatInfoController>().networkDisconnected();
            }
            /*if (Get.isRegistered<ContactSyncController>()) {
              Get.find<ContactSyncController>().networkDisconnected();
            }*/
            break;
        }
      },
    );
  }

  @override
  void onClose() {
    listener?.cancel();
    super.onClose();
  }

  @override
  void onDetached() {
    mirrorFlyLog('mainController', 'onDetached');
  }

  @override
  void onInactive() {
    mirrorFlyLog('mainController', 'onInactive');
  }

  bool fromLockScreen = false;

  @override
  void onPaused() async {
    mirrorFlyLog('mainController', 'onPaused');
    // fromLockScreen = await isLockScreen() ?? false;
    mirrorFlyLog('isLockScreen', '$fromLockScreen');
    SessionManagement.setAppSessionNow();
  }

  @override
  void onResumed() {
    mirrorFlyLog('mainController', 'onResumed');
    checkShouldShowPin();
    if (!MirrorflyUikit.instance.isTrialLicenceKey) {
      syncContacts();
    }
  }

  void syncContacts() async {
    if (await Permission.contacts.isGranted) {
      if (await AppUtils.isNetConnected() &&
          !await Mirrorfly.contactSyncStateValue()) {
        final permission = await Permission.contacts.status;
        if (permission == PermissionStatus.granted) {
          if (SessionManagement.getLogin()) {
            Mirrorfly.syncContacts(
                !SessionManagement.isInitialContactSyncDone());
          }
        }
      }
    } else {
      if (SessionManagement.isInitialContactSyncDone()) {
        Mirrorfly.revokeContactSync().then((value) {
          onContactSyncComplete(true);
          mirrorFlyLog("checkContactPermission isSuccess", value.toString());
        });
      }
    }
  }

  void networkDisconnected() {}

  void networkConnected() {
    if (!MirrorflyUikit.instance.isTrialLicenceKey) {
      syncContacts();
    }
  }

  /*
  *This function used to check time out session for app lock
  */
  void checkShouldShowPin() {
    var lastSession = SessionManagement.appLastSession();
    var lastPinChangedAt = SessionManagement.lastPinChangedAt();
    var sessionDifference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastSession));
    var lockSessionDifference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastPinChangedAt));
    debugPrint('sessionDifference seconds ${sessionDifference.inSeconds}');
    debugPrint('lockSessionDifference days ${lockSessionDifference.inDays}');
    if (Constants.pinAlert <= lockSessionDifference.inDays &&
        Constants.pinExpiry >= lockSessionDifference.inDays) {
      //Alert Day
      debugPrint('Alert Day');
    } else if (Constants.pinExpiry < lockSessionDifference.inDays) {
      //Already Expired day
      debugPrint('Already Expired');
      presentPinPage();
    } else {
      //if 30 days not completed
      debugPrint('Not Expired');
      if (Constants.sessionLockTime <= sessionDifference.inSeconds ||
          fromLockScreen) {
        //Show Pin if App Lock Enabled
        debugPrint('Show Pin');
        presentPinPage();
      }
    }
    fromLockScreen = false;
  }

  void presentPinPage() {
    /*if ((SessionManagement.getEnablePin() ||
            SessionManagement.getEnableBio()) &&
        Get.currentRoute != Routes.pin) {
       Get.toNamed(Routes.pin,);
    }*/
  }
}
