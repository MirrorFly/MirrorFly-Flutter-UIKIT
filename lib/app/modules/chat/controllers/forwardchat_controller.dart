import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/views/chat_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/dashboard/views/dashboard_view.dart';
import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/main_controller.dart';
import '../../../data/session_management.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/de_bouncer.dart';
import '../../../data/apputils.dart';

class ForwardChatController extends GetxController {
  //main list
  final _mainrecentChats = <RecentChatData>[];
  final _maingroupList = <ProfileDetails>[];
  final _mainuserList = <ProfileDetails>[];

  final _recentChats = <RecentChatData>[].obs;

  set recentChats(List<RecentChatData> value) => _recentChats.value = value;

  List<RecentChatData> get recentChats => _recentChats.take(3).toList();

  final _groupList = List<ProfileDetails>.empty(growable: true).obs;//<Profile>[].obs;

  set groupList(List<ProfileDetails> value) => _groupList.value = value;

  List<ProfileDetails> get groupList => _groupList.take(6).toList();

  var userlistScrollController = ScrollController();
  var scrollable = (!Constants.enableContactSync).obs;
  var isPageLoading = false.obs;
  final _userList = <ProfileDetails>[].obs;

  set userList(List<ProfileDetails> value) => _userList.value = value;

  List<ProfileDetails> get userList => _userList;

  final _search = false.obs;

  set search(value) => _search.value = value;

  bool get search => _search.value;

  final _isSearchVisible = true.obs;

  set isSearchVisible(value) => _isSearchVisible.value = value;

  bool get isSearchVisible => _isSearchVisible.value;

  var selectedJids = <String>[].obs;
  var selectedNames = <String>[].obs;

  var forwardMessageIds = <String>[];

  init(List<String> messageIds){
    debugPrint("messageIds $messageIds");
    forwardMessageIds = messageIds;
    userlistScrollController.addListener(_scrollListener);
    getRecentChatList();
  }


  removeGroupItem() {
    if (recentChats.isNotEmpty && groupList.isNotEmpty) {
      for (var element in recentChats) {
        var groupIndex = groupList.indexWhere((it) => it.jid == element.jid);
        if (!groupIndex.isNegative) {
          _groupList.removeAt(groupIndex);
          _groupList.refresh();
        }
      }
    }
  }

  removeUserItem() {
    if (recentChats.isNotEmpty && userList.isNotEmpty) {
      for (var element in recentChats) {
        var index = userList.indexWhere((it) => it.jid == element.jid);
        if (!index.isNegative) {
          _userList.removeAt(index);
          _userList.refresh();
        }
      }
    }
  }

  _scrollListener() {
    if (userlistScrollController.hasClients) {
      if (userlistScrollController.position.extentAfter <= 0 &&
          isPageLoading.value == false) {
        if (scrollable.value && !searching) {
          //isPageLoading.value = true;
          mirrorFlyLog("scroll", "end");
          pageNum++;
          getUsers(bottom: true);
        }
      }
    }
  }

  void getRecentChatList() {
    Mirrorfly.getRecentChatList(flyCallBack: (FlyResponse response) {
      if(response.isSuccess && response.hasData) {
        var data = recentChatFromJson(response.data);
        if (data.data != null) {
          if (_mainrecentChats.isEmpty) {
            _mainrecentChats.addAll(data.data!);
          }
          var list = data.data!.take(3).toList();
          _recentChats(list);
        }
      }
      getAllGroups();
      getUsers();
    });
  }

