import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirrorfly_uikit_plugin/app/call_modules/call_timeout/views/call_timeout_view.dart';
import 'package:mirrorfly_uikit_plugin/app/call_modules/participants/participants_view.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/model/call_user_list.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

import '../../common/constants.dart';
import '../../data/helper.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../call_utils.dart';
import '../ongoing_call/ongoingcall_view.dart';

class CallController extends GetxController {
  final RxBool isVisible = true.obs;
  final RxBool muted = false.obs;
  final RxBool speakerOff = true.obs;
  final RxBool cameraSwitch = false.obs;
  final RxBool videoMuted = false.obs;
  final RxBool layoutSwitch = true.obs;

  var callTimer = '00:00'.obs;

  DateTime? startTime;

  var callList = List<CallUserList>.empty(growable: true).obs;
  var availableAudioList = List<AudioDevices>.empty(growable: true).obs;

  var callTitle = "".obs;

  var pinnedUserJid = ''.obs;
  var pinnedUser = CallUserList(isAudioMuted: false, isVideoMuted: false).obs;

  var callMode = "".obs;
  get isOneToOneCall =>
      callList.length <= 2; //callMode.value == CallMode.oneToOne;
  get isGroupCall =>
      callList.length > 2; //callMode.value == CallMode.groupCall;

  var callType = "".obs;
  get isAudioCall => callType.value == CallType.audio;
  get isVideoCall => callType.value == CallType.video;

  // Rx<Profile> profile = Profile().obs;
  var calleeName = "".obs;
  var audioOutputType = "receiver".obs;
  var callStatus = CallStatus.calling.obs;

  late Completer<void> waitingCompleter;
  bool isWaitingCanceled = false;
  bool isVideoCallRequested = false;
  bool isCallTimerEnabled = false;

  var users = <String?>[].obs;
  var groupId = ''.obs;

  TabController? tabController;
  var getMaxCallUsersCount = 8;

  late BuildContext context;

  Future<void> initCallController(
      {required List<String?> userJid,
      required BuildContext buildContext}) async {
    debugPrint("#Mirrorfly Call Controller onInit");
    groupId(await Mirrorfly.getCallGroupJid());

    context = buildContext;
    /* if (userJid != null && userJid != "") {
      debugPrint("#Mirrorfly Call initCallController UserJid $userJid");
      var data = await getProfileDetails(userJid);
      profile(data);
      calleeName(data.getName());
    }*/
    audioDeviceChanged();
    // if (Get.currentRoute == Routes.onGoingCallView) {
    //   //startTimer();
    // }

    getAudioDevices();
    /* Mirrorfly.getAllAvailableAudioInput().then((value) {
      final availableList = audioDevicesFromJson(value);
      availableAudioList(availableList);
      debugPrint(
          "${Constants.tag} flutter getAllAvailableAudioInput $availableList");
    });*/
    await Mirrorfly.getCallDirection().then((value) async {
      debugPrint("#Mirrorfly Call Direction $value");
      if (value == "Incoming") {
        Mirrorfly.getCallUsersList().then((value) {
          // [{"userJid":"919789482015@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"919894940560@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"917010279986@xmpp-uikit-qa.contus.us","callStatus":"Connected"}]
          debugPrint("#Mirrorfly call get users --> $value");
          final callUserList = callUserListFromJson(value);
          callList.addAll(callUserList);
          if (callUserList.length > 1) {
            // pinnedUserJid(callUserList[0].userJid);
            CallUserList firstAttendedCallUser = callUserList.firstWhere(
                (callUser) =>
                    callUser.callStatus?.value == CallStatus.attended ||
                    callUser.callStatus?.value == CallStatus.connected,
                orElse: () => callUserList[0]);
            pinnedUserJid(firstAttendedCallUser.userJid!.value);
            pinnedUser(firstAttendedCallUser);
          }
          // getNames();
        });
      } else {
        debugPrint("#Mirrorfly Call Direction outgoing");
        debugPrint("#Mirrorfly Call getCallUsersList");
        Mirrorfly.getCallUsersList().then((value) {
          debugPrint("#Mirrorfly call get users --> $value");
          final callUserList = callUserListFromJson(value);
          callList(callUserList);
          if (callUserList.length > 1) {
            // pinnedUserJid(callUserList[0].userJid);
            CallUserList firstAttendedCallUser = callUserList.firstWhere(
                (callUser) =>
                    callUser.callStatus?.value == CallStatus.attended ||
                    callUser.callStatus?.value == CallStatus.connected,
                orElse: () => callUserList[0]);
            pinnedUserJid(firstAttendedCallUser.userJid!.value);
            pinnedUser(firstAttendedCallUser);
          }
        });
      }
    });

    await Mirrorfly.getCallType().then((value) => callType(value));

    debugPrint("#Mirrorfly call type ${callType.value}");
    if (callType.value == 'audio') {
      Mirrorfly.isUserAudioMuted().then((value) => muted(value));
      videoMuted(true);
    } else {
      Mirrorfly.isUserAudioMuted().then((value) => muted(value));
      Mirrorfly.isUserVideoMuted().then((value) => videoMuted(value));
      // videoMuted(false);
    }

    ever(callList, (callback) {
      debugPrint("#Mirrorfly call list is changed ******");
      debugPrint("#Mirrorfly call list $callList");
    });
  }

