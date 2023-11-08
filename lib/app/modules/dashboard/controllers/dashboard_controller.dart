import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/model/recent_chat.dart';
import 'package:mirrorfly_plugin/model/recent_search_model.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/views/chat_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/settings_view.dart';
import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../models.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';

import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/de_bouncer.dart';
import '../../../data/apputils.dart';
import '../../../data/permissions.dart';
import '../../chat/views/contact_list_view.dart';
import '../../chatInfo/views/chat_info_view.dart';
import '../../group/views/group_creation_view.dart';
import '../../group/views/group_info_view.dart';

class DashboardController extends FullLifeCycleController
    with FullLifeCycleMixin, GetTickerProviderStateMixin {
  var recentChats = <RecentChatData>[].obs;
  var archivedChats = <RecentChatData>[].obs;
  var calendar = DateTime.now();
  var selectedChats = <String>[].obs;
  var selectedChatsPosition = <int>[].obs;
  var selected = false.obs;

  var profile_ = Profile().obs;

  Profile get profile => profile_.value;

  //action icon visibles
  var archive = false.obs;
  var pin = false.obs;
  var unpin = false.obs;
  var mute = false.obs;
  var unmute = false.obs;
  var read = false.obs;
  var unread = false.obs;
  var delete = false.obs;
  var info = false.obs;
  var shortcut = false.obs;

  var archiveSettingEnabled = false.obs;

  late bool showChatDeliveryIndicator;

/*@override
  void onInit() {
    super.onInit();
    recentChats.bindStream(recentChats.stream);
    ever(recentChats, (callback) => unReadCount());
    archivedChats.bindStream(archivedChats.stream);
    ever(archivedChats, (callback) => archivedChatCount());
    getRecentChatList();
    getArchivedChatsList();
    checkArchiveSetting();
    userlistScrollController.addListener(_scrollListener);
  }*/

  @override
  void onHidden() {
    // Your implementation here
  }

  @override
  void onReady(){
    super.onReady();
    recentChats.bindStream(recentChats.stream);
    ever(recentChats, (callback) => unReadCount());
    archivedChats.bindStream(archivedChats.stream);
    ever(archivedChats, (callback) => archivedChatCount());
    // getRecentChatList();
    getArchivedChatsList();
    // checkArchiveSetting();
    userlistScrollController.addListener(_scrollListener);
  }

  infoPage(BuildContext context,Profile profile) {
    if (profile.isGroupProfile ?? false) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (con) =>
                  GroupInfoView(jid: profile.jid.checkNull())));
      /*Get.toNamed(Routes.groupInfo, arguments: profile)?.then((value) {
        if (value != null) {
          // profile_(value as Profile);
          // isBlocked(profile.isBlocked);
          // checkAdminBlocked();
          // memberOfGroup();
          // Mirrorfly.setOnGoingChatUser(profile.jid!);
          // getChatHistory();
          // sendReadReceipt();
        }
      });*/
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (con) => ChatInfoView(jid: profile.jid.checkNull())));
      // Get.toNamed(Routes.chatInfo, arguments: profile)?.then((value) {});
    }
  }

  checkArchiveSetting() {
    Mirrorfly.isArchivedSettingsEnabled()
        .then((value) => archiveSettingEnabled(value));
  }

  Future<RecentChatData?> getRecentChatOfJid(String jid) async {
    var value = await Mirrorfly.getRecentChatOf(jid);
    // mirrorFlyLog("chat", value.toString());
    if (value != null) {
      var data = RecentChatData.fromJson(json.decode(value));
      return data;
    } else {
      return null;
    }
  }

  var recentChatLoading = true.obs;

  getRecentChatList() {
    mirrorFlyLog(Constants.emptyString, "recent chats");
    try {
      Mirrorfly.getRecentChatList().then((value) async {
        // String recentList = value.replaceAll('\n', '\\n');
        // debugPrint(recentList);
        // var data = await compute(recentChatFromJson, value.toString());
        var data = recentChatFromJson(value.toString());
        ///removing recent chat item if the recent chat has a self chat
        data.data?.removeWhere((chat) => chat.jid == SessionManagement.getUserJID());

        //recentChats.clear();
        recentChats(data.data!);

        recentChats.refresh();
        recentChatLoading(false);
      }).catchError((error) {
        debugPrint("recent chat issue===> $error");
        recentChatLoading(false);
      });
    } catch (e, s) {
      debugPrint("Error while fetching recent chats $s");
    }
  }

  getArchivedChatsList() async {
    await Mirrorfly.getArchivedChatList().then((value) {
      mirrorFlyLog("archived", value.toString());
      if (value != null) {
        var data = recentChatFromJson(value);

        ///removing recent chat item if the recent chat has a self chat
        data.data?.removeWhere((chat) => chat.jid == SessionManagement.getUserJID());

        archivedChats(data.data!);
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  toChatPage(BuildContext context,String jid) async {
    if (jid.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (con)=>ChatView(jid: jid, showChatDeliveryIndicator: showChatDeliveryIndicator,)));
      // Helper.progressLoading();
      /*await Mirrorfly.getProfileDetails(jid, false).then((value) {
        if (value != null) {
          Helper.hideLoading();
          // debugPrint("Dashboard Profile===>$value");
          var profile = profiledata(value.toString());
          Get.toNamed(Routes.chat, arguments: profile);
        }
      });*/
      // SessionManagement.setChatJid(jid);
      // Get.toNamed(Routes.chat);
    }
  }

  String getTime(int? timestamp) {
    DateTime now = DateTime.now();
    final DateTime date1 = timestamp == null
        ? now
        : DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('hh:mm a').format(date1); //yyyy-MM-dd –
    return formattedDate;
  }

  logout() {
    SessionManagement.clear();
    // Get.offAllNamed(Routes.login);
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
    var hours = calendar.hour;
    calendar = messageDate;
    var dateHourFormat = setDateHourFormat(format, hours);
    return DateFormat(dateHourFormat).format(messageDate);
  }

  String setDateHourFormat(int format, int hours) {
    var dateHourFormat = (format == 12)
        ? (hours < 10)
        ? "hh:mm aa"
        : "h:mm aa"
        : (hours < 10)
        ? "HH:mm"
        : "H:mm";
    return dateHourFormat;
  }


  final _unreadCount = 0.obs;

  String get unreadCountString => returnFormattedCount(_unreadCount.value);

  set unreadCount(int val) => _unreadCount.value = val;

  unReadCount() {
    _unreadCount(0);
    recentPinnedCount(0);
    for (var p0 in recentChats) {
      if (p0.isConversationUnRead!) {
        _unreadCount(((p0.isConversationUnRead!)
            ? 1 + _unreadCount.value
            : 0 + _unreadCount.value));
      }
      if (p0.isChatPinned.checkNull()) {
        recentPinnedCount(recentPinnedCount.value + 1);
      }
    }
    /*mirrorFlyLog("recentPinned", recentChats.where((element) => (element.isChatPinned.checkNull()==true)).join(","));
    recentPinnedCount(recentChats.where((element) => (element.isChatPinned.checkNull()==true)).length);*/
  }

  final _archivedCount = 0.obs;

  String get archivedCount => returnFormattedCount(_archivedCount.value);

  archivedChatCount() {
    _archivedCount(0);
    for (var p0 in archivedChats) {
      if (p0.isConversationUnRead!) {
        _archivedCount(((p0.isConversationUnRead!)
            ? 1 + _archivedCount.value
            : 0 + _archivedCount.value));
      }
    }
  }

  updateRecentChat(String jid) {
    //updateArchiveRecentChat(jid);
    getRecentChatOfJid(jid).then((recent) {
      final index = recentChats.indexWhere((chat) => chat.jid == jid);
      debugPrint("dashboard index--> $index");
      if (recent != null) {
        if (!recent.isChatArchived.checkNull()) {
          if (index.isNegative) {
            recentChats.insert(0, recent);
          } else {
            var lastPinnedChat =
            recentChats.lastIndexWhere((element) => element.isChatPinned!);
            var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
            if (recentChats[index].isChatPinned!) {
              recentChats.removeAt(index);
              recentChats.insert(index, recent);
            } else {
              recentChats.removeAt(index);
              recentChats.insert(nxtIndex, recent);
              recentChats.refresh();
            }
          }
        } else {
          if (!index.isNegative) {
            recentChats.removeAt(index);
          }
        }
        checkArchiveList(recent);
      } else {
        if (!index.isNegative) {
          recentChats.removeAt(index);
        }
      }
      recentChats.refresh();
    });
  }

  updateArchiveRecentChat(String jid) {
    mirrorFlyLog("archived chat update", jid);
    getRecentChatOfJid(jid).then((recent) {
      final index = archivedChats.indexWhere((chat) => chat.jid == jid);
      if (recent != null) {
        //if(recent.isChatArchived.checkNull()) {
        if (index.isNegative) {
          archivedChats.insert(0, recent);
        } else {
          var lastPinnedChat =
          archivedChats.lastIndexWhere((element) => element.isChatPinned!);
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
        /*}else{
          if (!index.isNegative) {
            archivedChats.removeAt(index);
          }
          checkArchiveList(recent);
        }*/
      } else {
        if (!index.isNegative) {
          archivedChats.removeAt(index);
        }
      }
      archivedChats.refresh();
    });
  }

  void checkArchiveList(RecentChatData recent) async {
    Mirrorfly.isArchivedSettingsEnabled().then((value) {
      if (value.checkNull()) {
        var archiveIndex =
        archivedChats.indexWhere((element) => recent.jid == element.jid);
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          archivedChats.insert(0, recent);
        } else {
          if (recent.isChatArchived.checkNull()) {
            archivedChats.insert(0, recent);
          }
        }
      } else {
        var archiveIndex =
        archivedChats.indexWhere((element) => recent.jid == element.jid);
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          /*var lastPinnedChat = recentChats.lastIndexWhere((element) =>
          element.isChatPinned!);
          var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
          mirrorFlyLog("lastPinnedChat", lastPinnedChat.toString());
          recentChats.insert(nxtIndex, recent);*/
        }
      }
    });
  }

  Future<ChatMessageModel?> getMessageOfId(String mid) async {
    var value = await Mirrorfly.getMessageOfId(mid);
    // mirrorFlyLog("getMessageOfId recent", value.toString());
    if (value != null) {
      var data = ChatMessageModel.fromJson(json.decode(value.toString()));
      return data;
    } else {
      return null;
    }
  }

  webLogin() {
    /*if (SessionManagement.getWebLogin()) {
      Future.delayed(const Duration(milliseconds: 100),
          () => Get.toNamed(Routes.webLoginResult));
    } else {
      Future.delayed(
          const Duration(milliseconds: 100), () => Get.toNamed(Routes.scanner));
    }*/
  }

  var isSearching = false.obs;

  gotoSearch() {
    isSearching(true);
    // frmRecentChatList(recentChats);
    /*Future.delayed(const Duration(milliseconds: 100), () {
      Get.toNamed(Routes.recentSearch, arguments: {"recents": recentChats});
    });*/
  }

  gotoCreateGroup(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100),
            () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupCreationView())));
  }

  gotoSettings(BuildContext context) {
    Future.delayed(
        const Duration(milliseconds: 100), () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsView()),
    ));
  }

  chatInfo(BuildContext context) {
    var chatIndex = recentChats.indexWhere((element) =>
    selectedChats.first == element.jid); //selectedChatsPosition[index];
    var item = recentChats[chatIndex];
    // Helper.progressLoading(context: context);
    clearAllChatSelection();
    // getProfileDetails(item.jid.checkNull()).then((value) {
      if (item.jid != null) {
        // Helper.hideLoading(context: context);
        // var profile = profiledata(value.toString());
        if (item.isGroup!) {
          Future.delayed(const Duration(milliseconds: 100),
                  () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (con) =>
                          GroupInfoView(jid: item.jid.checkNull()))));//Get.toNamed(Routes.groupInfo, arguments: profile));
        } else {
          Future.delayed(const Duration(milliseconds: 100),
                  () =>  Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (con) => ChatInfoView(jid: item.jid.checkNull()))));//Get.toNamed(Routes.chatInfo, arguments: profile));
        }
      }
    // });
  }

  isSelected(int index) => selectedChats.contains(recentChats[index].jid);

  selectOrRemoveChatfromList(int index) {
    if (selected.isTrue) {
      if (selectedChats.contains(recentChats[index].jid)) {
        selectedChats.remove(recentChats[index].jid.checkNull());
        selectedChatsPosition.remove(index);
      } else {
        selectedChats.add(recentChats[index].jid.checkNull());
        selectedChatsPosition.add(index);
      }
    }
    if (selectedChats.isEmpty) {
      clearAllChatSelection();
    } else {
      menuValidationForItem();
    }
  }

  clearAllChatSelection() {
    selected(false);
    selectedChats.clear();
    selectedChatsPosition.clear();
    archive(false);
    pin(false);
    unpin(false);
    mute(false);
    unmute(false);
    read(false);
    unread(false);
    delete(false);
    info(false);
    shortcut(false);
    update();
  }

  menuValidationForPinIcon() {
    var checkListForPinIcon = <bool>[];
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      checkListForPinIcon.add(value.isChatPinned!);
    }
    if (checkListForPinIcon.contains(false)) {
      //pin able
      pin(true);
      unpin(false);
    } else {
      pin(false);
      unpin(true);
    }
    //return checkListForPinIcon.contains(false);//pin able
  }

  menuValidationForDeleteIcon() async {
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var item in selected) {
      var isMember = await Mirrorfly.isMemberOfGroup(item.jid.checkNull(), null);
      if ((item.getChatType() == Constants.typeGroupChat) && isMember!) {
        delete(false);
        return;
        //return false;
      }
    }
    //return true;
    delete(true);
  }

  menuValidationForMuteUnMuteIcon() {
    var checkListForMuteUnMuteIcon = <bool>[];
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      if (!value.isBroadCast!) {
        checkListForMuteUnMuteIcon.add(value.isMuted.checkNull());
      }
    }
    if (checkListForMuteUnMuteIcon.contains(false)) {
      // Mute able
      mute(true);
      unmute(false);
    } else if (checkListForMuteUnMuteIcon.contains(true)) {
      mute(false);
      unmute(true);
    } else {
      mute(false);
      unmute(false);
    }
    //return checkListForMuteUnMuteIcon.contains(false);// Mute able
  }

  menuValidationForMarkReadUnReadIcon() {
    var checkListForReadUnReadIcon = <bool>[];
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      checkListForReadUnReadIcon.add(value.isConversationUnRead.checkNull());
    }
    if (!checkListForReadUnReadIcon.contains(true)) {
      //Mark as Read Able
      read(false);
      unread(true);
    } else {
      read(true);
      unread(false);
    }
    //return !checkListForReadUnReadIcon.contains(true);//Mark as Read Able
  }

  menuValidationForItem() {
    mirrorFlyLog("selectedChats", selectedChats.length.toString());
    archive(true);
    if (selectedChats.length == 1) {
      var item = recentChats
          .firstWhere((element) => selectedChats.first == element.jid);
      info(true);
      pin(!item.isChatPinned!);
      unpin(item.isChatPinned!);
      if (Constants.typeBroadcastChat != item.getChatType()) {
        unmute(item.isMuted!);
        mute(!item.isMuted!);
        shortcut(true);
      } else {
        unmute(false);
        mute(false);
        shortcut(false);
      }
      read(item.isConversationUnRead);
      unread(!item.isConversationUnRead!);
      delete(Constants.typeGroupChat != item.getChatType());
      if (item.getChatType() == Constants.typeGroupChat) {
        mirrorFlyLog("isGroup", item.isGroup!.toString());
        Mirrorfly.isMemberOfGroup(item.jid.checkNull(), null)
            .then((value) => delete(!value!));
      }
    } else {
      info(false);
      menuValidationForPinIcon();
      /*var pinValid = menuValidationForPinIcon();
      pin(pinValid);
      unpin(!pinValid);*/
      menuValidationForMuteUnMuteIcon();
      /*var muteValid = menuValidationForMuteUnMuteIcon();
      mute(muteValid);
      unmute(!muteValid);*/
      menuValidationForMarkReadUnReadIcon();
      /*var readValid = menuValidationForMarkReadUnReadIcon();
      read(readValid);
      unread(!readValid);*/
      menuValidationForDeleteIcon(); //.then((value) => delete(value));
    }
  }

  var recentPinnedCount = 0.obs;

  pinChats() {
    if (isSelectedPositionsValidForPin()) {
      mirrorFlyLog("pinChat", "isSelectedPositionsValidForPin");
      if (selectedChats.length == 1) {
        _itemPin(0);
        clearAllChatSelection();
        toToast(AppConstants.chatPinned);
      } else {
        selected(false);
        for (var index = 0; index < selectedChats.length; index++) {
          var selectedChat = recentChats.indexWhere((p0) =>
          p0.jid == selectedChats[index] && p0.isChatPinned.checkNull());
          if (selectedChat.isNegative) {
            mirrorFlyLog(
                "pinChat", "$selectedChat selected chat is have to pinned");
            _itemPin(index);
          } else {
            mirrorFlyLog(
                "pinChat", "$selectedChat selected chat is already pinned");
          }
        }
        clearAllChatSelection();
        toToast(AppConstants.chatsPinned);
      }
    } else {
      toToast(AppConstants.pinUpTo3);
    }
  }

  bool isSelectedPositionsValidForPin() {
    var pinnedListPosition = selectedChats;
    var validPositions = 0; //selected non pinned items
    // mirrorFlyLog("selectedchats", pinnedListPosition.join(","));
    // mirrorFlyLog("recentPinnedCount", recentPinnedCount.toString());
    for (var value in pinnedListPosition) {
      var valid = recentChats
          .firstWhere((p0) => p0.jid == value); // check, is non pinned item
      if (!valid.isChatPinned.checkNull()) {
        validPositions = validPositions + 1;
      }
    }
    /*for (position in pinnedListPosition) {
      if (position >= recentPinnedCount) // check, is non pinned item
        validPositions++;
    }*/
    //mirrorFlyLog("validPositions", "$validPositions");
    var count = recentPinnedCount.value + validPositions;
    if (count <= 3) {
      return true;
    }
    var count2 = recentPinnedCount.value + pinnedListPosition.length;
    if (count2 <= 3) {
      return true;
    }
    return false;
  }

  unPinChats() {
    if (selectedChats.length == 1) {
      _itemUnPin(0);
      clearAllChatSelection();
      toToast(AppConstants.chatUnPinned);
    } else {
      selected(false);
      selectedChats.asMap().forEach((key, value) {
        _itemUnPin(key);
      });
      clearAllChatSelection();
      toToast(AppConstants.chatsUnPinned);
    }
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

  markAsRead() {
    if (selectedChats.length == 1) {
      _itemUnMute(0);
      clearAllChatSelection();
      toToast(AppConstants.chatMarkedAsRead);
    } else {
      selected(false);
      selectedChats.asMap().forEach((key, value) {
        _itemUnMute(key);
      });
      clearAllChatSelection();
      toToast(AppConstants.chatsMarkedAsRead);
    }
  }

  archiveChats() async {
    if (await AppUtils.isNetConnected()) {
      if (selectedChats.length == 1) {
        _itemArchive(0);
        clearAllChatSelection();
        toToast(AppConstants.chatArchived);
      } else {
        var count = selectedChats.length;
        selected(false);
        selectedChats.asMap().forEach((key, value) {
          _itemArchive(key);
        });
        clearAllChatSelection();
        toToast('$count ${AppConstants.chatsArchived}');
      }
    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  deleteChats(BuildContext context) {
    if (selectedChats.length == 1) {
      _itemDelete(0, context);
    } else {
      itemsDelete(context);
    }
  }

  _itemPin(int index) {
    Mirrorfly.updateRecentChatPinStatus(selectedChats[index], true);
    var chatIndex = recentChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    //recentChats[chatIndex].isChatPinned=(true);
    var change = recentChats[chatIndex];
    change.isChatPinned = true;
    recentChats.removeAt(chatIndex);
    recentChats.insert(0, change);
  }

  _itemUnPin(int index) {
    Mirrorfly.updateRecentChatPinStatus(selectedChats[index], false);
    var chatIndex = recentChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    //recentChats[chatIndex].isChatPinned=(false);
    var lastPinnedChat =
    recentChats.lastIndexWhere((element) => element.isChatPinned!);
    mirrorFlyLog("lastPinnedChat", lastPinnedChat.toString());
    var nxtIndex = lastPinnedChat.isNegative ? chatIndex : (lastPinnedChat);
    var change = recentChats[chatIndex];
    change.isChatPinned = false;
    recentChats.removeAt(chatIndex);
    recentChats.insert(nxtIndex, change);
  }

  _itemMute(int index) {
    Mirrorfly.updateChatMuteStatus(selectedChats[index], true);
    var chatIndex = recentChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    recentChats[chatIndex].isMuted = (true);
  }

  _itemUnMute(int index) {
    var chatIndex = recentChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    recentChats[chatIndex].isMuted = (false);
    Mirrorfly.updateChatMuteStatus(selectedChats[index], false);
  }

  /*_itemRead(int index){
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    recentChats[chatIndex].isMuted=(false);
    Mirrorfly.markAsRead(selectedChats[index]);
    updateUnReadChatCount();
  }*/

  itemsRead() async {
    if (await AppUtils.isNetConnected()) {
      selected(false);
      Mirrorfly.markConversationAsRead(selectedChats);
      var count = selectedChatsPosition.length;
      for (var element in selectedChatsPosition) {
        recentChats[element].isConversationUnRead = false;
        recentChats[element].unreadMessageCount = 0;
      }
      clearAllChatSelection();
      updateUnReadChatCount();
      // toToast("Chat${count > 1 ? 's' : ''} marked as read");
      if(count > 1){
        toToast(AppConstants.chatsMarkedAsRead);
      }else{
        toToast(AppConstants.chatMarkedAsRead);
      }

    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  itemsUnRead() {
    selected(false);
    Mirrorfly.markConversationAsUnread(selectedChats);
    for (var element in selectedChatsPosition) {
      recentChats[element].isConversationUnRead = true;
    }
    //toToast("Chat${selectedChats.length == 1 ? Constants.emptyString : "s"} marked as unread");
    if(selectedChats.length > 1){
      toToast(AppConstants.chatsMarkedAsUnRead);
    }else{
      toToast(AppConstants.chatMarkedAsUnRead);
    }
    clearAllChatSelection();
    updateUnReadChatCount();
  }

  _itemArchive(int index) {
    Mirrorfly.updateArchiveUnArchiveChat(selectedChats[index], true);
    var chatIndex = recentChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    recentChats[chatIndex].isChatArchived = (true);
    //getArchivedChatsList();
    if (archivedChats.isEmpty) {
      archivedChats([recentChats[chatIndex]]);
    } else {
      archivedChats.add(recentChats[chatIndex]);
    }
    recentChats.removeAt(chatIndex);
  }

  _itemDelete(int index, BuildContext context) {
    var chatIndex = recentChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    Helper.showAlert(
        message: "${AppConstants.deleteChatWith} \"${recentChats[chatIndex].profileName}\"?",
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Get.back();
              },
              child: Text(AppConstants.no,style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Get.back();
                Mirrorfly.deleteRecentChat(selectedChats[index]).then((value) {
                  clearAllChatSelection();
                  recentChats.removeAt(chatIndex);
                  updateUnReadChatCount();
                });
              },
              child: Text(AppConstants.yes,style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))),
        ], context: context);
  }

  itemsDelete(BuildContext context) {
    Helper.showAlert(
        message: "${AppConstants.delete} ${selectedChatsPosition.length} ${AppConstants.selectedChats}?",
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Get.back();
              },
              child: Text(AppConstants.no,style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Get.back();
                Mirrorfly.deleteRecentChats(selectedChats).then((value) {
                  for (var chatItem in selectedChats) {
                    var chatIndex = recentChats
                        .indexWhere((element) => chatItem == element.jid);
                    recentChats.removeAt(chatIndex);
                  }
                  updateUnReadChatCount();
                  clearAllChatSelection();
                });
              },
              child: Text(AppConstants.yes,style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))),
        ], context: context);
  }

  updateUnReadChatCount() {
    /*Mirrorfly.getUnreadMessagesCount().then((value){
      if(value!=null) {
        _unreadCount(value);
      }
    });*/
    unReadCount();
  }

  void onMessageReceived(chatMessageModel) {
    mirrorFlyLog("dashboard controller", "onMessageReceived");

    updateRecentChat(chatMessageModel.chatUserJid);
  }

  void onMessageStatusUpdated(ChatMessageModel chatMessageModel) {
    final index = recentChats.indexWhere(
            (message) => message.lastMessageId == chatMessageModel.messageId);
    debugPrint("Message Status Update index of search $index");
    if (!index.isNegative) {
      // updateRecentChat(chatMessageModel.chatUserJid);
      recentChats[index].lastMessageStatus = chatMessageModel.messageStatus.value;
      recentChats.refresh();
    }
  }

  void onGroupProfileUpdated(groupJid) {
    mirrorFlyLog("super", groupJid.toString());
    updateRecentChat(groupJid);
  }

  void onDeleteGroup(groupJid) {
    updateRecentChat(groupJid);
  }

  void onGroupDeletedLocally(groupJid) {
    updateRecentChat(groupJid);
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

  /* //Moved to Base Controller
  void onAdminBlockedUser(String jid, bool status) {
    mirrorFlyLog("dash onAdminBlockedUser", "$jid, $status");
    Get.find<MainController>().handleAdminBlockedUser(jid, status);
  }*/

  void userUpdatedHisProfile(String jid) {
    updateRecentChatAdapter(jid);
    updateRecentChatAdapterSearch(jid);
    updateProfileSearch(jid);
  }

  Future<void> updateRecentChatAdapter(String jid) async {
    if (jid.isNotEmpty) {
      var index = recentChats.indexWhere((element) =>
      element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
      debugPrint("updateRecentChatAdapter $index");
      var recent = await getRecentChatOfJid(jid);
      debugPrint("updateRecentChatAdapter getRecentChatOfJid ${recent?.toJson().toString()}");
      if (recent != null) {
        if (!index.isNegative) {
          recentChats[index] = recent;
        }
      }
    }
  }

  //search
  // var frmRecentChatList = <RecentChatData>[].obs;
  var recentSearchList = <Rx<RecentSearch>>[].obs;
  var filteredRecentChatList = <RecentChatData>[].obs;
  RxList<ChatMessageModel> chatMessages = <ChatMessageModel>[].obs;
  final deBouncer = DeBouncer(milliseconds: 700);
  TextEditingController search = TextEditingController();
  var searchFocusNode = FocusNode();
  String lastInputValue = Constants.emptyString;
  RxBool clearVisible = false.obs;
  final _mainuserList = <Profile>[];
  var userlistScrollController = ScrollController();
  var scrollable = MirrorflyUikit.instance.isTrialLicenceKey.obs;
  var isPageLoading = false.obs;
  final _userList = <Profile>[].obs;

  set userList(List<Profile> value) => _userList.value = value;

  List<Profile> get userList => _userList;

  onChange(String inputValue) {
    if (search.text.trim().isNotEmpty) {
      clearVisible(true);
    } else {
      clearVisible(false);
      recentChats.refresh();
    }
    if (lastInputValue != search.text.trim()) {
      lastInputValue = search.text.trim();
      searchLoading(true);
      // frmRecentChatList.clear();
      recentSearchList.clear();
      if (search.text.trim().isNotEmpty) {
        deBouncer.run(() {
          pageNum = 1;
          fetchRecentChatList();
          fetchMessageList();
          filterUserList();
        });
      } else {
        mirrorFlyLog("empty", "empty");
        // frmRecentChatList.addAll(recentChats);
      }
    }
    update();
  }

  onClearPressed() {
    filteredRecentChatList.clear();
    chatMessages.clear();
    userList.clear();
    search.clear();
    clearVisible(false);
    // frmRecentChatList(recentChats);
  }

  var pageNum = 1;
  var searching = false;
  var searchLoading = false.obs;

  Future<void> filterUserList() async {
    if (await AppUtils.isNetConnected()) {
      searching = true;
      var future = (MirrorflyUikit.instance.isTrialLicenceKey)
          ? Mirrorfly.getUserList(pageNum, search.text.trim().toString())
          : Mirrorfly.getRegisteredUsers(true);
      future.then((value) {
        // Mirrorfly.getUserList(pageNum, search.text.trim().toString()).then((value) {
        if (value != null) {
          var list = userListFromJson(value);
          if (list.data != null) {
            if (MirrorflyUikit.instance.isTrialLicenceKey) {
              scrollable(list.data!.length == 20);

              list.data!.removeWhere((element){
                debugPrint("filter chat list--> ${!filteredRecentChatList.indexWhere((recentChatItem) => recentChatItem.jid == element.jid.checkNull()).isNegative}");
                return !filteredRecentChatList.indexWhere((recentChatItem) => recentChatItem.jid == element.jid.checkNull()).isNegative; });
              _userList(list.data);
            } else {
              _userList(list.data!
                  .where((element) =>
              (element.nickName.checkNull().toLowerCase().contains(search.text.trim().toString().toLowerCase())) &&
                  !filteredRecentChatList.indexWhere((recentChatItem) => recentChatItem.jid != element.jid.checkNull()).isNegative).toList());
              // scrollable(false);
            }
          } else {
            scrollable(false);
          }
        }
        searching = false;
        searchLoading(false);
      }).catchError((error) {
        debugPrint("issue===> $error");
        searching = false;
        searchLoading(false);
      });
    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  fetchRecentChatList() async {
    debugPrint("========fetchRecentChatList======");
    await Mirrorfly.getRecentChatListIncludingArchived().then((value) {
      var recentChatList = <RecentChatData>[];
      var js = json.decode(value);
      var recentChatListWithArchived =
      List<RecentChatData>.from(js.map((x) => RecentChatData.fromJson(x)));
      for (var recentChat in recentChatListWithArchived) {
        if (recentChat.profileName != null &&
            recentChat.profileName!
                .toLowerCase()
                .contains(search.text.trim().toString().toLowerCase()) ==
                true && recentChat.jid != SessionManagement.getUserJID()) {
          recentChatList.add(recentChat);
        }
      }
      filteredRecentChatList(recentChatList);
      update(filteredRecentChatList);
    });
    //fetchMessageList();
  }

  fetchMessageList() async {
    await Mirrorfly.searchConversation(search.text.trim().toString())
        .then((value) {
      mirrorFlyLog("flutter search", value);
      var result = chatMessageModelFromJson(value);
      chatMessages(result);
      var mRecentSearchList = <Rx<RecentSearch>>[].obs;
      // var i = 0.obs;
      for (var message in result) {
        var searchMessageItem = RecentSearch(
            jid: message.chatUserJid,
            mid: message.messageId,
            searchType: AppConstants.typeSearchMessage,
            chatType: message.messageChatType.toString(),
            isSearch: true)
            .obs;
        mRecentSearchList.insert(0, searchMessageItem);
        // i++;
      }
      /*var map = <Rx<int>, RxList<Rx<RecentSearch>>>{}; //{0,searchMessageItem};
      map.putIfAbsent(i, () => mRecentSearchList).obs;
      filteredMessageList(map);
      update();*/
    });
  }

  Future<Map<Profile?, ChatMessageModel?>?> getProfileAndMessage(
      String jid, String mid) async {
    var value =
    await getProfileDetails(jid); //Mirrorfly.getProfileLocal(jid, false);
    var value2 = await Mirrorfly.getMessageOfId(mid);
    if (value.jid !=null && value2 != null) {
      var data = value; //profileDataFromJson(value);
      var data2 = sendMessageModelFromJson(value2);
      var map = <Profile?, ChatMessageModel?>{}; //{0,searchMessageItem};
      map.putIfAbsent(data, () => data2);
      return map;
    }
    return null;
  }

  void getBackFromSearch() {
    searchFocusNode.unfocus();
    onClearPressed();
    clearVisible(false);
    isSearching(false);
  }

  _scrollListener() {
    if (userlistScrollController.hasClients) {
      if (userlistScrollController.position.extentAfter <= 0 &&
          isPageLoading.value == false) {
        if (scrollable.value && !searching) {
          //isPageLoading.value = true;
          mirrorFlyLog("scroll", "end");
          pageNum++;
          getUsers();
        }
      }
    }
  }

  Future<void> getUsers() async {
    if (await AppUtils.isNetConnected()) {
      searching = true;
      Mirrorfly.getUserList(pageNum, search.text.trim().toString()).then((value) {
        if (value != null) {
          var list = userListFromJson(value);
          if (list.data != null) {
            if (_mainuserList.isEmpty) {
              _mainuserList.addAll(list.data!);
            }
            scrollable(list.data!.length == 20);
            _userList.addAll(list.data!);
            _userList.refresh();
          } else {
            scrollable(false);
          }
        }
        searching = false;
      }).catchError((error) {
        debugPrint("issue===> $error");
        searching = false;
      });
    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  Future<void> updateRecentChatAdapterSearch(String jid) async {
    if (jid.isNotEmpty) {
      var filterIndex = filteredRecentChatList.indexWhere((element) =>
      element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
      /*var frmIndex = frmRecentChatList.indexWhere((element) =>
      element.jid ==
          jid);*/ // { it.jid ?: Constants.EMPTY_STRING == jid }
      var recent = await getRecentChatOfJid(jid);
      if (recent != null) {
        if (!filterIndex.isNegative) {
          filteredRecentChatList[filterIndex] = recent;
        }
        /*if (!frmIndex.isNegative) {
          frmRecentChatList[frmIndex] = recent;
        }*/
      }
    }
  }

  Future<void> updateProfileSearch(String jid) async {
    debugPrint("updateProfileSearch jid $jid");
    if (jid.isNotEmpty) {
      var userListIndex = _userList.indexWhere((element) => element.jid == jid);
      debugPrint("userListIndex $userListIndex");
      getProfileDetails(jid).then((value) {
        debugPrint("get profile detail dashboard $value");
        if(value.jid !=null) {
          profile_(value);
          if (!userListIndex.isNegative) {
            _userList[userListIndex] = value;
          }
        }
      });
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {
    if (!KeyboardVisibilityController().isVisible) {
      if (searchFocusNode.hasFocus) {
        searchFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          searchFocusNode.requestFocus();
        });
      }
    }
    checkContactSyncPermission();
  }

  void getProfileDetail(context, RecentChatData chatItem, int index) {
    getProfileDetails(chatItem.jid.checkNull()).then((value) {
      if(value.jid!=null) {
        profile_(value);
        debugPrint("dashboard controller profile update received");
        showQuickProfilePopup(
            context: context,
            // chatItem: chatItem,
            chatTap: () {
              Navigator.pop(context);
              // Get.back();
              if (selected.value) {
                selectOrRemoveChatfromList(index);
              } else {
                toChatPage(context, chatItem.jid.checkNull());
              }
            },
            callTap: () {},
            videoTap: () {},
            infoTap: () {
              Navigator.pop(context);
              // Get.back();
              infoPage(context, value);
            },
            profile: profile_);
      }
    });
  }

  Future<void> gotoContacts(BuildContext context) async {
    if (MirrorflyUikit.instance.isTrialLicenceKey) {
      // Get.toNamed(Routes.contacts, arguments: {"forward": false, "group": false, "groupJid": Constants.emptyString});
      Navigator.push(context, MaterialPageRoute(builder: (con)=>const ContactListView()));
    } else {
      var contactPermissionHandle = await AppPermission.checkPermission(context,
          Permission.contacts,
          contactPermission,
          AppConstants.contactSyncPermission);
      if (contactPermissionHandle) {
        if(context.mounted)Navigator.push(context, MaterialPageRoute(builder: (con)=>const ContactListView()));
        /*Get.toNamed(Routes.contacts,
            arguments: {"forward": false, "group": false, "groupJid": Constants.emptyString});*/
      }
    }
  }

  void onContactSyncComplete(bool result) {
    getRecentChatList();
    getArchivedChatsList();
    // filterUserlist();
    mirrorFlyLog('isSearching.value', isSearching.value.toString());
    if (isSearching.value) {
      lastInputValue = '';
      onChange(search.text.toString());
    }
  }

  void checkContactSyncPermission() {
    Permission.contacts.isGranted.then((value) {
      if (!value) {
        _userList.clear();
        _userList.refresh();
      }
    });
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }


  void userBlockedMe(String jid) {
    userUpdatedHisProfile(jid);
  }

  void unblockedThisUser(String jid) {
    userUpdatedHisProfile(jid);
  }
}
