import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:is_lock_screen/is_lock_screen.dart';

import '../base_controller.dart';
import '../common/constants.dart';
import '../data/session_management.dart';
import '../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/utils.dart';
import '../routes/route_settings.dart';

class MainController extends FullLifeCycleController with BaseController, FullLifeCycleMixin /*with FullLifeCycleMixin */ {
  var currentAuthToken = "".obs;
  var googleMapKey = "";
  Rx<String> mediaEndpoint = "".obs;
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var isPlaying = false.obs;
  var audioPlayed = false.obs;
  AudioPlayer player = AudioPlayer();
  String currentPostLabel = "00:00";

  //network listener
  static StreamSubscription<InternetConnectionStatus>? listener;

  var availableFeature = AvailableFeatures().obs;

  final unreadCallCount = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    /*Mirrorfly.isOnGoingCall().then((value){
      if(value.checkNull()){
        NavUtils.toNamed(Routes.onGoingCallView);
      }
    });*/
    Mirrorfly.getValueFromManifestOrInfoPlist(androidManifestKey: "com.google.android.geo.API_THUMP_KEY", iOSPlistKey: "API_THUMP_KEY").then((value) {
      googleMapKey = value;
      LogMessage.d("com.google.android.geo.API_THUMP_KEY", googleMapKey);
    });
    //presentPinPage();
    debugPrint("#Mirrorfly Notification -> Main Controller push init");
    initListeners();
    mediaEndpoint(SessionManagement.getMediaEndPoint().checkNull());
    getMediaEndpoint();
    currentAuthToken(SessionManagement.getAuthToken().checkNull());
    getCurrentAuthToken();
    //getAuthToken();
    startNetworkListen();

    getAvailableFeatures();

    unreadMissedCallCount();
  }



  getMediaEndpoint() async {
    await Mirrorfly.mediaEndPoint().then((value) {
      LogMessage.d("media_endpoint", value.toString());
      if (value != null) {
        if (value.isNotEmpty) {
          mediaEndpoint(value);
          SessionManagement.setMediaEndPoint(value);
        } else {
          mediaEndpoint(SessionManagement.getMediaEndPoint().checkNull());
        }
      }
    });
  }

  getCurrentAuthToken() async {
    await Mirrorfly.getCurrentAuthToken().then((value) {
      LogMessage.d("getCurrentAuthToken", value.toString());
      if (value.isNotEmpty) {
        currentAuthToken(value);
        SessionManagement.setAuthToken(value);
      } else {
        currentAuthToken(SessionManagement.getAuthToken().checkNull());
      }
    });
  }

  handleAdminBlockedUser(String jid, bool status) {
    if (SessionManagement.getUserJID().checkNull() == jid) {
      if (status) {
        //show Admin Blocked Activity
        SessionManagement.setAdminBlocked(status);
        NavUtils.toNamed(Routes.adminBlocked);
      }
    }
  }

  handleAdminBlockedUserFromRegister() {}

  void startNetworkListen() {
    final InternetConnectionChecker customInstance = InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 1),
      checkInterval: const Duration(seconds: 1),
    );
    listener = customInstance.onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            LogMessage.d("network", 'Data connection is available.');
            networkConnected();
            break;
          case InternetConnectionStatus.disconnected:
            LogMessage.d("network", 'You are disconnected from the internet.');
            networkDisconnected();
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
    LogMessage.d('LifeCycle', 'onDetached');
  }

  @override
  void onInactive() {
    LogMessage.d('LifeCycle', 'onInactive');
  }

  bool fromLockScreen = false;

  var hasPaused = false;
  @override
  void onPaused() async {
    hasPaused = true;
    LogMessage.d('LifeCycle', 'onPaused');
    var unReadMessageCount = await Mirrorfly.getUnreadMessageCountExceptMutedChat();
    debugPrint('mainController unReadMessageCount onPaused ${unReadMessageCount.toString()}');
    fromLockScreen = await isLockScreen() ?? false;
    LogMessage.d('isLockScreen', '$fromLockScreen');
    SessionManagement.setAppSessionNow();
  }

  @override
  void onResumed() {
    LogMessage.d('LifeCycle', 'onResumed');
    // NotificationBuilder.cancelNotifications();
    checkShouldShowPin();
    if(hasPaused) {
      hasPaused = false;
      if (Constants.enableContactSync) {
        syncContacts();
      }
      unreadMissedCallCount();
    }
  }

  void syncContacts() async {
    if(await Permission.contacts.isGranted) {
      if (await AppUtils.isNetConnected() &&
          !await Mirrorfly.contactSyncStateValue()) {
        final permission = await Permission.contacts.status;
        if (permission == PermissionStatus.granted) {
          if(SessionManagement.getLogin()) {
            Mirrorfly.syncContacts(isFirstTime: !SessionManagement.isInitialContactSyncDone(), flyCallBack: (_) {});
          }
        }
      }
    }else{
      if(SessionManagement.isInitialContactSyncDone()) {
        Mirrorfly.revokeContactSync(flyCallBack: (FlyResponse response) {
          onContactSyncComplete(true);
          LogMessage.d("checkContactPermission isSuccess", response.isSuccess.toString());
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
    var sessionDifference = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastSession,isUtc: true));
    var lockSessionDifference = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastPinChangedAt,isUtc: true));
    debugPrint('sessionDifference seconds ${sessionDifference.inSeconds}');
    debugPrint('lockSessionDifference days ${lockSessionDifference.inDays}');
    if (Constants.pinAlert <= lockSessionDifference.inDays && Constants.pinExpiry >= lockSessionDifference.inDays) {
      //Alert Day
      debugPrint('Alert Day');
    } else if (Constants.pinExpiry < lockSessionDifference.inDays) {
      //Already Expired day
      debugPrint('Already Expired');
      presentPinPage();
    } else {
      //if 30 days not completed
      debugPrint('Not Expired');
      if (Constants.sessionLockTime <= sessionDifference.inSeconds || fromLockScreen) {
        //Show Pin if App Lock Enabled
        debugPrint('Show Pin');
        presentPinPage();
      }
    }
    fromLockScreen = false;
  }

  void presentPinPage() {
    if ((SessionManagement.getEnablePin() || SessionManagement.getEnableBio()) && NavUtils.currentRoute != Routes.pin) {
      NavUtils.toNamed(
        Routes.pin,
      );
    }
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
    LogMessage.d('LifeCycle', 'onHidden');
  }

  unreadMissedCallCount() async {
    try {
      var unreadMissedCallCount = await Mirrorfly.getUnreadMissedCallCount();
      unreadCallCount.value = unreadMissedCallCount ?? 0;
      debugPrint("unreadMissedCallCount $unreadMissedCallCount");
    }catch(e){
      debugPrint("unreadMissedCallCount $e");
    }
  }
}
