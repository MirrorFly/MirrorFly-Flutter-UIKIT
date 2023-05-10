
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

import '../../../../data/apputils.dart';
import '../../../../models.dart';


class BlockedListController extends GetxController {
  final _blockedUsers = <Member>[].obs;
  set blockedUsers(value) => _blockedUsers.value = value;
  List<Member> get blockedUsers => _blockedUsers;

  @override
  void onInit(){
    super.onInit();
    debugPrint("oninit");
    getUsersIBlocked(false);
  }

  getUsersIBlocked(bool server){
    debugPrint("getting blockked user");
    Mirrorfly.getUsersIBlocked(server).then((value){
      if(value!=null && value != ""){
        var list = memberFromJson(value);
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
  unBlock(Member item, BuildContext context){
    Helper.showAlert(message: "Unblock ${getMemberName(item)}?", actions: [
      TextButton(
          onPressed: () {
            // Get.back();
            Navigator.pop(context);
          },
          child: Text("NO", style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),)),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              // Get.back();
              Navigator.pop(context);
              Helper.progressLoading(context: context);
              Mirrorfly.unblockUser(item.jid.checkNull()).then((value) {
                Helper.hideLoading(context: context);
                if(value!=null && value) {
                  toToast("${getMemberName(item)} has been Unblocked");
                  getUsersIBlocked(false);
                }
              }).catchError((error) {
                Helper.hideLoading(context: context);
                debugPrint(error);
              });
            }else{
              toToast(Constants.noInternetConnection);
            }
          },
          child: Text("YES", style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor))),
    ], context: context);
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }
}