import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/dashboard/views/dashboard_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/view_all_media/views/view_all_media_view.dart';
import '../../../../mirrorfly_uikit_plugin.dart';

import '../../../common/crop_image.dart';
import '../../../common/main_controller.dart';
import '../../../data/apputils.dart';
import '../../../data/session_management.dart';
import '../../chat/views/contact_list_view.dart';
import '../views/name_change_view.dart';

class GroupInfoController extends GetxController {
  var availableFeatures = Get.find<MainController>().availableFeature;
  ScrollController scrollController = ScrollController();
  var groupMembers = <ProfileDetails>[].obs;
  final _mute = false.obs;
  set mute(value) => _mute.value=value;
  bool get mute => _mute.value;

  final _isAdmin = false.obs;
  set isAdmin(value) => _isAdmin.value=value;
  bool get isAdmin => _isAdmin.value;

  final _isMemberOfGroup = true.obs;
  set isMemberOfGroup(value) => _isMemberOfGroup.value=value;
  bool get isMemberOfGroup => _isMemberOfGroup.value;

  var profile_ = ProfileDetails().obs;
  //set profile(value) => _profile.value = value;
  ProfileDetails get profile => profile_.value;

  final _isSliverAppBarExpanded = true.obs;
  set isSliverAppBarExpanded(value) => _isSliverAppBarExpanded.value = value;
  bool get isSliverAppBarExpanded => _isSliverAppBarExpanded.value;
  final muteable = false.obs;
  @override
  void onInit(){
    super.onInit();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });
  }
  init(String jid){
    getProfileDetails(jid).then((value) {
      if(value.jid !=null) {
        profile_(value);
        _mute(profile.isMuted!);
        scrollController.addListener(_scrollListener);
        getGroupMembers(false);
        groupAdmin();
        memberOfGroup();
        muteAble();
        nameController.text = profile.nickName.checkNull();
      }
    });
  }
  muteAble() async {
    muteable(await Mirrorfly.isChatUnArchived(jid: profile.jid.checkNull()));
  }

  void onGroupProfileUpdated(String groupJid) {
    if (groupJid.checkNull().isNotEmpty) {
      if (profile.jid.checkNull() == groupJid.toString()) {
        mirrorFlyLog("group info", groupJid.toString());
        getProfileDetails(profile.jid.checkNull()).then((value) {
          if (value.jid != null) {
            // var member = Profile.fromJson(json.decode(value.toString()));
            profile_(value);
            _mute(profile.isMuted!);
            nameController.text=profile.nickName.checkNull();
          }
        });
      }
    }
  }

  void userUpdatedHisProfile(String jid) {
    // debugPrint("userUpdatedHisProfile : $jid");
    if(jid.checkNull().isNotEmpty) {
      getProfileDetails(jid).then((value) {
        var index = groupMembers.indexWhere((element) => element.jid == jid);
        // debugPrint("profile : $index");
        if (!index.isNegative) {
          value.isGroupAdmin = groupMembers[index].isGroupAdmin;
          groupMembers[index] = value;
          groupMembers.refresh();
        }
      });
    }
  }

  void onLeftFromGroup({required String groupJid, required String userJid}) {
    if (profile.isGroupProfile.checkNull()) {
      if (groupJid == profile.jid) {
        var index = groupMembers.indexWhere((element) => element.jid == userJid);
        if(!index.isNegative) {
          debugPrint('user left ${groupMembers[index].name}');
          var isAdmin = groupMembers[index].isGroupAdmin;
          groupMembers.removeAt(index);
          if(isAdmin.checkNull()){
            getGroupMembers(false);
          }else {
            groupMembers.refresh();
          }
        }
      }
    }
  }

  void onMemberMadeAsAdmin({required String groupJid,
    required String newAdminMemberJid, required String madeByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      debugPrint('onMemberMadeAsAdmin $newAdminMemberJid');
      if (groupJid == profile.jid) {
        var index = groupMembers.indexWhere((element) => element.jid == newAdminMemberJid);
        if(!index.isNegative) {
          debugPrint('user admin ${groupMembers[index].name}');
          groupMembers[index].isGroupAdmin=true;
          groupMembers.refresh();
        }
      }
    }
  }

  void onMemberRemovedFromGroup({required String groupJid,
    required String removedMemberJid, required String removedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      debugPrint('onMemberRemovedFromGroup $removedMemberJid');
      if (groupJid == profile.jid) {
        var index = groupMembers.indexWhere((element) => element.jid == removedMemberJid);
        if(!index.isNegative) {
          debugPrint('user removed ${groupMembers[index].name}');
          groupMembers.removeAt(index);
          groupMembers.refresh();
        }
        loadGroupExistence();
      }
    }
  }

  void onNewMemberAddedToGroup({required String groupJid,
    required String newMemberJid, required String addedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      debugPrint('onNewMemberAddedToGroup $newMemberJid');
      if (groupJid == profile.jid) {
        var index = groupMembers.indexWhere((element) => element.jid == newMemberJid);
        if(index.isNegative) {
          if(newMemberJid.checkNull().isNotEmpty) {
            getProfileDetails(newMemberJid).then((value) {
              groupMembers.add(value);
              groupMembers.refresh();
            });
          }
        }
      }
    }
  }

  _scrollListener() {
    if (scrollController.hasClients) {
      _isSliverAppBarExpanded(scrollController.offset < (250 - kToolbarHeight));
      //Log("isSliverAppBarExpanded", isSliverAppBarExpanded.toString());
    }
  }
  groupAdmin(){
    Mirrorfly.isGroupAdmin(userJid: SessionManagement.getUserJID()! ,groupJid: profile.jid.checkNull()).then((bool? value){
      if(value!=null){
        _isAdmin(value);
      }
    });
  }
  memberOfGroup(){
    Mirrorfly.isMemberOfGroup(groupJid:profile.jid.checkNull(),userJid: SessionManagement.getUserJID().checkNull()).then((bool? value){
      if(value!=null){
        _isMemberOfGroup(value);
      }
    });
  }
  onToggleChange(bool value){
    if (isMemberOfGroup) {
      if (muteable.value) {
        mirrorFlyLog("change", value.toString());
        _mute(value);
        Mirrorfly.updateChatMuteStatus(
            jid: profile.jid.checkNull(), muteStatus: value);
        notifyDashboardUI();
      }
    }else{
      toToast(AppConstants.youAreNoLonger);
    }
  }

  getGroupMembers(bool? server){
    Mirrorfly.getGroupMembersList(jid: profile.jid.checkNull(),fetchFromServer: server, flyCallBack: (FlyResponse response) {
      mirrorFlyLog("getGroupMembersList", response.data);
      if(response.isSuccess && response.hasData){
        var list = profileFromJson(response.data);
        list.sort((a, b) => (a.jid==SessionManagement.getUserJID()) ? 1 : (b.jid==SessionManagement.getUserJID()) ? -1 : 0);
        groupMembers.value=(list);
        groupMembers.refresh();
      }
    });
  }

  reportGroup(BuildContext context){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    Helper.showAlert(title: AppConstants.reportThisGroup,message: AppConstants.reportThisGroupContent,actions: [
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
          },
          child: Text(AppConstants.cancel.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
            Helper.progressLoading(context: context);
            Mirrorfly.reportUserOrMessages(jid: profile.jid.checkNull(),type: Constants.typeGroupChat, messageId: "", flyCallBack: (FlyResponse response) {
              Helper.hideLoading(context: context);
              if(response.isSuccess){
                toToast(AppConstants.reportSent);
              }else{
                toToast(AppConstants.thereNoMessagesAvailable);
              }
            });
          },
          child: Text(AppConstants.report.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
    ], context: context);
  }
  exitOrDeleteGroup(BuildContext context){
    if(!isMemberOfGroup){
      deleteGroup(context);
    }else{
      if(profile.isGroupProfile!) {
        leaveGroup(context);
      }
    }
  }
  leaveGroup(BuildContext context){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    Helper.showAlert(message: AppConstants.areYouLeave,actions: [
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
          },
          child: Text(AppConstants.cancel.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
            exitFromGroup(context);
          },
          child: Text(AppConstants.leave.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
    ], context: context);
  }
  var leavedGroup = false.obs;
  exitFromGroup(BuildContext context)async{
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    if(await AppUtils.isNetConnected()) {
      if(context.mounted) Helper.progressLoading(context: context);
      Mirrorfly.leaveFromGroup(userJid: SessionManagement.getUserJID().checkNull() ,groupJid: profile.jid.checkNull(), flyCallBack: (FlyResponse response) {
        Helper.hideLoading(context: context);
        if(response.isSuccess){
          _isMemberOfGroup(!response.isSuccess);
          leavedGroup(response.isSuccess);
        }
      });
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }
  deleteGroup(BuildContext context){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull() || !availableFeatures.value.isDeleteChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    Helper.showAlert(message: AppConstants.areYouDelete,actions: [
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
          },
          child: Text(AppConstants.cancel.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              // Get.back();
              if(context.mounted) Navigator.pop(context);
              if(!availableFeatures.value.isGroupChatAvailable.checkNull() || !availableFeatures.value.isDeleteChatAvailable.checkNull()){
                if(context.mounted) Helper.showFeatureUnavailable(context);
                return;
              }
              if(context.mounted) Helper.progressLoading(context: context);
              Mirrorfly.deleteGroup(jid: profile.jid.checkNull(), flyCallBack: (FlyResponse response) {
                Helper.hideLoading(context: context);
                if(response.isSuccess){
                  Navigator.popUntil(context, (route) => route is DashboardView);
                }else{
                  toToast(AppConstants.errorTryAgain);
                }
              });
            }else{
              toToast(AppConstants.noInternetConnection);
            }
          },
          child: Text(AppConstants.delete.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
    ], context: context);
  }

  var imagePath = "".obs;
  Future imagePicker(BuildContext context) async {
    if(await AppUtils.isNetConnected()) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);
      if (result != null) {
        // Get.to(CropImage(
        //   imageFile: File(result.files.single.path!),
        // ))?.then((value) {
        if(context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (con) =>
              CropImage(
                imageFile: File(result.files.single.path!),
              ))).then((value) {
            value as MemoryImage;
            var name = "${DateTime
                .now()
                .millisecondsSinceEpoch}.jpg";
            writeImageTemp(value.bytes, name).then((value) {
              imagePath(value.path);
              updateGroupProfileImage(value.path, context);
            });
          });
        }
      } else {
        // User canceled the picker
      }
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  final ImagePicker _picker = ImagePicker();
  camera(BuildContext context) async {
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    if(await AppUtils.isNetConnected()) {
      final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera);
      if (photo != null) {
        /*Get.to(CropImage(
          imageFile: File(photo.path),
        ))?.then((value) {*/
        if(context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (con) =>
              CropImage(
                imageFile: File(photo.path),
              ))).then((value) {
            value as MemoryImage;
            var name = "${DateTime
                .now()
                .millisecondsSinceEpoch}.jpg";
            writeImageTemp(value.bytes, name).then((value) {
              imagePath(value.path);
              updateGroupProfileImage(value.path, context);
            });
          });
        }
      } else {
        // User canceled the Camera
      }
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  updateGroupProfileImage(String path, BuildContext context){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    showLoader(context);
    Mirrorfly.updateGroupProfileImage(jid:profile.jid.checkNull(),file: path, flyCallBack: (FlyResponse response) {
      hideLoader(context);
      if(response.isSuccess){
        profile_.value.image=path;
        profile_.refresh();
      }
    });
  }

  updateGroupName(String name, BuildContext context){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    showLoader(context);
    Mirrorfly.updateGroupName(jid: profile.jid.checkNull(),name: name, flyCallBack: (FlyResponse response) {
      hideLoader(context);
      if(response.isSuccess){
        profile_.value.name = name;
        profile_.value.nickName = name;
        profile_.refresh();
      }
    });
  }

  removeProfileImage(BuildContext context) {
    Helper.showAlert(message: AppConstants.areYouRemoveGroupPhoto,actions: [
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
          },
          child: Text(AppConstants.cancel.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
            revokeAccessForProfileImage(context);
          },
          child: Text(AppConstants.remove.toUpperCase(),style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
    ], context: context);
  }

  revokeAccessForProfileImage(BuildContext context)async{
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    if(await AppUtils.isNetConnected()) {
      if(context.mounted) showLoader(context);
      Mirrorfly.removeGroupProfileImage(jid: profile.jid.checkNull(), flyCallBack: (FlyResponse response) {
        hideLoader(context);
        if (response.isSuccess) {
          profile_.value.image=Constants.emptyString;
          profile_.refresh();
        }
      });
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  showLoader(BuildContext context){
    Helper.progressLoading(context: context);
  }
  hideLoader(BuildContext context){
    // Helper.hideLoading();
    Navigator.pop(context);
  }

  gotoAddParticipants(BuildContext context){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (con) => ContactListView(group : true, groupJid: profile.jid.checkNull().toString()))).then((value){
      if(value!=null){
        addUsers(value, context);
      }
    });
  }

  addUsers(dynamic value, BuildContext context)async{
    if(await AppUtils.isNetConnected()) {
      if(context.mounted)showLoader(context);
      Mirrorfly.addUsersToGroup(jid: profile.jid.checkNull(),userList: value as List<String>, flyCallBack: (FlyResponse response) {
        hideLoader(context);
        if(response.isSuccess){
          //getGroupMembers(false);
        }else{
          toToast(AppConstants.errorWhileAddingMember);
        }
      });
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  gotoViewAllMedia(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (con)=>ViewAllMediaView(name:profile.name.checkNull(),jid:profile.jid.checkNull(),isGroup:profile.isGroupProfile.checkNull())));
    // Get.toNamed(Routes.viewMedia,arguments: {"name":profile.name,"jid":profile.jid,"isgroup":profile.isGroupProfile});
  }

  removeUser(String userJid, BuildContext context) async {
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    if(isMemberOfGroup){
      if(await AppUtils.isNetConnected()) {
        if(context.mounted)showLoader(context);
        Mirrorfly.removeMemberFromGroup(groupJid: profile.jid.checkNull(), userJid: userJid, flyCallBack: (FlyResponse response) {
          hideLoader(context);
          if(response.isSuccess){
            //getGroupMembers(false);
          }else{
            toToast(AppConstants.errorWhileRemovingMember);
          }
        });
      }else{
        toToast(AppConstants.noInternetConnection);
      }
    }
  }

  makeAdmin(String userJid, BuildContext context) async {
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    if(isMemberOfGroup){
      if(await AppUtils.isNetConnected()) {
        if(context.mounted)showLoader(context);
        Mirrorfly.makeAdmin(groupJid: profile.jid.checkNull(),userJid: userJid, flyCallBack: (FlyResponse response) {
          hideLoader(context);
          if(response.isSuccess){
            //getGroupMembers(false);
          }else{
            toToast(AppConstants.errorWhileMakeAdmin);
          }
        });
      }else{
        toToast(AppConstants.noInternetConnection);
      }
    }
  }

  //New Name Change
  gotoNameEdit(BuildContext context){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable(context);
      return;
    }
    if(isMemberOfGroup) {
      Navigator.push(context, MaterialPageRoute(builder: (con) => const NameChangeView())).then((value) {
        if (value != null) {
          updateGroupName(nameController.text, context);
        }
      });
    }else{
      toToast(AppConstants.youAreNoLonger);
    }
  }
  var nameController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count= 25.obs;

  onChanged(){
    count.value = (25 - nameController.text.length);
  }

  onEmojiBackPressed(){
    var text = nameController.text;
    var cursorPosition = nameController.selection.base.offset;

    // If cursor is not set, then place it at the end of the textfield
    if (cursorPosition < 0) {
      nameController.selection = TextSelection(
        baseOffset: nameController.text.length,
        extentOffset: nameController.text.length,
      );
      cursorPosition = nameController.selection.base.offset;
    }

    if (cursorPosition >= 0) {
      final selection = nameController.value.selection;
      final newTextBeforeCursor =
      selection.textBefore(text).characters.skipLast(1).toString();
      LogMessage.d("newTextBeforeCursor", newTextBeforeCursor);
      nameController
        ..text = newTextBeforeCursor + selection.textAfter(text)
        ..selection = TextSelection.fromPosition(
            TextPosition(offset: newTextBeforeCursor.length));
    }
    count((25 - nameController.text.characters.length));
  }

  onEmojiSelected(Emoji emoji){
    if(nameController.text.characters.length < 25){
      final controller = nameController;
      final text = controller.text;
      final selection = controller.selection;
      final cursorPosition = controller.selection.base.offset;

      if (cursorPosition < 0) {
        controller.text += emoji.emoji;
        // widget.onEmojiSelected?.call(category, emoji);
        return;
      }

      final newText =
      text.replaceRange(selection.start, selection.end, emoji.emoji);
      final emojiLength = emoji.emoji.length;
      controller
        ..text = newText
        ..selection = selection.copyWith(
          baseOffset: selection.start + emojiLength,
          extentOffset: selection.start + emojiLength,
        );
    }
    count((25 - nameController.text.characters.length));
  }

  void showHideEmoji(BuildContext context) {
    if (!showEmoji.value) {
      focusNode.unfocus();
    }else{
      focusNode.requestFocus();
      return;
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      showEmoji(!showEmoji.value);
    });
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  void loadGroupExistence() {
    memberOfGroup();
  }

  void unblockedThisUser(String jid) {
    userUpdatedHisProfile(jid);
  }

  void userBlockedMe(String jid) {
    userUpdatedHisProfile(jid);
  }

  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("GroupInfo", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
    _isMemberOfGroup.refresh();
    // loadGroupExistence();
  }
  void notifyDashboardUI(){
    if(Get.isRegistered<DashboardController>()){
      Get.find<DashboardController>().chatMuteChangesNotifyUI(profile.jid.checkNull());
    }
  }

  onBackPressed(BuildContext context) {
    if (showEmoji.value) {
      showEmoji(false);
    } else {
      nameController.text = profile.nickName.checkNull();
      // Get.back();
      Navigator.pop(context);
    }
  }
}
