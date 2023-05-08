import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chatInfo/views/chat_info_view.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/group/controllers/group_info_controller.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../models.dart';
import '../../image_view/views/image_view_view.dart';


class GroupInfoView extends StatefulWidget {
  const GroupInfoView({Key? key, required this.jid}) : super(key: key);
  final String jid;
  @override
  State<GroupInfoView> createState() => _GroupInfoViewState();
}

class _GroupInfoViewState extends State<GroupInfoView> {
  var controller = Get.put(GroupInfoController());
  @override
  void initState() {
    controller.init(widget.jid);
    super.initState();
  }
  @override
  void dispose() {
    Get.delete<GroupInfoController>();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        body: NestedScrollView(
          controller: controller.scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              Obx(() {
                return SliverAppBar(
                  backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
                  actionsIconTheme: IconThemeData(
                      color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                          iconColor),
                  iconTheme: IconThemeData(
                      color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                          iconColor),
                  centerTitle: false,
                  snap: false,
                  pinned: true,
                  floating: false,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: controller.isSliverAppBarExpanded
                            ? Colors.white
                            : MirrorflyUikit
                            .getTheme?.colorOnAppbar ?? Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                      // Get.back();
                    },
                  ),
                  title: Visibility(
                    visible: !controller.isSliverAppBarExpanded,
                    child: Text(controller.profile.nickName.checkNull(),
                        style: TextStyle(
                          color: MirrorflyUikit
                              .getTheme?.colorOnAppbar ?? Colors.black,
                          fontSize: 18.0,
                        )),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 16),
                      title: Visibility(
                        visible: controller.isSliverAppBarExpanded,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(controller.profile.nickName.checkNull(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                        ) //TextStyle
                                    ),
                                    Text("${controller.groupMembers.length} members",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.0,
                                        ) //TextStyle
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: controller.isMemberOfGroup,
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  edit,package: package,
                                  color: Colors.white,
                                  width: 16.0,
                                  height: 16.0,
                                ),
                                tooltip: 'edit',
                                onPressed: () => controller.gotoNameEdit(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      background: controller.imagePath.value.isNotEmpty
                          ? SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 300,
                          child: Image.file(
                            File(controller.imagePath.value),
                            fit: BoxFit.fill,
                          ))
                          : ImageNetwork(
                        url: controller.profile.image.checkNull(),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 300,
                        clipOval: false,
                        errorWidget: Image.asset(
                          groupImg,package: package,
                          height: 300,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          fit: BoxFit.fill,
                        ),
                        onTap: (){
                          if(controller.imagePath.value.isNotEmpty){
                            Navigator.push(context, MaterialPageRoute(builder: (con)=>ImageViewView(imageName: controller.profile.nickName.checkNull(),imagePath: controller.profile.image.checkNull(),)));
                            /*Get.toNamed(Routes.imageView, arguments: {
                              'imageName': controller.profile.nickName,
                              'imagePath': controller.profile.image.checkNull()
                            });*/
                          }else if(controller.profile.image.checkNull().isNotEmpty){
                            Navigator.push(context, MaterialPageRoute(builder: (con)=>ImageViewView(imageName: controller.profile.nickName.checkNull(),imageUrl: controller.profile.image.checkNull(),)));
                            /*Get.toNamed(Routes.imageView, arguments: {
                              'imageName': controller.profile.nickName,
                              'imageUrl': controller.profile.image.checkNull()
                            });*/
                          }
                        },
                        isGroup: controller.profile.isGroupProfile.checkNull(),
                        blocked: controller.profile.isBlockedMe.checkNull() || controller.profile.isAdminBlocked.checkNull(),
                        unknown: (!controller.profile.isItSavedContact.checkNull() || controller.profile.isDeletedContact()),
                      ) //Images.network
                  ),
                  //FlexibleSpaceBar
                  expandedHeight: 300,
                  //IconButton
                  actions: <Widget>[
                    Visibility(
                      visible: controller.isMemberOfGroup,
                      child: IconButton(
                        icon: SvgPicture.asset(
                          imageEdit,package: package,
                          color: controller.isSliverAppBarExpanded
                              ? Colors.white
                              : MirrorflyUikit
                              .getTheme?.colorOnAppbar ?? Colors.black,
                        ),
                        tooltip: 'Image edit',
                        onPressed: () {
                          if (controller.isMemberOfGroup) {
                            bottomSheetView(context);
                          }else{
                            toToast("You're no longer a participant in this group");
                          }
                        },
                      ),
                    ),
                  ],
                );
              })
            ];
          },
          body: SafeArea(
            child: ListView(
              children: <Widget>[
                Obx(() {
                  return ListItem(title: Text("Mute Notification",
                      style: TextStyle(
                          color: MirrorflyUikit
                              .getTheme?.textPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)), trailing: FlutterSwitch(
                    width: 40.0,
                    height: 20.0,
                    valueFontSize: 12.0,
                    toggleSize: 12.0,
                    activeColor: MirrorflyUikit.getTheme!.primaryColor,//Colors.white,
                    activeToggleColor: MirrorflyUikit.getTheme?.colorOnPrimary, //Colors.blue,
                    inactiveToggleColor: Colors.grey,
                    inactiveColor: Colors.white,
                    switchBorder: Border.all(
                        color: controller.mute ? MirrorflyUikit.getTheme!.colorOnPrimary : Colors
                            .grey,
                        width: 1),
                    value: controller.mute,
                    onToggle:  (value){
                      if(controller.isMemberOfGroup) {
                        controller.onToggleChange(value);
                      }
                    },
                  ), onTap: (){
                    if(controller.isMemberOfGroup) {
                      controller.onToggleChange(!controller.mute);
                    }
                  });
                }),
                Obx(() =>
                    Visibility(
                      visible: controller.isAdmin,
                      child: ListItem(leading: SvgPicture.asset(addUser,package: package, color: MirrorflyUikit.getTheme?.textSecondaryColor,),
                          title: Text("Add Participants",
                              style: TextStyle(
                                  color: MirrorflyUikit.getTheme?.textPrimaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          onTap: () => controller.gotoAddParticipants(context)),
                    )),
                Obx(() {
                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.groupMembers.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var item = controller.groupMembers[index];
                        return memberItem(name: getName(item).checkNull(),image: item.image.checkNull(),isAdmin: item.isGroupAdmin,status: item.status.checkNull(),onTap: (){
                          if (item.jid.checkNull() !=
                              SessionManagement.getUserJID().checkNull()) {
                            showOptions(item, context);
                          }
                        },
                          isGroup: item.isGroupProfile.checkNull(),
                          blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
                          unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),);
                      });
                }),
                ListItem(
                  leading: SvgPicture.asset(imageOutline,package: package,color: MirrorflyUikit.getTheme?.textPrimaryColor,),
                  title: Text("View All Media",
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.textPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.keyboard_arrow_right,color: MirrorflyUikit.getTheme?.textPrimaryColor,),
                  onTap: ()=>controller.gotoViewAllMedia(context),
                ),
                ListItem(
                  leading: SvgPicture.asset(reportGroup,package: package,color: Colors.red,),
                  title: const Text("Report Group",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  onTap: () => controller.reportGroup(context),
                ),
                Obx(() {
                  return ListItem(
                    leading: SvgPicture.asset(leaveGroup,package: package, width: 18,),
                    title: Text(!controller.isMemberOfGroup
                        ? "Delete Group"
                        : "Leave Group",
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    onTap: () => controller.exitOrDeleteGroup(context),
                  );
                }),
              ],
            ),
          ),
        ),
    );
  }

  showOptions(Profile item, BuildContext context) {
    Helper.showButtonAlert(actions: [
        ListTile(title: const Text("Start Chat", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),), onTap: () {
          // Get.toNamed(Routes.CHAT, arguments: item);
          // Get.back();
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 300),(){
            Navigator.pop(context,item);
            // Get.back(result: item);
          });
        },
        visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        ListTile(title: const Text("View Info",style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),), onTap: () {
          // Get.back();
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (con)=>ChatInfoView(jid:item.jid.checkNull())));
          // Get.toNamed(Routes.chatInfo, arguments: item);
        },
        visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        Visibility(visible: controller.isAdmin,
            child: ListTile(title: const Text("Remove from Group",style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),), onTap: () {
              Navigator.pop(context);
              // Get.back();
              Helper.showAlert(
                  message: "Are you sure you want to remove ${getName(item)}?",
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Get.back();
                        },
                        child: const Text("NO")),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Get.back();
                          controller.removeUser(item.jid.checkNull(), context);
                        },
                        child: const Text("YES")),
                  ], context: context);
            },
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3))),
        Visibility(
            visible: (!item.isGroupAdmin! && controller.isAdmin),
            child: ListTile(title: const Text("Make Admin", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),), onTap: () {
              Navigator.pop(context);
              // Get.back();
              Helper.showAlert(message: "Are you sure you want to make ${getName(item)} the admin?", actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Get.back();
                    },
                    child: const Text("NO")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Get.back();
                      controller.makeAdmin(item.jid.checkNull(), context);
                    },
                    child: const Text("YES")),
              ], context: context);
            },
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3))),
      ], context: context,
    );
  }

  bottomSheetView(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return SafeArea(
            child: SizedBox(
              child: Card(
                color: MirrorflyUikit.getTheme?.scaffoldColor,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10,),
                      Text("Options", style: TextStyle(
                          color: MirrorflyUikit.getTheme?.textPrimaryColor),),
                      const SizedBox(height: 10,),
                      TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            // Get.back();
                            controller.camera(context);
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: Text("Take Photo",
                              style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor, fontWeight: FontWeight.bold))),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Get.back();
                            controller.imagePicker(context);
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: Text("Choose from Gallery",
                              style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor, fontWeight: FontWeight.bold))),
                      controller.profile.image
                          .checkNull()
                          .isNotEmpty
                          ? TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Get.back();
                            controller.removeProfileImage(context);
                          },
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          child: Text(
                            "Remove Photo",
                            style: TextStyle(color: MirrorflyUikit.getTheme
                                ?.textPrimaryColor, fontWeight: FontWeight
                                .bold),
                          ))
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
