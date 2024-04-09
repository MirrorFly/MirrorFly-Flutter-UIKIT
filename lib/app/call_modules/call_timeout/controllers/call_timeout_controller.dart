import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/permissions.dart';
import '../../outgoing_call/outgoing_call_view.dart';

class CallTimeoutController extends GetxController {
  var callType = ''.obs;
  var callMode = ''.obs;
  // var userJID = ''.obs;
  var calleeName = ''.obs;
  // Rx<Profile> profile = Profile().obs;

  var users = <String?>[].obs;
  var groupId = ''.obs;
  late BuildContext context;
  @override
  Future<void> onInit() async {
    super.onInit();

    /*  callType(Get.arguments["callType"]);
    callMode(Get.arguments["callMode"]);
    users.value = (Get.arguments["userJid"] as List<String?>);
    calleeName(Get.arguments["calleeName"]);*/
  }

  Future<void> initCallController(
      {required BuildContext buildContext,
      required userJid,
      required String callType,
      required String callMode,
      required String calleeName}) async {
    context = buildContext;
    enterFullScreen();
    groupId(await Mirrorfly.getCallGroupJid());
    this.callType(callType);
    this.callMode(callMode);
    users(userJid);
    this.calleeName(calleeName);
  }

  @override
  void dispose() {
    super.dispose();
    exitFullScreen();
  }

  void cancelCallTimeout() {
    Get.back();
  }

  callAgain() async {
    // Get.offNamed(Routes.outGoingCallView, arguments: {"userJid": userJID.value});
    if (await AppUtils.isNetConnected()) {
      if (callType.value == Constants.audioCall) {
        if (await AppPermission.askAudioCallPermissions(context)) {
          if (users.length == 1) {
            Mirrorfly.makeVoiceCall(
                toUserJid: users.first!,
                flyCallBack: (FlyResponse response) {
                  // Get.offNamed(
                  //     Routes.outGoingCallView, arguments: {"userJid": users});
                  MirrorflyUikit.instance.navigationManager.navigateTo(
                      context: context,
                      pageToNavigate: OutGoingCallView(userJid: users),
                      routeName: 'outgoing_call_view',
                      onNavigateComplete: () {});
                });
          } else {
            var usersList = <String>[];
            for (var element in users) {
              if (element != null) {
                usersList.add(element);
              }
            }
            Mirrorfly.makeGroupVoiceCall(
                toUserJidList: usersList,
                flyCallBack: (FlyResponse response) {
                  /*Get.offNamed(
                  Routes.outGoingCallView, arguments: {"userJid": users});*/

                  MirrorflyUikit.instance.navigationManager.navigateTo(
                      context: context,
                      pageToNavigate: OutGoingCallView(userJid: users),
                      routeName: 'outgoing_call_view',
                      onNavigateComplete: () {});
                });
          }
        } else {
          debugPrint("permission not given");
        }
      } else {
        if (await AppPermission.askVideoCallPermissions(context)) {
          if (users.length == 1) {
            Mirrorfly.makeVideoCall(
                toUserJid: users.first!,
                flyCallBack: (FlyResponse response) {
                  if (response.isSuccess) {
                    /*Get.offNamed(
                    Routes.outGoingCallView, arguments: {"userJid": users});*/
                    MirrorflyUikit.instance.navigationManager.navigateTo(
                        context: context,
                        pageToNavigate: OutGoingCallView(userJid: users),
                        routeName: 'outgoing_call_view',
                        onNavigateComplete: () {});
                  }
                });
          } else {
            var usersList = <String>[];
            for (var element in users) {
              if (element != null) {
                usersList.add(element);
              }
            }
            Mirrorfly.makeGroupVideoCall(
                toUserJidList: usersList,
                flyCallBack: (FlyResponse response) {
                  /*Get.offNamed(
                  Routes.outGoingCallView, arguments: {"userJid": users});*/
                  MirrorflyUikit.instance.navigationManager.navigateTo(
                      context: context,
                      pageToNavigate: OutGoingCallView(userJid: users),
                      routeName: 'outgoing_call_view',
                      onNavigateComplete: () {});
                });
          }
        } else {
          LogMessage.d("askVideoCallPermissions", "false");
        }
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  void userUpdatedHisProfile(String jid) {
    updateProfile(jid);
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      var callListIndex = users.indexWhere((element) => element == jid);
      if (!callListIndex.isNegative) {
        users[callListIndex] = jid;
        users.refresh();
      }
    }
  }

  void enterFullScreen() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void exitFullScreen() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }
}
