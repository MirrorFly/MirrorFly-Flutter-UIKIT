import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

import '../../../common/crop_image.dart';
import '../../chat/views/contact_list_view.dart';

class GroupCreationController extends GetxController {
  var imagePath = "".obs;
  var userImgUrl = "".obs;
  var name = "".obs;
  var loading = false.obs;

  final _count= 25.obs;
  set count(value) => _count.value = value;
  get count => _count.value.toString();

  // group name
  TextEditingController groupName = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;

  @override
  void onInit(){
    super.onInit();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });
  }

  onGroupNameChanged(){
    debugPrint("text changing");
    debugPrint("length--> ${groupName.text.length}");
    _count((25 - groupName.text.characters.length));
  }
  goToAddParticipantsPage(BuildContext context){
    if(groupName.text.trim().isNotEmpty) {
      //Get.toNamed(Routes.ADD_PARTICIPANTS);
      // Get.toNamed(Routes.contacts, arguments: {"forward" : false,"group":true,"groupJid":"" })?.then((value){
      //   if(value!=null){
      //     createGroup(value as List<String>, context);
      //   }
      // });
      Navigator.push(context, MaterialPageRoute(builder: (con) => const ContactListView(group : true, groupJid:""))).then((value){
        if(value!=null){
          createGroup(value as List<String>, context);
        }
      });

    }else{
      toToast(AppConstants.pleaseProvideGroupName);
    }
  }

  showHideEmoji(BuildContext context){
    if (!showEmoji.value) {
      focusNode.unfocus();
    }else{
      focusNode.requestFocus();
      return;
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      showEmoji(!showEmoji.value);
    });
  }


  Future imagePick(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null) {
      // isImageSelected.value = true;
      // Get.to(CropImage(
      //   imageFile: File(result.files.single.path!),
      // ))?.then((value) {
      //   value as MemoryImage;
      //   // imageBytes = value.bytes;
      //   var name ="${DateTime.now().millisecondsSinceEpoch}.jpg";
      //   writeImageTemp(value.bytes, name).then((value) {
      //     imagePath(value.path);
      //   });
      // });

      if(context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (con) =>
            CropImage(
              imageFile: File(result.files.single.path!),
            ))).then((value) {
          value as MemoryImage;
          // imageBytes = value.bytes;
          var name = "${DateTime
              .now()
              .millisecondsSinceEpoch}.jpg";
          writeImageTemp(value.bytes, name).then((value) {
            imagePath(value.path);
          });
        });
      }

    } else {
      // User canceled the picker
      // isImageSelected.value = false;
    }
  }

  final ImagePicker _picker = ImagePicker();
  camera(BuildContext context) async {
    final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera);
    if (photo != null) {
      // isImageSelected.value = true;
      // Get.to(CropImage(
      //   imageFile: File(photo.path),
      // ))?.then((value) {
      //   value as MemoryImage;
      //   // imageBytes = value.bytes;
      //   var name ="${DateTime.now().millisecondsSinceEpoch}.jpg";
      //   writeImageTemp(value.bytes, name).then((value) {
      //     imagePath(value.path);
      //   });
      // });

      if(context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (con) =>
            CropImage(
              imageFile: File(photo.path),
            ))).then((value) {
          value as MemoryImage;
          // imageBytes = value.bytes;
          var name ="${DateTime.now().millisecondsSinceEpoch}.jpg";
          writeImageTemp(value.bytes, name).then((value) {
            imagePath(value.path);
          });
        });
      }

    } else {
      // User canceled the Camera
      // isImageSelected.value = false;
    }
  }

  createGroup(List<String> users, BuildContext context){
    mirrorFlyLog("group name", groupName.text);
    mirrorFlyLog("users", users.toString());
    mirrorFlyLog("group image", imagePath.value);
    Helper.showLoading(buildContext: context);
    Mirrorfly.createGroup(groupName.text.toString(),users,imagePath.value).then((value){
      Helper.hideLoading(context: context);
      if(value!=null) {
        // Get.back();
        Navigator.pop(context);
        toToast(AppConstants.groupCreatedSuccessfully);
      }
    });
  }

  void choosePhoto(BuildContext context) {
    Helper.showVerticalButtonAlert(context, [
      ListTile(
          onTap: () {
            Navigator.pop(context);
            imagePick(context);
          },
          title: Text(AppConstants.chooseFromGallery,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),)),
      ListTile(
          onTap: () async{
            Navigator.pop(context);
            camera(context);
          },
          title: Text(AppConstants.takePhoto,style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor))),
    ]);
  }
}