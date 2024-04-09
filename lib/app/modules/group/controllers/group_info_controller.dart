import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/model/available_features.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_plugin/flychat.dart';
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
        getGroupMembers(null);
        groupAdmin();
        memberOfGroup();
        muteAble();
        nameController.text = profile.nickName.checkNull();
      }
    });
  }
  muteAble() async {
    muteable(await Mirrorfly.isUserUnArchived(profile.jid.checkNull()));
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
    Mirrorfly.isAdmin(SessionManagement.getUserJID()! ,profile.jid.checkNull()).then((bool? value){
      if(value!=null){
        _isAdmin(value);
      }
    });
  }
  memberOfGroup(){
    Mirrorfly.isMemberOfGroup(profile.jid.checkNull(),null).then((bool? value){
      if(value!=null){
        _isMemberOfGroup(value);
      }
    });
  }
  onToggleChange(bool value){
    if(muteable.value) {
      mirrorFlyLog("change", value.toString());
      _mute(value);
      Mirrorfly.updateChatMuteStatus(profile.jid.checkNull(), value);
    }
  }

  getGroupMembers(bool? server){
    Mirrorfly.getGroupMembersList(profile.jid.checkNull(),server).then((value) {
      mirrorFlyLog("getGroupMembersList", value);
      if(value!=null){
        var list = profileFromJson(value);
        groupMembers.value=(list);
        groupMembers.refresh();
      }
    });
  }

  reportGroup(BuildContext context){
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
            Mirrorfly.reportUserOrMessages(profile.jid.checkNull(),Constants.typeGroupChat, "").then((value) {
              Helper.hideLoading(context: context);
              if(value!=null){
                if(value){
                  toToast(AppConstants.reportSent);
                }else{
                  toToast(AppConstants.thereNoMessagesAvailable);
                }
              }
            }).catchError((error) {
              Helper.hideLoading(context: context);
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
  exitFromGroup(BuildContext context)async{
    if(await AppUtils.isNetConnected()) {
      if(context.mounted) Helper.progressLoading(context: context);
      Mirrorfly.leaveFromGroup(SessionManagement.getUserJID() ,profile.jid.checkNull()).then((value) {
        Helper.hideLoading(context: context);
        if(value!=null){
          if(value){
            _isMemberOfGroup(!value);
          }
        }
      }).catchError((error) {
        Helper.hideLoading(context: context);
      });
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }
  deleteGroup(BuildContext context){
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
              if(context.mounted) Helper.progressLoading(context: context);
              Mirrorfly.deleteGroup(profile.jid.checkNull()).then((value) {
                Helper.hideLoading(context: context);
                if(value!=null){
                  if(value){
                    // Get.offAllNamed(Routes.dashboard);
                    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (con)=>DashboardView()), (route) => false);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                }
              }).catchError((error) {
                Helper.hideLoading(context: context);
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
    showLoader(context);
    Mirrorfly.updateGroupProfileImage(profile.jid.checkNull(),path).then((bool? value){
      hideLoader(context);
      if(value!=null){
        if(value){
          profile_.value.image=path;
          profile_.refresh();
        }
      }
    });
  }

  updateGroupName(String name, BuildContext context){
    showLoader(context);
    Mirrorfly.updateGroupName(profile.jid.checkNull(),name).then((bool? value){
      hideLoader(context);
      if(value!=null){
        if(value){
          profile_.value.name = name;
          profile_.value.nickName = name;
          profile_.refresh();
        }
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
    if(await AppUtils.isNetConnected()) {
      if(context.mounted) showLoader(context);
      Mirrorfly.removeGroupProfileImage(profile.jid.checkNull()).then((bool? value) {
        hideLoader(context);
        if (value != null) {
          if(value){
            profile_.value.image=Constants.emptyString;
            profile_.refresh();
          }
        }
      }).catchError((onError) {
        hideLoader(context);
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
    Navigator.push(context, MaterialPageRoute(builder: (con) => ContactListView(group : true, groupJid: profile.jid.checkNull().toString()))).then((value){
      if(value!=null){
        addUsers(value, context);
      }
    });
    /*Get.toNamed(Routes.contacts, arguments: {"forward" : false,"group":true,"groupJid":profile.jid })?.then((value){
      if(value!=null){
        addUsers(value, context);
      }
    });*/
  }

  addUsers(dynamic value, BuildContext context)async{
    if(await AppUtils.isNetConnected()) {
      if(context.mounted)showLoader(context);
      Mirrorfly.addUsersToGroup(profile.jid.checkNull(),value as List<String>).then((value){
        hideLoader(context);
        if(value!=null && value){
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
    if(isMemberOfGroup){
      if(await AppUtils.isNetConnected()) {
        if(context.mounted)showLoader(context);
        Mirrorfly.removeMemberFromGroup(profile.jid.checkNull(), userJid).then((value){
          hideLoader(context);
          if(value!=null && value){
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
    if(isMemberOfGroup){
      if(await AppUtils.isNetConnected()) {
        if(context.mounted)showLoader(context);
        Mirrorfly.makeAdmin(profile.jid.checkNull(), userJid).then((value){
          hideLoader(context);
          if(value!=null && value){
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
    if(isMemberOfGroup) {
      // Get.to(const NameChangeView())?.then((value) {
      //   if (value != null) {
      //     updateGroupName(nameController.text, context);
      //   }
      // });
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
}