  void getAllGroups() {
    Mirrorfly.getAllGroups(flyCallBack: (FlyResponse response) {
      if (response.isSuccess && response.hasData) {
        LogMessage.d("getAllGroups", response);
        var list = profileFromJson(response.data);
        for (var group in list) {
          if(recentChats.indexWhere((element) => element.jid == group.jid).isNegative){
            _maingroupList.add(group);
            _groupList.add(group);
          }
        }
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    searchQuery.dispose();
  }

  var pageNum = 1;
  var searchQuery = TextEditingController(text: Constants.emptyString);
  var searching = false;
  var searchLoading = false.obs;
  var contactLoading = false.obs;

  Future<void> getUsers({bool bottom = false}) async {
    if (await AppUtils.isNetConnected()) {
      if(!bottom)contactLoading(true);
      searching = true;
      callback (FlyResponse response){
        if(response.isSuccess){
          if (response.hasData) {
            var list = userListFromJson(response.data);
            if (list.data != null) {
              for (var user in list.data!) {
                if(recentChats.indexWhere((element) => element.jid == user.jid).isNegative){
                  _mainuserList.add(user);
                  _userList.add(user);
                }
              }
            }
          }
          searching = false;
          contactLoading(false);
        }else{
          searching = false;
          contactLoading(false);
        }
      }
      (!Constants.enableContactSync)
          ? Mirrorfly.getUserList(page: pageNum, search: searchQuery.text.trim().toString(),flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(fetchFromServer: false,flyCallback: callback);
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  void onSearchPressed() {
    _isSearchVisible(false);
  }

  void filterRecentChat() {
    _recentChats.clear();
    var y = 0;
    for (var recentChat in _mainrecentChats) {
      if (recentChat.profileName != null &&
          recentChat.profileName!
              .toLowerCase()
              .contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        if(y<3) {// only add 3 items in recent chat list
          _recentChats.add(recentChat);
          _recentChats.refresh();
          y++;
        }else{
          break;
        }
      }
    }
    filterGroupChat();
    filterUserList();
  }

  void filterGroupChat() {
    _groupList.clear();
    for (var group in _maingroupList) {
      if (group.name != null &&
          group.name!
              .toLowerCase()
              .contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        // add only when group not available in recent chat list
        if(_recentChats.indexWhere((element) => element.jid == group.jid).isNegative) {
          _groupList.add(group);
          _groupList.refresh();
        }
      }
    }
  }

  Future<void> filterUserList() async {
    if (await AppUtils.isNetConnected()) {
      _userList.clear();
      searching = true;
      searchLoading(true);
      callback(FlyResponse response){
        if(response.isSuccess){
          if (response.hasData) {
            var list = userListFromJson(response.data);
            if (list.data != null) {
              list.data?.forEach((user) {
                // add only when user not available in recent chat list
                if(_recentChats.indexWhere((element) => element.jid == user.jid).isNegative) {
                  if (!Constants.enableContactSync) {
                    _userList.add(user);
                  } else {
                    var filter = user.nickName.checkNull().toLowerCase().contains(searchQuery.text.trim().toString().toLowerCase());
                    if(filter) {
                      _userList.add(user);
                    }
                  }
                }
              });
              scrollable((_userList.length == 20 && !Constants.enableContactSync));
            } else {
              scrollable(false);
            }
          }
          searching = false;
          searchLoading(false);
        }else{
          searching = false;
          searchLoading(false);
        }
      }
      (!Constants.enableContactSync)
          ? Mirrorfly.getUserList(page: pageNum, search: searchQuery.text.trim().toString(),flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(fetchFromServer: false,flyCallback: callback);
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  bool isChecked(String jid) => selectedJids.contains(jid);

  void onItemSelect(String jid, String name,bool isBlocked,bool isGroup, BuildContext context) async{
    if(isGroup.checkNull() && !availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    if(isGroup.checkNull() && !(await Mirrorfly.isMemberOfGroup(groupJid: jid, userJid: SessionManagement.getUserJID().checkNull())).checkNull()){
      toToast(AppConstants.youAreNoLonger);
      return;
    }
    if(isBlocked.checkNull()){
      if(context.mounted) {
        unBlock(jid, name, context);
      }
    }else{
      onItemClicked(jid,name);
    }
  }

  unBlock(String jid, String name, BuildContext context,){
    Helper.showAlert(message: "${AppConstants.unblock} $name?", actions: [
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
          },
          child: Text(AppConstants.no.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              // Get.back();
              if(context.mounted) Navigator.pop(context);
              // Helper.progressLoading();
              Mirrorfly.unblockUser(userJid: jid.checkNull(), flyCallBack: (FlyResponse response) {
                // Helper.hideLoading();
                if(response.isSuccess && response.hasData) {
                  toToast("$name ${AppConstants.hasUnBlocked}");
                  userUpdatedHisProfile(jid);
                }
              });
            }else{
              toToast(AppConstants.noInternetConnection);
            }
          },
          child: Text(AppConstants.yes.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
    ], context: context);
  }

  void onItemClicked(String jid, String name) {
    if (selectedJids.contains(jid)) {
      selectedJids.removeAt(selectedJids.indexOf(jid));
      selectedNames.removeAt(selectedNames.indexOf(name));
    } else {
      if (selectedJids.length < 5) {
        selectedJids.add(jid);
        selectedNames.add(name);
      } else {
        toToast(AppConstants.onlyForwardUpTo5);
      }
    }

    _recentChats.refresh();
    _groupList.refresh();
    _userList.refresh();
  }

  final deBouncer = DeBouncer(milliseconds: 700);
  String lastInputValue = Constants.emptyString;

  void onSearch(String search) {
    mirrorFlyLog("search", "onSearch");
    if (lastInputValue != searchQuery.text.toString().trim()) {
      lastInputValue = searchQuery.text.toString().trim();
      if (searchQuery.text.toString().trim().isNotEmpty) {
        debugPrint("cleared not");
        deBouncer.run(() {
          pageNum = 1;
          filterRecentChat();
        });
      } else {
        debugPrint("cleared");
        _recentChats.refresh();
        _groupList.refresh();
        _userList.refresh();
      }
    }
  }

  void backFromSearch() {
    pageNum = 1;
    searchQuery.clear();
    _isSearchVisible(true);
    scrollable((_mainuserList.length == 20 && !Constants.enableContactSync));
    _recentChats(_mainrecentChats.take(3).toList());
    _groupList(_maingroupList);
    _userList(_mainuserList);
  }

  forwardMessages(BuildContext context) async {
    if (await AppUtils.isNetConnected()) {
      var busyStatus = await Mirrorfly.isBusyStatusEnabled();
      if (!busyStatus.checkNull()) {
        if (forwardMessageIds.isNotEmpty && selectedJids.isNotEmpty) {
          if(context.mounted) {
            Helper.showLoading(
                message: "Forward message", buildContext: context);
            Future.delayed(const Duration(milliseconds: 1000), () async {
              await Mirrorfly.forwardMessagesToMultipleUsers(
                  messageIds: forwardMessageIds,
                  userList: selectedJids,
                  flyCallBack: (FlyResponse response) {
                    // debugPrint("to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
                    Helper.hideLoading(context: context);
                    updateLastMessage(selectedJids);
                    // debugPrint("to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (con) => ChatView(jid: selectedJids.last)), (
                        route) => route is DashboardView);
                    // Get.offNamedUntil(Routes.chat,arguments: value, (route){
                    //   LogMessage.d("offNamedUntil",route.settings.name);
                    //   return route.settings.name.toString().startsWith(Routes.dashboard);
                    // });
                  });
            });
          }
        }
      } else {
        //show busy status popup
        // var messageObject = MessageObject(toJid: profile.jid.toString(),replyMessageId: (isReplying.value) ? replyChatMessage.messageId : Constants.emptyString, messageType: Constants.mText,textMessage: messageController.text);
        //showBusyStatusAlert(disableBusyChatAndSend());
      }
    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  void updateLastMessage(List<String> chatJid){
    //below method is used when message is not sent and onMessageStatusUpdate listener will not trigger till the message status was updated so notify the ui in dashboard
    for (var element in chatJid) {
      Get.find<MainController>().onUpdateLastMessageUI(element);
    }
  }

  Future<String> getParticipantsNameAsCsv(String jid) async {
    var groupParticipantsName = Constants.emptyString;
    await Mirrorfly.getGroupMembersList(jid: jid, fetchFromServer: false, flyCallBack: (FlyResponse response) {
      if (response.isSuccess && response.hasData) {
        var str = <String>[];
        var groupsMembersProfileList = memberFromJson(response.data);
        for (var it in groupsMembersProfileList) {
          //if (it.jid.checkNull() != SessionManagement.getUserJID().checkNull()) {
          str.add(it.name.checkNull());
          //}
        }
        return groupParticipantsName = (str.join(","));
      }
    });
    return groupParticipantsName;
  }

  void userUpdatedHisProfile(String jid) {
    if (jid.toString().isNotEmpty) {
      updateRecentChatAdapter(jid);
      updateProfile(jid);
    }
  }

  Future<void> updateRecentChatAdapter(String jid) async {
    var index = _recentChats.indexWhere((element) =>
        element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
    var mainIndex = _mainrecentChats.indexWhere((element) =>
        element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
    if (jid.isNotEmpty) {
      var recent = await getRecentChatOfJid(jid);
      if (recent != null) {
        if (!index.isNegative) {
          _recentChats[index] = recent;
        }
        if (!mainIndex.isNegative) {
          _mainrecentChats[mainIndex] = recent;
        }
      }
    }
  }

  Future<void> updateProfile(String jid) async {
    var maingroupListIndex =
        _maingroupList.indexWhere((element) => element.jid == jid);
    var mainuserListIndex =
        _mainuserList.indexWhere((element) => element.jid == jid);
    var groupListIndex =
        _groupList.indexWhere((element) => element.jid == jid);
    var userListIndex = _userList.indexWhere((element) => element.jid == jid);
    getProfileDetails(jid).then((value) {
      if (!maingroupListIndex.isNegative) {
        _maingroupList[maingroupListIndex] = value;
      }
      if (!mainuserListIndex.isNegative) {
        _mainuserList[mainuserListIndex] = value;
      }
      if (!groupListIndex.isNegative) {
        _groupList[groupListIndex] = value;
      }
      if (!userListIndex.isNegative) {
        _userList[userListIndex] = value;
      }
    });
  }

  void onContactSyncComplete(bool result) {
    getRecentChatList();
    if (searchQuery.text.toString().trim().isNotEmpty) {
      lastInputValue='';
      onSearch(searchQuery.text.toString());
    }
  }

  void checkContactSyncPermission() {
    Permission.contacts.isGranted.then((value) {
      if(!value){
        _mainuserList.clear();
        _userList.clear();
        _userList.refresh();
      }
    });
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  var availableFeatures = Get.find<MainController>().availableFeature;
  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("Forward", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }
}
