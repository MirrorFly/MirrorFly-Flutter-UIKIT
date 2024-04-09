import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';

import '../../../mirrorfly_uikit_plugin.dart';
import '../../common/constants.dart';
import '../../common/de_bouncer.dart';
import '../../common/main_controller.dart';
import '../../data/apputils.dart';
import '../../data/helper.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../modules/chatInfo/views/chat_info_view.dart';
import '../../modules/group/views/group_info_view.dart';
import '../outgoing_call/outgoing_call_view.dart';

class GroupParticipantsController extends GetxController {
  var usersList = <ProfileDetails>[].obs;
  var mainUserList = <ProfileDetails>[].obs;
  var selectedUsersList = List<ProfileDetails>.empty(growable: true).obs;
  var selectedUsersJIDList = List<String>.empty(growable: true).obs;

  var groupId = "".obs;
  var callType = "".obs;

  late BuildContext context;

  Future<void> initGroupParticipantController(
      {required BuildContext buildContext,
      required String groupId,
      required String callType}) async {
    context = buildContext;
    getMaxCallUsersCount = (await Mirrorfly.getMaxCallUsersCount()) ?? 8;
    this.groupId(groupId);
    this.callType(callType);
    getGroupMembers();
  }

  @override
  void onClose() {
    super.onClose();
    searchQuery.dispose();
  }

  void getGroupMembers() {
    Mirrorfly.getGroupMembersList(
        jid: groupId.value.checkNull(),
        fetchFromServer: false,
        flyCallBack: (FlyResponse response) {
          mirrorFlyLog("getGroupMembersList", response.toString());
          if (response.isSuccess && response.hasData) {
            var list = profileFromJson(response.data);
            var withoutMe = list
                .where(
                    (element) => element.jid != SessionManagement.getUserJID())
                .toList();
            mainUserList(withoutMe);
            usersList(withoutMe);
          }
        });
  }

  //Search Start Here
  bool get isClearVisible =>
      _search.value &&
      lastInputValue
          .value.isNotEmpty /*&& !isForward.value && isCreateGroup.value*/;
  bool get isSearchVisible => !_search.value;
  FocusNode searchFocus = FocusNode();

  final _search = false.obs;
  set search(bool value) => _search.value = value;
  bool get search => _search.value;

  var _searchText = "";

  final TextEditingController searchQuery = TextEditingController();

  void onSearchPressed() {
    if (_search.value) {
      _search(false);
    } else {
      _search(true);
    }
  }

  final deBouncer = DeBouncer(milliseconds: 700);
  RxString lastInputValue = "".obs;

  searchListener(String text) async {
    debugPrint("searching .. ");
    if (lastInputValue.value != searchQuery.text.trim()) {
      lastInputValue(searchQuery.text.trim());
      if (searchQuery.text.trim().isEmpty) {
        _searchText = "";
      } else {
        _searchText = searchQuery.text.trim();
      }
      filterGroupMembers();
    }
  }

  void filterGroupMembers() {
    var filteredList = mainUserList
        .where(
            (item) => item.getName().toLowerCase().contains(_searchText.trim()))
        .toList();
    usersList(filteredList);
  }

  clearSearch() {
    searchQuery.clear();
    _searchText = "";
    lastInputValue('');
    usersList(mainUserList);
  }

  backFromSearch() {
    _search.value = false;
    searchQuery.clear();
    _searchText = "";
    lastInputValue('');
    usersList(mainUserList);
  }

  //Search End Here

