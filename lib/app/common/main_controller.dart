import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/model/available_features.dart';
import 'package:mirrorfly_plugin/model/callback.dart';

import 'package:mirrorfly_uikit_plugin/app/base_controller.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/apputils.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/controllers/chat_controller.dart';

import 'package:mirrorfly_plugin/flychat.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../mirrorfly_uikit_plugin.dart';
import '../modules/chatInfo/controllers/chat_info_controller.dart';
import '../modules/notification/notification_builder.dart';
import '../modules/notification/notification_service.dart';
import 'app_constants.dart';
import 'extensions.dart';

class MainController extends FullLifeCycleController
    with BaseController, FullLifeCycleMixin /*with FullLifeCycleMixin */ {
  // var authToken = "".obs;
  var currentAuthToken = "".obs;
  var googleMapKey = "";
  Rx<String> mediaEndpoint = "".obs;
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

  var availableFeature = AvailableFeatures().obs;

  final unreadCallCount = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    //presentPinPage();
    Mirrorfly.getValueFromManifestOrInfoPlist(androidManifestKey: "com.google.android.geo.API_THUMP_KEY", iOSPlistKey: "API_THUMP_KEY").then((value) {
      googleMapKey = value;
      mirrorFlyLog("com.google.android.geo.API_THUMP_KEY", googleMapKey);
    });
    // PushNotifications.init();
    initListeners();
    mediaEndpoint(SessionManagement.getMediaEndPoint().checkNull());
    getMediaEndpoint();
    // uploadEndpoint(SessionManagement.getMediaEndPoint().checkNull());
    currentAuthToken(SessionManagement.getAuthToken().checkNull());
    getCurrentAuthToken();
    startNetworkListen();

    getAvailableFeatures();

    if(SessionManagement.getBool(AppConstants.enableLocalNotification)) {
      NotificationService notificationService = NotificationService();
      await notificationService.init();
      _isAndroidPermissionGranted();
      _requestPermissions();
      // _configureSelectNotificationSubject();
      unreadMissedCallCount();
      _removeBadge();
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

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
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

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

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

  getCurrentAuthToken() async {
    await Mirrorfly.getCurrentAuthToken().then((value) {
      mirrorFlyLog("getCurrentAuthToken", value.toString());
      if (value.isNotEmpty) {
        currentAuthToken(value);
        SessionManagement.setAuthToken(value);
      } else {
        currentAuthToken(SessionManagement.getAuthToken().checkNull());
      }
    });
  }

 /* getAuthToken() async {
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
  }*/

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
    var unReadMessageCount = await Mirrorfly.getUnreadMessageCountExceptMutedChat();
    debugPrint('mainController unReadMessageCount onPaused ${unReadMessageCount.toString()}');
    _setBadgeCount(unReadMessageCount ?? 0);
    // fromLockScreen = await isLockScreen() ?? false;
    mirrorFlyLog('isLockScreen', '$fromLockScreen');
    SessionManagement.setAppSessionNow();
  }

  @override
  void onResumed() {
    mirrorFlyLog('mainController', 'onResumed');

    NotificationBuilder.cancelNotifications();
    checkShouldShowPin();
    if (!MirrorflyUikit.instance.isTrialLicenceKey) {
      syncContacts();
    }
    unreadMissedCallCount();
  }

  void syncContacts() async {
    if (await Permission.contacts.isGranted) {
      if (await AppUtils.isNetConnected() &&
          !await Mirrorfly.contactSyncStateValue()) {
        final permission = await Permission.contacts.status;
        if (permission == PermissionStatus.granted) {
          if (SessionManagement.getLogin()) {
            Mirrorfly.syncContacts(isFirstTime:
                !SessionManagement.isInitialContactSyncDone(), flyCallBack: (_) {});
          }
        }
      }
    } else {
      if (SessionManagement.isInitialContactSyncDone()) {
        Mirrorfly.revokeContactSync(flyCallBack: (FlyResponse response) {
          onContactSyncComplete(true);
          mirrorFlyLog("checkContactPermission isSuccess", response.isSuccess.toString());
        });
      }
    }
  }

  void networkDisconnected() {}

  void networkConnected() {
    if (Constants.enableContactSync) {
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

  void getAvailableFeatures() {
    Mirrorfly.getAvailableFeatures().then((features) {
      debugPrint("getAvailableFeatures $features");
      var featureAvailable = availableFeaturesFromJson(features);
      availableFeature(featureAvailable);
    });
  }

  void onAvailableFeatures(AvailableFeatures features) {
    availableFeature(features);
  }

  @override
  void onHidden() {
    mirrorFlyLog('LifeCycle', 'onHidden');
  }

  unreadMissedCallCount() async {
    var unreadMissedCallCount = await Mirrorfly.getUnreadMissedCallCount();
    unreadCallCount.value = unreadMissedCallCount ?? 0;
    debugPrint("unreadMissedCallCount $unreadMissedCallCount");
  }

  void _setBadgeCount(int count) {
    FlutterAppBadger.updateBadgeCount(count);
  }

  void _removeBadge() {
    FlutterAppBadger.removeBadge();
  }
}
