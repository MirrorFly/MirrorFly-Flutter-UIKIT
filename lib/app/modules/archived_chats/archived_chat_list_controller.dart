import 'package:flutter/material.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/model/available_features.dart';
import 'package:mirrorfly_plugin/model/callback.dart';
import 'package:mirrorfly_plugin/model/recent_chat.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/views/chat_view.dart';
import '../../../mirrorfly_uikit_plugin.dart';
import '../../common/main_controller.dart';
import '../../data/session_management.dart';
import '../../models.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';

import '../../data/apputils.dart';
import '../../data/helper.dart';
import '../chatInfo/views/chat_info_view.dart';
import '../group/views/group_info_view.dart';
import '../../common/extensions.dart';

class ArchivedChatListController extends GetxController {
  RxList<RecentChatData> archivedChats = <RecentChatData>[].obs;//Get.find<DashboardController>().archivedChats;

  late final bool showChatDeliveryIndicator;
  //RxList<RecentChatData> archivedChats = <RecentChatData>[].obs;

  @override
  void onInit(){
    super.onInit();
    //archivedChats(dashboardController.archivedChats);
    getArchivedSettingsEnabled();
  }
  final archiveEnabled = true.obs;
  Future<void> getArchivedSettingsEnabled() async {
    await Mirrorfly.isArchivedSettingsEnabled().then((value) => archiveEnabled(value));
  }

  getArchivedChatsList() async {
    await Mirrorfly.getArchivedChatList(flyCallBack: (FlyResponse response) {
      mirrorFlyLog("archived response", response.toString());
      if (response.isSuccess && response.hasData) {
        var data = recentChatFromJson(response.data);
        archivedChats(data.data!);
      } else {
        debugPrint("Archive list is empty");
      }
    });
  }

  var selected = false.obs;
  var selectedChats = <String>[].obs;
  var selectedChatsPosition = <int>[].obs;

  isSelected(int index) => selectedChats.contains(archivedChats[index].jid);

  selectOrRemoveChatFromList(int index) {
    if (selected.isTrue) {
      if (selectedChats.contains(archivedChats[index].jid)) {
        selectedChats.remove(archivedChats[index].jid.checkNull());
        selectedChatsPosition.remove(index);
      } else {
        selectedChats.add(archivedChats[index].jid.checkNull());
        selectedChatsPosition.add(index);
      }
    }
    if (selectedChats.isEmpty) {
      clearAllChatSelection();
    } else {
      menuValidationForItem();
    }
  }

  menuValidationForItem() {
    // delete(false);
    if (selectedChats.length == 1) {
      var item = archivedChats
          .firstWhere((element) => selectedChats.first == element.jid);
      // delete(Constants.typeGroupChat != item.getChatType());
      menuValidationForDeleteIcon();
      if ((Constants.typeBroadcastChat != item.getChatType()&& !archiveEnabled.value)) {
        unMute(item.isMuted!);
        mute(!item.isMuted!);
        // shortcut(true);
        debugPrint("item.isMuted! ${item.isMuted!}");
      } else {
        unMute(false);
        mute(false);
        // shortcut(false);
      }
    } else {
      menuValidationForDeleteIcon();
      if(!archiveEnabled.value) {
        menuValidationForMuteUnMuteIcon();
      }
    }
  }

  clearAllChatSelection() {
    selected(false);
    selectedChats.clear();
    selectedChatsPosition.clear();
    update();
  }

  var typingAndGoneStatus = <Triple>[].obs;

  String typingUser(String jid) {
    var index =
        typingAndGoneStatus.indexWhere((it) => it.singleOrgroupJid == jid);
    if (index.isNegative) {
      return Constants.emptyString;
    } else {
      return typingAndGoneStatus[index].userId.isNotEmpty
          ? typingAndGoneStatus[index].userId
          : typingAndGoneStatus[index].singleOrgroupJid;
    }
  }

  void setTypingStatus(
      String singleOrgroupJid, String userId, String typingStatus) {
    var index = typingAndGoneStatus.indexWhere(
        (it) => it.singleOrgroupJid == singleOrgroupJid && it.userId == userId);
    if (typingStatus.toLowerCase() == Constants.composing) {
      if (index.isNegative) {
        typingAndGoneStatus.insert(0, Triple(singleOrgroupJid, userId, true));
      }
    } else {
      if (!index.isNegative) {
        typingAndGoneStatus.removeAt(index);
      }
    }
  }

