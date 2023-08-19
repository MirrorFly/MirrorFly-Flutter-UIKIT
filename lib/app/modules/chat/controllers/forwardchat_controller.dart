import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/AppConstants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../data/session_management.dart';
import '../../../models.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/de_bouncer.dart';
import '../../../data/apputils.dart';

class ForwardChatController extends GetxController {
  //main list
  final _mainrecentChats = <RecentChatData>[];
  final _maingroupList = <Profile>[];
  final _mainuserList = <Profile>[];

  final _recentChats = <RecentChatData>[].obs;

  set recentChats(List<RecentChatData> value) => _recentChats.value = value;

  List<RecentChatData> get recentChats => _recentChats.take(3).toList();

  final _groupList = List<Profile>.empty(growable: true).obs;//<Profile>[].obs;

  set groupList(List<Profile> value) => _groupList.value = value;

  List<Profile> get groupList => _groupList.take(6).toList();

  var userlistScrollController = ScrollController();
  var scrollable = MirrorflyUikit.instance.isTrialLicenceKey.obs;
  var isPageLoading = false.obs;
  final _userList = <Profile>[].obs;

  set userList(List<Profile> value) => _userList.value = value;

  List<Profile> get userList => _userList;

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
    getAllGroups();
    getUsers();
    //
    _recentChats.bindStream(_recentChats.stream);
    ever(_recentChats, (callback) {
      removeGroupItem();
    });
    _groupList.bindStream(_groupList.stream);
    ever(_groupList, (callback) {
      removeGroupItem();
    });
    _userList.bindStream(_userList.stream);
    ever(_userList, (callback) {
      removeUserItem();
    });
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
    Mirrorfly.getRecentChatList().then((value) {
      var data = recentChatFromJson(value);

      ///removing recent chat item if the recent chat has a self chat
      data.data?.removeWhere((chat) => chat.jid == SessionManagement.getUserJID());

      if (_mainrecentChats.isEmpty) {
        _mainrecentChats.addAll(data.data!);
      }
      _recentChats(data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  void getAllGroups() {
    Mirrorfly.getAllGroups().then((value) {
      debugPrint("getall groups $value");
      if (value != null) {
        var list = profileFromJson(value);
        if (_maingroupList.isEmpty) {
          _maingroupList.addAll(list);
        }
        _groupList(list);
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
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
      var future = (MirrorflyUikit.instance.isTrialLicenceKey)
          ? Mirrorfly.getUserList(pageNum, searchQuery.text.trim().toString())
          : Mirrorfly.getRegisteredUsers(false);
      future
      // Mirrorfly.getUserList(pageNum, searchQuery.text.trim().toString())
          .then((value) {
        if (value != null) {
          var list = userListFromJson(value);
          if (list.data != null) {
            if (_mainuserList.isEmpty) {
              _mainuserList.addAll(list.data!);
            }
            _userList.addAll(list.data!);
            _userList.refresh();
          }
        }
        searching = false;
        contactLoading(false);
      }).catchError((error) {
        debugPrint("issue===> $error");
        searching = false;
        contactLoading(false);
      });
    } else {
      toToast(AppConstants.noInternetConnection);
    }
  }

  void onSearchPressed() {
    _isSearchVisible(false);
  }

  void filterRecentChat() {
    _recentChats.clear();
    for (var recentChat in _mainrecentChats) {
      if (recentChat.profileName != null &&
          recentChat.profileName!
                  .toLowerCase()
                  .contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        _recentChats.add(recentChat);
        _recentChats.refresh();
      }
    }
  }

  void filterGroupChat() {
    _groupList.clear();
    for (var group in _maingroupList) {
      if (group.name != null &&
          group.name!
                  .toLowerCase()
                  .contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        _groupList.add(group);
        _groupList.refresh();
      }
    }
  }

  Future<void> filterUserList() async {
    if (await AppUtils.isNetConnected()) {
      _userList.clear();
      searching = true;
      searchLoading(true);
      var future = (MirrorflyUikit.instance.isTrialLicenceKey)
          ? Mirrorfly.getUserList(pageNum, searchQuery.text.trim().toString())
          : Mirrorfly.getRegisteredUsers(false);
      future
      // Mirrorfly.getUserList(pageNum, searchQuery.text.trim().toString())
          .then((value) {
        if (value != null) {
          var list = userListFromJson(value);
          if (list.data != null) {
            scrollable((list.data!.length == 20 && MirrorflyUikit.instance.isTrialLicenceKey));
            if(MirrorflyUikit.instance.isTrialLicenceKey) {
              _userList(list.data);
            }else{
              _userList(list.data!.where((element) => element.nickName.checkNull().toLowerCase().contains(searchQuery.text.trim().toString().toLowerCase())).toList());
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

  bool isChecked(String jid) => selectedJids.contains(jid);

  void onItemSelect(String jid, String name,bool isBlocked, BuildContext context){
    if(isBlocked.checkNull()){
      unBlock(jid,name, context);
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
              Mirrorfly.unblockUser(jid.checkNull()).then((value) {
                // Helper.hideLoading();
                if(value!=null && value.checkNull()) {
                  toToast("$name ${AppConstants.hasUnBlocked}");
                  userUpdatedHisProfile(jid);
                }
              }).catchError((error) {
                // Helper.hideLoading();
                debugPrint(error.toString());
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
        toToast(AppConstants.onlyForwardUpto5);
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
          filterGroupChat();
          filterUserList();
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
    scrollable((_mainuserList.length == 20 && MirrorflyUikit.instance.isTrialLicenceKey));
    _recentChats(_mainrecentChats);
    _groupList(_maingroupList);
    _userList(_mainuserList);
  }

  forwardMessages(BuildContext context) async {
    if (await AppUtils.isNetConnected()) {
      var busyStatus = await Mirrorfly.isBusyStatusEnabled();
      if (!busyStatus.checkNull()) {
        if (forwardMessageIds.isNotEmpty && selectedJids.isNotEmpty) {
          Mirrorfly.forwardMessagesToMultipleUsers(
                  forwardMessageIds, selectedJids)
              .then((values) {
            // debugPrint("to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
            getProfileDetails(selectedJids.last)
                .then((value) {
              if (value.jid != null) {
                // var str = profiledata(value.toString());
                // Get.back(result: str);
                Navigator.pop(context, value);
              }
            });
          });
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

  Future<String> getParticipantsNameAsCsv(String jid) async {
    var groupParticipantsName = Constants.emptyString;
    await Mirrorfly.getGroupMembersList(jid, false).then((value) {
      if (value != null) {
        var str = <String>[];
        var groupsMembersProfileList = memberFromJson(value);
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
    getAllGroups();
    getUsers();
    if (searchQuery.text.toString().trim().isNotEmpty) {
      lastInputValue=Constants.emptyString;
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
}
