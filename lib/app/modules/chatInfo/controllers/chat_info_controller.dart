import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

import '../../../common/constants.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import '../../../models.dart';
import '../../view_all_media/views/view_all_media_view.dart';

class ChatInfoController extends GetxController {
  var profile_ = Profile().obs;
  Profile get profile => profile_.value;
  var mute = false.obs;
  var nameController = TextEditingController();

  ScrollController scrollController = ScrollController();

  var silverBarHeight = 20.0;
  final _isSliverAppBarExpanded = true.obs;
  set isSliverAppBarExpanded(value) => _isSliverAppBarExpanded.value = value;
  bool get isSliverAppBarExpanded => _isSliverAppBarExpanded.value;

  final muteable = false.obs;
  var userPresenceStatus = ''.obs;

  /*@override
  void onInit() {
    super.onInit();
    profile_((Get.arguments as Profile));
  }*/

  init(String jid){
    getProfileDetails(jid,server: false).then((value) {
      profile_(value);
      mute(profile.isMuted!);
      scrollController.addListener(_scrollListener);
      nameController.text = profile.nickName.checkNull();
      muteAble();
      getUserLastSeen();
    });
  }

  muteAble() async {
    muteable(await Mirrorfly.isUserUnArchived(profile.jid.checkNull()));
  }

  _scrollListener() {
    if (scrollController.hasClients) {
      _isSliverAppBarExpanded(
          scrollController.offset < (silverBarHeight - kToolbarHeight));
    }
  }

  void userUpdatedHisProfile(jid) {
    if (jid.isNotEmpty && jid == profile.jid) {
      getProfileDetails(jid).then((value) {
        profile_(value);
        mute(profile.isMuted!);
        nameController.text = profile.nickName.checkNull();
      });
    }

  }

  onToggleChange(bool value) {
    if(muteable.value) {
      mirrorFlyLog("change", value.toString());
      mute(value);
      Mirrorfly.updateChatMuteStatus(profile.jid.checkNull(), value);
    }
  }

  getUserLastSeen(){
    if(!profile.isBlockedMe.checkNull() || !profile.isAdminBlocked.checkNull()) {
      Mirrorfly.getUserLastSeenTime(profile.jid.toString()).then((value) {
        var lastSeen = convertSecondToLastSeen(value!);
        userPresenceStatus(lastSeen.toString());
      }).catchError((er) {
        userPresenceStatus("");
      });
    }else{
      userPresenceStatus("");
    }
  }


  void userCameOnline(jid) {
    debugPrint("userCameOnline : $jid");
    if(jid.isNotEmpty && profile.jid == jid && !profile.isGroupProfile.checkNull()) {
      debugPrint("userCameOnline jid match: $jid");
      Future.delayed(const Duration(milliseconds: 3000),(){
        getUserLastSeen();
      });
    }
  }

  void userWentOffline(jid) {
    if(jid.isNotEmpty && profile.jid==jid && !profile.isGroupProfile.checkNull()) {
      debugPrint("userWentOffline : $jid");
      Future.delayed(const Duration(milliseconds: 3000),(){
        getUserLastSeen();
      });
    }
  }

  void networkConnected() {
    mirrorFlyLog("networkConnected", 'true');
    Future.delayed(const Duration(milliseconds: 2000), () {
      getUserLastSeen();
    });
  }

  void networkDisconnected() {
    mirrorFlyLog('networkDisconnected', 'false');
    getUserLastSeen();
  }

  reportChatOrUser(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Helper.showAlert(
          title: "Report ${profile.name}?",
          message:
              "The last 5 messages from this contact will be forwarded to admin. This Contact will not be notified.",
          actions: [
            TextButton(
                onPressed: () {
                  // Get.back();
                  Navigator.pop(context);
                  // Helper.showLoading(message: "Reporting User");
                  Mirrorfly
                      .reportUserOrMessages(profile.jid!, "chat")
                      .then((value) {
                    // Helper.hideLoading();
                    if(value.checkNull()){
                      toToast("Report sent");
                    }else{
                      toToast("There are no messages available");
                    }

                    // debugPrint(value.toString());
                  }).catchError((onError) {
                    debugPrint(onError.toString());
                  });
                },
                child: const Text("REPORT",style: TextStyle(color: Colors.red),)),
            TextButton(
                onPressed: () {
                  // Get.back();
                  Navigator.pop(context);
                },
                child: Text("CANCEL",style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))),
          ], context: context);
    });
  }

  gotoViewAllMedia(BuildContext context){
    // debugPrint("to Media Page==>${profile.name} jid==>${profile.jid} isgroup==>${profile.isGroupProfile ?? false}");
    Navigator.push(context, MaterialPageRoute(builder: (con)=>ViewAllMediaView(name:profile.name.checkNull(),jid:profile.jid.checkNull(),isGroup:profile.isGroupProfile.checkNull())));
    // Get.toNamed(Routes.viewMedia,arguments: {"name":profile.name,"jid":profile.jid,"isgroup":profile.isGroupProfile ?? false});
  }

  void onContactSyncComplete(bool result) {
    userUpdatedHisProfile(profile.jid);
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  void unblockedThisUser(String jid) {
    userUpdatedHisProfile(jid);
  }

  void userBlockedMe(String jid) {
    userUpdatedHisProfile(jid);
  }
}