  var calleeNames = <String>[].obs;
  Future outGoingUsers() async {
    debugPrint("outGoingUsers $users");
    calleeNames();
    if (users.length > 1) {
      for (var value in users) {
        if (value != null) {
          var data = await getProfileDetails(value);
          calleeNames.add(data.getName());
        }
      }
    } else {
      if (users.isNotEmpty && users[0] != null) {
        var data = await getProfileDetails(users[0]!);
        calleeNames.add(data.getName());
      }
    }
  }

  muteAudio() async {
    debugPrint("#Mirrorfly muteAudio ${muted.value}");
    await Mirrorfly.muteAudio(
        status: !muted.value,
        flyCallBack: (FlyResponse response) {
          debugPrint("#Mirrorfly Mute Audio Response ${response.isSuccess}.");
        });
    muted(!muted.value);
    var callUserIndex = callList.indexWhere(
        (element) => element.userJid!.value == SessionManagement.getUserJID());
    if (!callUserIndex.isNegative) {
      callList[callUserIndex].isAudioMuted(muted.value);
    }
  }

  changeSpeaker(BuildContext context) {
    // speakerOff(!speakerOff.value);
    debugPrint("availableAudioList.length ${availableAudioList.length}");
    //if connected other audio devices
    // if (availableAudioList.length > 2) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            // backgroundColor:
            //     MirrorflyUikit.theme == "dark" ? darkPopupColor : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableAudioList.length,
                    itemBuilder: (context, index) {
                      var audioItem = availableAudioList[index];
                      debugPrint("audio item name ${audioItem.name}");
                      return Obx(() {
                        return ListTile(
                          contentPadding: const EdgeInsets.only(left: 10),
                          title: Text(audioItem.name ?? "",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal)),
                          trailing: audioItem.type == audioOutputType.value
                              ? const Icon(
                                  Icons.check_outlined,
                                  color: Colors.green,
                                )
                              : const SizedBox.shrink(),
                          onTap: () {
                            if (audioOutputType.value != audioItem.type) {
                              // Get.back();
                              // Navigator.pop(context);
                              MirrorflyUikit.instance.navigationManager
                                  .navigateBack(context: context);

                              debugPrint(
                                  "selected audio item ${audioItem.type}");
                              audioOutputType(audioItem.type);
                              Mirrorfly.routeAudioTo(
                                  routeType: audioItem.type ?? "");
                            } else {
                              LogMessage.d("routeAudioOption",
                                  "clicked on same audio type selected");
                            }
                          },
                        );
                      });
                    });
              }),
            ),
          );
        });
  }

  videoMute() async {
    debugPrint("isOneToOneCall : $isOneToOneCall");
    if (await AppPermission.askVideoCallPermissions(context)) {
      if (callType.value != CallType.audio) {
        Mirrorfly.muteVideo(status: !videoMuted.value, flyCallBack: (_) {});
        videoMuted(!videoMuted.value);
      } else if (callType.value == CallType.audio &&
          isOneToOneCall &&
          MirrorflyUikit.instance.navigationManager.getCurrentRoute() !=
              Constants.onGoingCallView) {
        showVideoSwitchPopup();
      } else if (isGroupCall) {
        Mirrorfly.muteVideo(
          status: !videoMuted.value,
          flyCallBack: (_) {},
        );
        videoMuted(!videoMuted.value);
      }
    }
  }

  switchCamera() async {
    if (Platform.isIOS) {
      cameraSwitch(!cameraSwitch.value);
    }
    await Mirrorfly.switchCamera();
  }

  void showCallOptions() {
    isVisible(true);
  }

  void changeLayout() {
    layoutSwitch(!layoutSwitch.value);
  }

  void disconnectCall() {
    isCallTimerEnabled = false;
    callTimer("Disconnected");
    if (callList.isNotEmpty) {
      callList.clear();
    }
    Mirrorfly.disconnectCall(flyCallBack: (FlyResponse response) {
      debugPrint("#Disconnect call disconnect value ${response.isSuccess}");
      if (response.isSuccess) {
        debugPrint("#Disconnect call disconnect list size ${callList.length}");
        backCalledFromDisconnect();
      }
    });
  }

  void backCalledFromDisconnect() {
    if (MirrorflyUikit.instance.navigationManager.hasPrevRoute()) {
      debugPrint("#Disconnect previous route is not empty");
      if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
          Constants.onGoingCallView) {
        debugPrint("#Disconnect current route is ongoing call view");
        Future.delayed(const Duration(seconds: 1), () {
          debugPrint(
              "#Disconnect call controller back called from Ongoing Screen");
          // Get.back();
          MirrorflyUikit.instance.navigationManager
              .navigateBack(context: context);
        });
      } else if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
          Constants.participantView) {
        // Get.back();
        MirrorflyUikit.instance.navigationManager
            .navigateBack(context: context);
        Future.delayed(const Duration(seconds: 1), () {
          debugPrint(
              "#Disconnect call controller back called from Participant Screen");
          // Get.back();
          MirrorflyUikit.instance.navigationManager
              .navigateBack(context: context);
        });
      } else {
        // Get.back();
        MirrorflyUikit.instance.navigationManager
            .navigateBack(context: context);
      }
    } else {
      // Get.offNamed(getInitialRoute());
      Navigator.pop(context, true);
      // MirrorflyUikit.instance.navigationManager.navigateBack(context: context);
    }
  }

  /*getNames() async {
    callTitle("");
    callList.asMap().forEach((index, users) async {
      if (users.userJid == SessionManagement.getUserJID()) {
        callTitle("$callTitle You");
      } else {
        var profile = await Mirrorfly.getUserProfile(users.userJid!);
        var data = profileDataFromJson(profile);
        var userName = data.data?.name;
        callTitle("$callTitle ${userName!}");
      }
      if (index == 0) {
        callTitle("$callTitle and ");
      }
    });
  }*/

  @override
  void dispose() {
    exitFullScreen();
    LogMessage.d("callController", " callController dispose");
    super.dispose();
  }

  @override
  void onClose() {
    LogMessage.d("callController", " callController onClose");
    super.onClose();
  }

  void userDisconnection(String callMode, String userJid, String callType) {
    this.callMode(callMode);
    this.callType(callType);
    debugPrint("Current Route ${Get.currentRoute}");
    if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
        Constants.outGoingCallView) {
      // This if condition is added for the group call remote busy - call action
      if (callList.length < 2) {
        // Get.back();
        MirrorflyUikit.instance.navigationManager
            .navigateBack(context: context);
      }
      return;
    }

    debugPrint("#Mirrorfly call call disconnect called ${callList.length}");
    debugPrint("#Mirrorfly call call disconnect called $callList");

    if (callList.isEmpty) {
      debugPrint("call list is empty returning");
      return;
    }
    debugPrint("call list is not empty");
    var index = callList.indexWhere((user) => user.userJid!.value == userJid);
    // debugPrint("#Mirrorfly call disconnected user Index $index ${Get.currentRoute}");
    if (!index.isNegative) {
      // callList.removeAt(index);
      callList.removeWhere((callUser) => callUser.userJid?.value == userJid);
    } else {
      debugPrint("#Mirrorflycall participant jid is not in the list");
    }
    if (callList.length <= 1 || userJid == SessionManagement.getUserJID()) {
      debugPrint("Entering Call Disconnection Loop");
      isCallTimerEnabled = false;
      //if user is in the participants screen all users end the call then we should close call pages
      if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
          Constants.participantView) {
        // Navigator.pop(context);
        MirrorflyUikit.instance.navigationManager
            .navigateBack(context: context);
      }

      if (MirrorflyUikit.instance.navigationManager.hasPrevRoute()) {
        if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
            Constants.onGoingCallView) {
          callTimer("Disconnected");
          Future.delayed(const Duration(seconds: 1), () {
            // Get.back();
            MirrorflyUikit.instance.navigationManager
                .navigateBack(context: context);
          });
        } else {
          // Get.back();
          MirrorflyUikit.instance.navigationManager
              .navigateBack(context: context);
        }
      } else {
        // Get.offNamed(getInitialRoute());
      }

      /*if (Platform.isIOS) {
        // in iOS needs to call disconnect.
        disconnectCall();
      } else {
        if (MirrorflyUikit.instance.navigationManager.routeHistory.isNotEmpty) {
          if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() == Constants.onGoingCallView) {
            callTimer("Disconnected");
            Future.delayed(const Duration(seconds: 1), () {
              MirrorflyUikit.instance.navigationManager.navigateBack(context: context);
            });
          } else {
            MirrorflyUikit.instance.navigationManager.navigateBack(context: context);
          }
        } else {
          //Get.offNamed(getInitialRoute());
          Navigator.pop(context, true);
        }*/
      //Code Changed to above
      /*if (Get.previousRoute.isNotEmpty) {
          if (Get.currentRoute == Routes.onGoingCallView) {
            callTimer("Disconnected");
            Future.delayed(const Duration(seconds: 1), () {
              Get.back();
            });
          } else {
            Get.back();
          }
        } else {
          Get.offNamed(getInitialRoute());
        }*/
    }
  }

  callDisconnectedStatus() {
    debugPrint("callDisconnectedStatus is called");
    callList.clear();
    callTimer("Disconnected");
    backCalledFromDisconnect();
  }

  Future<void> remoteBusy(String callMode, String userJid, String callType,
      String callAction) async {
    // declineCall();
    if (callList.length > 2) {
      var data = await getProfileDetails(userJid);
      toToast("${data.getName()} is Busy");
    } else {
      toToast("User is Busy");
    }

    this.callMode(callMode);
    this.callType(callType);
    debugPrint("onCallAction CallList Length ${callList.length}");
    if (callList.length < 2) {
      disconnectOutgoingCall();
    } else {
      removeUser(callMode, userJid, callType);
    }
  }

  Future<void> remoteOtherBusy(String callMode, String userJid, String callType,
      String callAction) async {
    // this.callMode(callMode);
    //remove the user from the list and update ui
    // users.remove(userJid);//out going call view
    remoteBusy(callMode, userJid, callType, callAction);
  }

  void localHangup(
      String callMode, String userJid, String callType, String callAction) {
    //Commenting to check iOS Crash.
    // callDisconnected(callMode, userJid, callType);
    this.callMode(callMode);
    userDisconnection(callMode, userJid, callType);
  }

  void remoteHangup(
      String callMode, String userJid, String callType, String callAction) {
    // if(callList.isNotEmpty) {
    //   disconnectCall();
    // }
    this.callMode(callMode);
    this.callType(callType);
  }

  void calling(
      String callMode, String userJid, String callType, String callStatus) {
    // this.callStatus(callStatus);
    this.callMode(callMode);
    this.callType(callType);
  }

  void reconnected(
      String callMode, String userJid, String callType, String callStatus) {
    // this.callStatus(callStatus);
    this.callMode(callMode);
    this.callType(callType);
  }

  Future<void> ringing(String callMode, String userJid, String callType,
      String callStatus) async {
    // this.callStatus(callStatus);
    this.callMode(callMode);
    this.callType(callType);
    // this.callStatus(callStatus);
    var isAudioMuted =
        (await Mirrorfly.isUserAudioMuted(userJid: userJid)).checkNull();
    var isVideoMuted =
        (await Mirrorfly.isUserVideoMuted(userJid: userJid)).checkNull();
    var index =
        callList.indexWhere((userList) => userList.userJid!.value == userJid);
    debugPrint("User List Index $index");
    if (index.isNegative) {
      debugPrint("User List not Found, so adding the user to list");
      CallUserList callUserList = CallUserList(
        userJid: userJid.obs,
        callStatus: RxString(callStatus),
        isAudioMuted: isAudioMuted,
        isVideoMuted: isVideoMuted,
      );
      if (callList.length > 1) {
        callList.insert(callList.length - 1, callUserList);
      } else {
        callList.add(callUserList);
      }
    } else {
      callList[index].callStatus?.value = callStatus;
    }
  }

  void onHold(
      String callMode, String userJid, String callType, String callStatus) {
    // this.callStatus(callStatus);
    this.callMode(callMode);
    this.callType(callType);
  }

  Future<void> connected(String callMode, String userJid, String callType,
      String callStatus) async {
    // this.callStatus(callStatus);
    // getNames();
    // startTimer();
    /*Future.delayed(const Duration(milliseconds: 500), () {
      Get.offNamed(Routes.onGoingCallView, arguments: {"userJid": userJid});
    });*/

    this.callMode(callMode);
    this.callType(callType);
    // this.callStatus(callStatus);
    // startTimer();
    if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
            Constants.onGoingCallView &&
        MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
            Constants.participantView) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // Get.offNamed(Routes.onGoingCallView, arguments: {"userJid": [userJid], "cameraSwitch": cameraSwitch.value});

        MirrorflyUikit.instance.navigationManager.navigatePushReplacement(
            context: context,
            pageToNavigate: OnGoingCallView(userJid: [userJid]),
            routeName: Constants.onGoingCallView);
      });
    } else if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
        Constants.participantView) {
      //commenting this for when user reconnected then toast is displayed so no need to display
      // var data = await getProfileDetails(userJid);
      // toToast("${data.getName()} joined the Call");
    } else {
      var isAudioMuted =
          (await Mirrorfly.isUserAudioMuted(userJid: userJid)).checkNull();
      var isVideoMuted =
          (await Mirrorfly.isUserVideoMuted(userJid: userJid)).checkNull();
      var indexValid =
          callList.indexWhere((element) => element.userJid?.value == userJid);
      debugPrint("#MirrorflyCall user jid $userJid");
      CallUserList callUserList = CallUserList(
        userJid: userJid.obs,
        callStatus: RxString(callStatus),
        isAudioMuted: isAudioMuted,
        isVideoMuted: isVideoMuted,
      );
      if (indexValid.isNegative) {
        callList.insert(callList.length - 1, callUserList);
        // callList.add(callUserList);
        debugPrint("#MirrorflyCall List value updated ${callList.length}");
      } else {
        debugPrint(
            "#MirrorflyCall List value not updated due to jid $userJid is already in list ${callList.length}");
      }
    }
  }

  void timeout(
      String callMode, String userJid, String callType, String callStatus) {
    // this.callStatus("Disconnected");
    // Get.back();
    // Navigator.pop(context);
    debugPrint("timeout");
    // MirrorflyUikit.instance.navigationManager.navigateBack(context: context);
    this.callMode(callMode);
    this.callType(callType);
    debugPrint(
        "#Mirrorfly Call timeout callMode : $callMode -- userJid : $userJid -- callType $callType -- callStatus $callStatus -- current route ${Get.currentRoute}");
    if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
        Constants.outGoingCallView) {
      debugPrint("#Mirrorfly Call navigating to Call Timeout");
      // Get.offNamed(Routes.callTimeOutView,
      //     arguments: {"callType": callType, "callMode": callMode, "userJid": users, "calleeName": calleeName.value});
      MirrorflyUikit.instance.navigationManager.navigatePushReplacement(
          context: context,
          pageToNavigate: CallTimeoutView(
              callType: callType,
              callMode: callMode,
              userJid: users,
              calleeName: calleeName.value),
          routeName: Constants.callTimeOutView);
    } else {
      var userJids = userJid.split(",");
      debugPrint("#Mirrorfly Call timeout userJids $userJids");
      for (var jid in userJids) {
        debugPrint("removeUser userJid $jid");
        removeUser(callMode, jid.toString().trim(), callType);
      }
    }
  }

  void disconnectOutgoingCall() {
    isCallTimerEnabled = false;
    Mirrorfly.disconnectCall(flyCallBack: (FlyResponse response) {
      if (response.isSuccess) {
        callList.clear();
        // Get.back();
        MirrorflyUikit.instance.navigationManager
            .navigateBack(context: context);
      }
    });
  }