  showProfilePopup(Rx<ProfileDetails> profile) {
    showQuickProfilePopup(
        context: Get.context,
        // chatItem: chatItem,
        chatTap: () {
          Get.back();
          onListItemPressed(profile.value);
        },
        infoTap: () {
          Get.back();
          if (profile.value.isGroupProfile ?? false) {
            // Get.toNamed(Routes.groupInfo, arguments: profile.value);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (con) =>
                        GroupInfoView(jid: profile.value.jid.checkNull())));
          } else {
            // Get.toNamed(Routes.chatInfo, arguments: profile.value);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (con) =>
                        ChatInfoView(jid: profile.value.jid.checkNull())));
          }
        },
        profile: profile,
        availableFeatures: availableFeatures,
        callTap: () {},
        videoTap: () {});
  }

  onListItemPressed(ProfileDetails item) {
    if (item.isBlocked.checkNull()) {
      unBlock(item);
    } else {
      validateForCall(item);
    }
  }

  unBlock(ProfileDetails item) {
    Helper.showAlert(
        message: "Unblock ${getName(item)}?",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("NO", style: TextStyle(color: buttonBgColor))),
          TextButton(
              onPressed: () async {
                if (await AppUtils.isNetConnected()) {
                  Get.back();
                  Helper.progressLoading(context: context);
                  Mirrorfly.unblockUser(
                      userJid: item.jid.checkNull(),
                      flyCallBack: (FlyResponse response) {
                        Helper.hideLoading(context: context);
                        if (response.isSuccess && response.hasData) {
                          toToast("${getName(item)} has been Unblocked");
                          userUpdatedHisProfile(item.jid.checkNull());
                        }
                      });
                } else {
                  toToast(Constants.noInternetConnection);
                }
              },
              child: const Text("YES", style: TextStyle(color: buttonBgColor))),
        ],
        context: context);
  }

  void userUpdatedHisProfile(String jid) {
    updateProfile(jid);
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      getProfileDetails(jid).then((value) {
        var userListIndex =
            usersList.indexWhere((element) => element.jid == jid);
        var mainUserListIndex =
            mainUserList.indexWhere((element) => element.jid == jid);
        mirrorFlyLog('value.isBlockedMe', value.isBlockedMe.toString());
        if (!userListIndex.isNegative) {
          usersList[userListIndex] = value;
          usersList.refresh();
        }
        if (!mainUserListIndex.isNegative) {
          mainUserList[userListIndex] = value;
          mainUserList.refresh();
        }
      });
    }
  }

  //Call Functions Start Here
  var getMaxCallUsersCount = 8;
  var groupCallMembersCount =
      1.obs; //initially its 1 because me also added into call
  void validateForCall(ProfileDetails item) {
    if (selectedUsersJIDList.contains(item.jid)) {
      selectedUsersList.remove(item);
      selectedUsersJIDList.remove(item.jid);
      groupCallMembersCount(groupCallMembersCount.value - 1);
    } else {
      if (getMaxCallUsersCount > groupCallMembersCount.value) {
        selectedUsersList.add(item);
        selectedUsersJIDList.add(item.jid!);
        groupCallMembersCount(groupCallMembersCount.value + 1);
      } else {
        toToast(Constants.callMembersLimit
            .replaceFirst("%d", getMaxCallUsersCount.toString()));
      }
    }
    usersList.refresh();
  }

  makeCall() async {
    if (selectedUsersJIDList.isEmpty) {
      return;
    }
    if (!availableFeatures.value.isGroupCallAvailable.checkNull()) {
      Helper.showFeatureUnavailable(context);
      return;
    }
    if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
      debugPrint("#Mirrorfly Call You are on another call");
      toToast(Constants.msgOngoingCallAlert);
      return;
    }
    if (!(await AppUtils.isNetConnected())) {
      toToast(Constants.noInternetConnection);
      return;
    }
    if (callType.value == CallType.audio) {
      if (await AppPermission.askAudioCallPermissions(context)) {
        Mirrorfly.makeGroupVoiceCall(
            groupJid: groupId.value,
            toUserJidList: selectedUsersJIDList,
            flyCallBack: (FlyResponse response) {
              if (response.isSuccess) {
                /*Get.offNamed(Routes.outGoingCallView,
                arguments: {"userJid": selectedUsersJIDList, "callType": CallType.audio});*/
                MirrorflyUikit.instance.navigationManager.navigateTo(
                    context: context,
                    pageToNavigate:
                        OutGoingCallView(userJid: selectedUsersJIDList),
                    routeName: 'outgoing_call_view',
                    onNavigateComplete: () {});
              }
            });
      }
    } else if (callType.value == CallType.video) {
      if (await AppPermission.askVideoCallPermissions(context)) {
        Mirrorfly.makeGroupVideoCall(
            groupJid: groupId.value,
            toUserJidList: selectedUsersJIDList,
            flyCallBack: (FlyResponse response) {
              if (response.isSuccess) {
                /*Get.offNamed(Routes.outGoingCallView,
                arguments: {"userJid": selectedUsersJIDList, "callType": CallType.video});*/
                MirrorflyUikit.instance.navigationManager.navigateTo(
                    context: context,
                    pageToNavigate:
                        OutGoingCallView(userJid: selectedUsersJIDList),
                    routeName: 'outgoing_call_view',
                    onNavigateComplete: () {});
              }
            });
      }
    }
  }

  //Call Functions End Here
  var availableFeatures = Get.find<MainController>().availableFeature;
  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d(
        "GroupParticipants", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }
}