  toChatPage(String jid,bool isGroup, BuildContext context) async {
    if (jid.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (con)=>ChatView(jid: jid,showChatDeliveryIndicator: showChatDeliveryIndicator,)));
      
    }
  }

  _itemUnArchive(int index) {
    Mirrorfly.setChatArchived(jid: selectedChats[index], isArchived: false, flyCallBack: (_) {  });
    var chatIndex =
    archivedChats.indexWhere((element) => selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats[chatIndex].isChatArchived = (false);
    archivedChats.removeAt(chatIndex);
  }

  Future<void> unArchiveSelectedChats() async {
    if (await AppUtils.isNetConnected()) {
      if (selectedChats.length == 1) {
        _itemUnArchive(0);
        clearAllChatSelection();
        toToast(AppConstants.chatUnArchived);
      } else {
        selected(false);
        var count = selectedChats.length;
        selectedChats.asMap().forEach((key, value) {
          _itemUnArchive(key);
        });
        clearAllChatSelection();
        toToast("$count ${AppConstants.chatsUnArchived}");
      }
    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  void checkArchiveList(RecentChatData recent) async {
    Mirrorfly.isArchivedSettingsEnabled().then((value) {
      if (value.checkNull()) {
        var archiveIndex =
            archivedChats.indexWhere((element) => recent.jid == element.jid);
        mirrorFlyLog("checkArchiveList", "$archiveIndex");
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          archivedChats.insert(0, recent);
          archivedChats.refresh();
        } else {
          archivedChats.insert(0, recent);
          archivedChats.refresh();
        }
      } else {
        var archiveIndex =
            archivedChats.indexWhere((element) => recent.jid == element.jid);
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          /*var lastPinnedChat = dashboardController.recentChats.lastIndexWhere((element) =>
          element.isChatPinned!);
          var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
          mirrorFlyLog("lastPinnedChat", lastPinnedChat.toString());
          dashboardController.recentChats.insert(nxtIndex, recent);*/
        }
      }
    });
  }

  void onMessageReceived(ChatMessageModel chatMessage) {
    updateArchiveRecentChat(chatMessage.chatUserJid);
  }

  void onMessageStatusUpdated(ChatMessageModel chatMessageModel) {
    // mirrorFlyLog("MESSAGE STATUS UPDATED", event);
    updateArchiveRecentChat(chatMessageModel.chatUserJid);
  }

  Future<RecentChatData?> getRecentChatOfJid(String jid) async {
    var value = await Mirrorfly.getRecentChatOf(jid: jid);
    mirrorFlyLog("chat", value.toString());
    if (value.isNotEmpty) {
      var data = recentChatDataFromJson(value);
      return data;
    } else {
      return null;
    }
  }

  updateArchiveRecentChat(String jid) {
    mirrorFlyLog("checkArchiveList", jid);
    getRecentChatOfJid(jid).then((recent) {
      final index = archivedChats.indexWhere((chat) => chat.jid == jid);
      if (recent != null) {
        /*if(!recent.isChatArchived.checkNull()) {
          if (index.isNegative) {
            archivedChats.insert(0, recent);
          } else {
            var lastPinnedChat = archivedChats.lastIndexWhere((element) =>
            element.isChatPinned!);
            var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
            if (archivedChats[index].isChatPinned!) {
              archivedChats.removeAt(index);
              archivedChats.insert(index, recent);
            } else {
              archivedChats.removeAt(index);
              archivedChats.insert(nxtIndex, recent);
              archivedChats.refresh();
            }
          }
        }else{
          if (!index.isNegative) {
            archivedChats.removeAt(index);
          }
          checkArchiveList(recent);
        }*/
        checkArchiveList(recent);
      } else {
        if (!index.isNegative) {
          archivedChats.removeAt(index);
        }
      }
      archivedChats.refresh();
    });
  }

  var delete = false.obs;

  menuValidationForDeleteIcon() async {
    var selected = archivedChats.where((p0) => selectedChats.contains(p0.jid));
    for (var item in selected) {
      var isMember = await Mirrorfly.isMemberOfGroup(groupJid: item.jid.checkNull(), userJid: SessionManagement.getUserJID().checkNull());
      if ((item.getChatType() == Constants.typeGroupChat) && isMember!) {
        delete(false);
        return;
        //return false;
      }
    }
    delete(true);
    //return true;
  }

  var mute = false.obs;
  var unMute = false.obs;
  menuValidationForMuteUnMuteIcon() {
    var checkListForMuteUnMuteIcon = <bool>[];
    var selected = archivedChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      if (!value.isBroadCast!) {
        checkListForMuteUnMuteIcon.add(value.isMuted.checkNull());
      }
    }
    if (checkListForMuteUnMuteIcon.contains(false)) {
      // Mute able
      mute(true);
      unMute(false);
    } else if (checkListForMuteUnMuteIcon.contains(true)) {
      mute(false);
      unMute(true);
    } else {
      mute(false);
      unMute(false);
    }
    //return checkListForMuteUnMuteIcon.contains(false);// Mute able
  }

  muteChats() {
    if (selectedChats.length == 1) {
      _itemMute(0);
      clearAllChatSelection();
    } else {
      selected(false);
      selectedChats.asMap().forEach((key, value) {
        _itemMute(key);
      });
      clearAllChatSelection();
    }
  }

  unMuteChats() {
    if (selectedChats.length == 1) {
      _itemUnMute(0);
      clearAllChatSelection();
    } else {
      selected(false);
      selectedChats.asMap().forEach((key, value) {
        _itemUnMute(key);
      });
      clearAllChatSelection();
    }
  }

  _itemMute(int index) {
    Mirrorfly.updateChatMuteStatus(jid: selectedChats[index], muteStatus: true);
    var chatIndex = archivedChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats[chatIndex].isMuted = (true);
  }

  _itemUnMute(int index) {
    var chatIndex = archivedChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats[chatIndex].isMuted = (false);
    Mirrorfly.updateChatMuteStatus(jid: selectedChats[index], muteStatus: false);
  }

  deleteChats(BuildContext context) {
    String? profile = Constants.emptyString;
    profile = archivedChats
        .firstWhere((element) => selectedChats.first == element.jid)
        .profileName;
    Helper.showAlert(
        title: selectedChats.length == 1
            ? "${AppConstants.deleteChatWith} $profile?"
            : "${AppConstants.delete} ${selectedChats.length} ${AppConstants.selectedChats}?",
        actions: [
          TextButton(
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
              },
              child: Text(AppConstants.no.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
          TextButton(
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
                if (selectedChats.length == 1) {
                  _itemDelete(0);
                } else {
                  itemsDelete();
                }
              },
              child: Text(AppConstants.yes.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
        ],
        message: Constants.emptyString, context: context);
  }

  _itemDelete(int index) {
    var chatIndex = archivedChats.indexWhere((element) =>
        selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats.removeAt(chatIndex);
    Mirrorfly.deleteRecentChats(jidList: [selectedChats[index]], flyCallBack: (_) {  });
    //Mirrorfly.updateArchiveUnArchiveChat(selectedChats[index], false);
    clearAllChatSelection();
  }

  itemsDelete() {
    // debugPrint('selectedChatsPosition : ${selectedChatsPosition.join(',')}');
    Mirrorfly.deleteRecentChats(jidList: selectedChats, flyCallBack: (_) {});
    for (var element in selectedChats) {
      archivedChats.removeWhere((e) => e.jid == element);
    }
    clearAllChatSelection();
  }

  void userUpdatedHisProfile(String jid) {
    updateRecentChatAdapter(jid);
  }

  Future<void> updateRecentChatAdapter(String jid) async {
    if (jid.isNotEmpty) {
      var index = archivedChats.indexWhere((element) =>
          element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
      if (!index.isNegative) {
        var recent = await getRecentChatOfJid(jid);
        if (recent != null) {
          archivedChats[index] = recent;
        }
      }
    }
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
    updateProfile(jid);
  }
  var profile_ = ProfileDetails().obs;
  void getProfileDetail(context, RecentChatData chatItem, int index) {
    getProfileDetails(chatItem.jid.checkNull()).then((value) {
      profile_(value);
      debugPrint("dashboard controller profile update received");
      showQuickProfilePopup(
          context: context,
          // chatItem: chatItem,
          chatTap: () {
            Navigator.pop(context);
            toChatPage(chatItem.jid.checkNull(),chatItem.isGroup.checkNull(),context);
          },
          callTap: () {},
          videoTap: () {},
          infoTap: () {
            Navigator.pop(context);
            infoPage(context,value);
          },
          profile: profile_, availableFeatures: availableFeatures);
    });
  }
  void updateProfile(String jid){
    if(profile_.value.jid != null && profile_.value.jid.toString() == jid.toString()) {
      getProfileDetails(jid).then((value) {
        debugPrint("get profile detail archived $value");
        profile_(value);
      });
    }
  }
  infoPage(BuildContext context,ProfileDetails profile) {
    if (profile.isGroupProfile ?? false) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (con) =>
                  GroupInfoView(jid: profile.jid.checkNull())));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (con) => ChatInfoView(jid: profile.jid.checkNull())));
    }
  }
  var availableFeatures = Get.find<MainController>().availableFeature;
  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("ArchivedChat", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }

  void onMessageEdited(ChatMessageModel editedChatMessage) {
    updateArchiveRecentChat(editedChatMessage.chatUserJid);
  }
}
