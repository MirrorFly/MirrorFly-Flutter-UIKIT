
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/model/callback.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';

import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

import '../../../../data/apputils.dart';


class BlockedListController extends GetxController {
  final _blockedUsers = <ProfileDetails>[].obs;
  set blockedUsers(value) => _blockedUsers.value = value;
  List<ProfileDetails> get blockedUsers => _blockedUsers;

  @override
  void onInit(){
    super.onInit();
    debugPrint("oninit");
    getUsersIBlocked(false);
  }

  getUsersIBlocked([bool? server]) async {
    debugPrint("getting blockked user");
    Mirrorfly.getUsersIBlocked(fetchFromServer: server ?? await AppUtils.isNetConnected(), flyCallBack: (FlyResponse response) {
    if(response.isSuccess && response.hasData){
    LogMessage.d("getUsersIBlocked", response.toString());
    var list = profileFromJson(response.data);
    list.sort((a, b) => getMemberName(a).checkNull().toString().toLowerCase().compareTo(getMemberName(b).checkNull().toString().toLowerCase()));
    _blockedUsers(list);
    }else{
    _blockedUsers.clear();
    }
    });
  }
  void userUpdatedHisProfile(String jid) {
    if (jid.isNotEmpty) {
       //This function is not working in UI kit so commented
      getProfileDetails(jid).then((value) {
        var index = _blockedUsers.indexWhere((element) => element.jid == jid);
        if(!index.isNegative) {
          _blockedUsers[index].name = value.name;
          _blockedUsers[index].nickName = value.nickName;
          _blockedUsers[index].email = value.email;
          _blockedUsers[index].image = value.image;
          _blockedUsers[index].isBlocked = value.isBlocked;
          _blockedUsers[index].mobileNumber = value.mobileNumber;
          _blockedUsers[index].status = value.status;
          _blockedUsers.refresh();
        }
      });
    }

  }
  unBlock(ProfileDetails item, BuildContext context){
    Helper.showAlert(message: "${AppConstants.unblock} ${getMemberName(item)}?", actions: [
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
          },
          child: Text(AppConstants.no.toUpperCase(), style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              // Get.back();
              if(context.mounted)Navigator.pop(context);
              if(context.mounted)Helper.progressLoading(context: context);
              Mirrorfly.unblockUser(userJid: item.jid.checkNull(), flyCallBack: (FlyResponse response) {
                Helper.hideLoading(context: context);
                if(response.isSuccess) {
                  toToast("${getMemberName(item)} ${AppConstants.hasUnBlocked}");
                  getUsersIBlocked(false);
                }
              },);
            }else{
              toToast(AppConstants.noInternetConnection);
            }
          },
          child: Text(AppConstants.yes.toUpperCase(), style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))),
    ], context: context);
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }
}