/*  void declineCall() {
    Mirrorfly.declineCall();
    callList.clear();
    // Get.back();
    MirrorflyUikit.instance.navigationManager.navigateBack(context: context);
  }*/

  void statusUpdate(String userJid, String callStatus) {
    if (callList.isEmpty) {
      debugPrint("skipping statusUpdate as list is empty");
      return;
    }

    debugPrint("statusUpdate $callStatus");
    // var displayStatus = CallStatus.calling;
    var displayStatus = "";
    switch (callStatus) {
      case CallStatus.connected:
        displayStatus = CallStatus.connected;
        break;
      case CallStatus.connecting:
      case CallStatus.ringing:
        displayStatus = CallStatus.ringing;
        break;
      case CallStatus.callTimeout:
        displayStatus = "Unavailable, Try again later";
        break;
      case CallStatus.disconnected:
      case CallStatus.calling:
        displayStatus = CallStatus.calling;
        break;
      case CallStatus.onHold:
        displayStatus = CallStatus.onHold;
        break;
      case CallStatus.attended:
        break;
      case CallStatus.inviteCallTimeout:
        displayStatus = CallStatus.callTimeout;
        break;
      case CallStatus.reconnecting:
        displayStatus = "Reconnecting…";
        break;
      case CallStatus.onResume:
        displayStatus = "Call on Resume";
        break;
      case CallStatus.userJoined:
      case CallStatus.userLeft:
      case CallStatus.reconnected:
        displayStatus = '';
        break;
      case CallStatus.calling10s:
      case CallStatus.callingAfter10s:
        displayStatus = callStatus;
        break;
      default:
        displayStatus = '';
        break;
    }
    if (pinnedUserJid.value == userJid && isGroupCall) {
      this.callStatus(displayStatus);
    } else if (isOneToOneCall) {
      this.callStatus(displayStatus);
    } else {
      debugPrint("isOneToOneCall $isOneToOneCall");
      debugPrint("isGroupCall $isGroupCall");
      debugPrint("Status is not updated");
    }
    if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
        Constants.onGoingCallView) {
      ///update the status of the user in call user list
      var indexOfItem =
          callList.indexWhere((element) => element.userJid!.value == userJid);

      /// check the index is valid or not
      if (!indexOfItem.isNegative && callStatus != CallStatus.disconnected) {
        debugPrint(
            "indexOfItem of call status update $indexOfItem $callStatus");

        /// update the current status of the user in the list
        callList[indexOfItem].callStatus?.value = (callStatus);
      }
    }
  }

  void audioDeviceChanged() {
    getAudioDevices();
    Mirrorfly.selectedAudioDevice().then((value) => audioOutputType(value));
  }

  void getAudioDevices() {
    Mirrorfly.getAllAvailableAudioInput().then((value) {
      final availableList = audioDevicesFromJson(value);
      availableAudioList(availableList);
      debugPrint(
          "${Constants.tag} flutter getAllAvailableAudioInput $availableList");
    });
  }

  Future<void> remoteEngaged(
      String userJid, String callMode, String callType) async {
    var data = await getProfileDetails(userJid);
    toToast(data.getName() + Constants.remoteEngagedToast);

    debugPrint("***call list length ${callList.length}");
//The below condition (<= 2) -> (<2) is changed for Group call, to maintain the call to continue if there is a 2 users in call
    if (callList.length < 2) {
      disconnectOutgoingCall();
    } else {
      removeUser(callMode, userJid, callType);
    }
  }

  void audioMuteStatusChanged(String muteEvent, String userJid) {
    var callUserIndex =
        callList.indexWhere((element) => element.userJid!.value == userJid);
    if (!callUserIndex.isNegative) {
      debugPrint("index $callUserIndex");
      callList[callUserIndex]
          .isAudioMuted(muteEvent == MuteStatus.remoteAudioMute);
    } else {
      debugPrint("#Mirrorfly call User Not Found in list to mute the status");
    }
  }

  void videoMuteStatusChanged(String muteEvent, String userJid) {
    var callUserIndex =
        callList.indexWhere((element) => element.userJid!.value == userJid);
    if (!callUserIndex.isNegative) {
      debugPrint("index $callUserIndex");
      callList[callUserIndex]
          .isVideoMuted(muteEvent == MuteStatus.remoteVideoMute);
    } else {
      debugPrint(
          "#Mirrorfly call User Not Found in list to video mute the status");
    }
  }

  void callDuration(String timer) {
    // callTimer(timer);
    if (callTimer.value != "Disconnected") {
      callTimer(timer);
    }
  }

  var speakingUsers = <SpeakingUsers>[].obs;
  void onUserSpeaking(String userJid, int audioLevel) {
    // LogMessage.d("speakingUsers", "${speakingUsers.length}");
    var index = speakingUsers.indexWhere(
        (element) => element.userJid.toString() == userJid.toString());
    // LogMessage.d("speakingUsers indexWhere", "$index");
    if (index.isNegative) {
      speakingUsers
          .add(SpeakingUsers(userJid: userJid, audioLevel: audioLevel.obs));
      // LogMessage.d("speakingUsers", "added");
    } else {
      speakingUsers[index].audioLevel(audioLevel);
      // LogMessage.d("speakingUsers", "updated");
    }
  }

  int audioLevel(String userJid) {
    var index =
        speakingUsers.indexWhere((element) => element.userJid == userJid);
    var value = index.isNegative ? -1 : speakingUsers[index].audioLevel.value;
    // debugPrint("speakingUsers Audio level $value");
    return value;
  }

  void onUserStoppedSpeaking(String userJid) {
    //adding delay to show better ui
    Future.delayed(const Duration(milliseconds: 300), () {
      var index =
          speakingUsers.indexWhere((element) => element.userJid == userJid);
      if (!index.isNegative) {
        speakingUsers[index].audioLevel(-1);
      }
    });
  }

  void denyCall() {
    if (MirrorflyUikit.instance.navigationManager.getCurrentRoute() ==
        Constants.outGoingCallView) {
      MirrorflyUikit.instance.navigationManager.navigateBack(context: context);
    }
  }

  void onCameraSwitch() {
    LogMessage.d("onCameraSwitch", cameraSwitch.value);
    cameraSwitch(!cameraSwitch.value);
  }

  void changedToAudioCall() {
    // if(Get.isDialogOpen ?? false){
    Navigator.of(Get.overlayContext!).pop();
    // }
    callType(CallType.audio);

    videoMuted(true);
  }

  void closeDialog() {
    Navigator.pop(context);
  }

  var showingVideoSwitchPopup = false;
  var outGoingRequest = false;
  var inComingRequest = false;
  Future<void> showVideoSwitchPopup() async {
    if (await AppPermission.askVideoCallPermissions(context)) {
      showingVideoSwitchPopup = true;
      Helper.showAlert(
          message: Constants.videoSwitchMessage,
          actions: [
            TextButton(
                onPressed: () {
                  outGoingRequest = false;
                  showingVideoSwitchPopup = false;
                  closeDialog();
                },
                child: const Text("CANCEL",
                    style: TextStyle(color: buttonBgColor))),
            TextButton(
                onPressed: () {
                  if (callType.value == CallType.audio &&
                      isOneToOneCall &&
                      MirrorflyUikit.instance.navigationManager
                              .getCurrentRoute() ==
                          Constants.onGoingCallView) {
                    outGoingRequest = true;
                    Mirrorfly.requestVideoCallSwitch().then((value) {
                      if (value) {
                        showingVideoSwitchPopup = false;
                        closeDialog();
                        showWaitingPopup();
                      }
                    });
                  } else {
                    closeDialog();
                  }
                },
                child: const Text("SWITCH",
                    style: TextStyle(color: buttonBgColor)))
          ],
          barrierDismissible: false,
          context: context);
    } else {
      toToast("Camera Permission Needed to switch the call");
    }
  }

  // when request was canceled from requester side
  void videoCallConversionCancel() {
    if (isVideoCallRequested) {
      isVideoCallRequested = false;
      //To Close the Request Popup
      closeDialog();
    }
  }

  void videoCallConversionRequest(String userJid) async {
    inComingRequest = true;
    if (showingVideoSwitchPopup) {
      closeDialog();
    }
    //if both users are made switch request then accept the request without confirmation popup
    LogMessage.d("Both Call Switch Request",
        "inComingRequest : $inComingRequest outGoingRequest : $outGoingRequest");
    if (inComingRequest && outGoingRequest) {
      inComingRequest = false;
      outGoingRequest = false;
      Mirrorfly.acceptVideoCallSwitchRequest().then((value) {
        videoMuted(false);
        callType(CallType.video);
      });
      return;
    }
    var profile = await getProfileDetails(userJid);
    isVideoCallRequested = true;
    Helper.showAlert(
        message:
            "${profile.getName()} ${Constants.videoSwitchRequestedMessage}",
        actions: [
          TextButton(
              onPressed: () {
                isVideoCallRequested = false;
                inComingRequest = false;
                closeDialog();
                Mirrorfly.declineVideoCallSwitchRequest();
              },
              child: const Text("DECLINE",
                  style: TextStyle(color: buttonBgColor))),
          TextButton(
              onPressed: () async {
                closeDialog();
                if (await AppPermission.askVideoCallPermissions(context)) {
                  isVideoCallRequested = false;
                  inComingRequest = false;
                  Mirrorfly.acceptVideoCallSwitchRequest().then((value) {
                    videoMuted(false);
                    callType(CallType.video);
                  });
                } else {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    toToast("Camera Permission Needed to switch the call");
                  });
                  Mirrorfly.declineVideoCallSwitchRequest();
                }
              },
              child:
                  const Text("ACCEPT", style: TextStyle(color: buttonBgColor)))
        ],
        barrierDismissible: false,
        context: context);
  }

  void showWaitingPopup() {
    isWaitingCanceled = false;
    waitingCompleter = Completer<void>();

    Helper.showAlert(
        message: Constants.videoSwitchRequestMessage,
        actions: [
          TextButton(
              onPressed: () {
                isWaitingCanceled = true;
                outGoingRequest = false;
                closeDialog();
                Mirrorfly.cancelVideoCallSwitch();
              },
              child:
                  const Text("CANCEL", style: TextStyle(color: buttonBgColor)))
        ],
        barrierDismissible: false,
        context: context);

    // Wait for 20 seconds or until canceled
    Future.delayed(const Duration(seconds: 20)).then((_) async {
      debugPrint("waiting duration end");
      if (!isWaitingCanceled) {
        outGoingRequest = false;
        closeDialog();
        Mirrorfly.cancelVideoCallSwitch();
        waitingCompleter.complete();
        // Get.back();
        var profile =
            await getProfileDetails(callList.first.userJid!.value.checkNull());
        toToast("No response from ${profile.getName()}");
      }
    });
  }

  void videoCallConversionAccepted() {
    if (Get.isDialogOpen ?? false) {
      Navigator.of(Get.overlayContext!).pop();
    }
    inComingRequest = false;
    outGoingRequest = false;
    if (!waitingCompleter.isCompleted) {
      isWaitingCanceled = true;
      waitingCompleter.complete();
      //To Close the Waiting Popup
      closeDialog();
      videoMuted(false);
      callType(CallType.video);
    }
  }

  void videoCallConversionRejected() {
    toToast("Request Declined");
    inComingRequest = false;
    outGoingRequest = false;
    if (!waitingCompleter.isCompleted) {
      isWaitingCanceled = true;
      waitingCompleter.complete();
      //To Close the Waiting Popup
      closeDialog();
    }
  }

  void onResume(
      String callMode, String userJid, String callType, String callStatus) {
    this.callType(callType);
    this.callMode(callMode);
    // isCallTimerEnabled = true;
  }

  void openParticipantScreen() {
    // Get.toNamed(Routes.participants);
    MirrorflyUikit.instance.navigationManager.navigatePushReplacement(
        context: context,
        pageToNavigate: const ParticipantsView(),
        routeName: Constants.participantView);
  }

  void onUserInvite(String callMode, String userJid, String callType) {
    closeVideoConversationAvailable();
    addParticipants(callMode, userJid, callType);
  }

  void closeVideoConversationAvailable() {
    if (inComingRequest || outGoingRequest || showingVideoSwitchPopup) {
      closeDialog();
    }
    if (!isWaitingCanceled) {
      isWaitingCanceled = true;
      outGoingRequest = false;
    }
    if (inComingRequest) {
      isVideoCallRequested = false;
      inComingRequest = false;
    }
    videoCallConversionCancel();
  }

  void onUserJoined(
      String callMode, String userJid, String callType, String callStatus) {
    // addParticipants(callMode, userJid, callType);
  }

  void addParticipants(String callMode, String userJid, String callType) {
    Mirrorfly.getInvitedUsersList().then((value) async {
      LogMessage.d("callController", " getInvitedUsersList $value");
      if (value.isNotEmpty) {
        var userJids = value;
        for (var jid in userJids) {
          LogMessage.d(
              "callController", "before ${callUserListToJson(callList)}");
          var isAudioMuted =
              (await Mirrorfly.isUserAudioMuted(userJid: jid)).checkNull();
          var isVideoMuted =
              (await Mirrorfly.isUserVideoMuted(userJid: jid)).checkNull();
          var indexValid =
              callList.indexWhere((element) => element.userJid?.value == jid);
          LogMessage.d("callController", "indexValid : $indexValid jid : $jid");
          if (indexValid.isNegative &&
              callList.length != getMaxCallUsersCount) {
            callList.insert(
                callList.length - 1,
                CallUserList(
                    userJid: jid.obs,
                    isAudioMuted: isAudioMuted,
                    isVideoMuted: isVideoMuted,
                    callStatus: CallStatus.calling.obs));
            users.insert(users.length - 1, jid);
            // getNames();
            LogMessage.d(
                "callController", "after ${callUserListToJson(callList)}");
          }
        }
      }
    });
  }

  void onUserLeft(String callMode, String userJid, String callType) {
    if (callList.length > 2 &&
        !callList
            .indexWhere(
                (element) => element.userJid.toString() == userJid.toString())
            .isNegative) {
      //#FLUTTER-1300
      CallUtils.getNameOfJid(userJid).then((value) => toToast("$value Left"));
    }
    removeUser(callMode, userJid, callType);
  }

  void removeUser(String callMode, String userJid, String callType) {
    this.callType(callType);
    debugPrint("before removeUser ${callList.length}");
    debugPrint(
        "before removeUser index ${callList.indexWhere((element) => element.userJid!.value == userJid)}");
    callList.removeWhere((element) {
      debugPrint("removeUser callStatus ${element.callStatus}");
      return element.userJid!.value == userJid;
    });
    users.removeWhere((element) => element == userJid);
    speakingUsers.removeWhere((element) => element.userJid == userJid);
    debugPrint("after removeUser ${callList.length}");
    debugPrint(
        "removeUser ${callList.indexWhere((element) => element.userJid.toString() == userJid)}");
    if (callList.length > 1 && pinnedUserJid.value == userJid) {
      pinnedUserJid(callList[0].userJid!.value);
    }
    userDisconnection(callMode, userJid, callType);
    // getNames();
  }

  void userUpdatedHisProfile(String jid) {
    updateProfile(jid);
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      var callListIndex =
          callList.indexWhere((element) => element.userJid!.value == jid);
      var usersIndex = users.indexWhere((element) => element == jid);
      if (!usersIndex.isNegative) {
        users[usersIndex] = ("");
        users[usersIndex] = (jid);
      }
      if (!callListIndex.isNegative) {
        callList[callListIndex].userJid!("");
        callList[callListIndex].userJid!(jid);
        // callList.refresh();
        // getNames();
      }
    }
  }

  void enterFullScreen() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void exitFullScreen() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  void swap(int index) {
    if (isOneToOneCall && isVideoCall && !videoMuted.value) {
      var itemToReplace =
          callList.indexWhere((y) => y.userJid!.value == pinnedUserJid.value);
      var itemToRemove = callList[index];
      var userJid = itemToRemove.userJid?.value;
      pinnedUserJid(userJid);
      callList.swap(index, itemToReplace);
    }
  }
}
