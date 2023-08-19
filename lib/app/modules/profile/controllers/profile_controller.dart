import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart' as lib_phone_number;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirrorfly_uikit_plugin/app/common/AppConstants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

import '../../../common/crop_image.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import '../../../models.dart';

import '../../../data/apputils.dart';

class ProfileController extends GetxController {
  TextEditingController profileName = TextEditingController();
  TextEditingController profileEmail = TextEditingController();
  TextEditingController profileMobile = TextEditingController();
  var profileStatus = Constants.emptyString.obs;//I am in Mirror Fly
  var isImageSelected = false.obs;
  var isUserProfileRemoved = false.obs;
  var imagePath = Constants.emptyString.obs;
  var userImgUrl = Constants.emptyString.obs;
  var emailPatternMatch = RegExp(Constants.emailPattern,multiLine: false);
  var loading = false.obs;
  var changed = false.obs;

  dynamic imageBytes;
  var from = Constants.emptyString.obs;//Routes.settings.obs;

  var name = Constants.emptyString.obs;
  var nameOnImage = Constants.emptyString.obs;

  bool get emailEditAccess => true;//Get.previousRoute!=Routes.settings;
  RxBool mobileEditAccess = false.obs;//Get.previousRoute!=Routes.settings;

  var userNameFocus= FocusNode();
  var emailFocus= FocusNode();
  @override
  Future<void> onInit() async {
    super.onInit();
    userImgUrl.value = SessionManagement.getUserImage() ?? Constants.emptyString;
    mirrorFlyLog("auth : ", SessionManagement.getAuthToken().toString());
    /*if (Get.arguments != null) {
      // from(Get.arguments["from"]);
      if (from.value == Routes.login) {
        profileMobile.text = Get.arguments['mobile'] ?? Constants.emptyString;
      }
    } else {
      profileMobile.text = Constants.emptyString;
    }*/
    /*if (from.value == Routes.login) {
      if(await AppUtils.isNetConnected()) {
        getProfile();
      }else{
        toToast(AppConstants.noInternetConnection);
      }
      checkAndEnableNotificationSound();
    }else{*/
      getProfile();
    // }
    //profileStatus.value="I'm Mirror fly user";
    // await askStoragePermission(context);
  }

  Future<bool> validation() async {
    if (profileName.text
        .trim()
        .isEmpty) {
      toToast(AppConstants.pleaseEnterUserName);
      return false;
    } else if (profileName.text
        .trim()
        .length < 3) {
      toToast(AppConstants.userNameTooShort);
      return false;
    } else if (profileEmail.text
        .trim()
        .isEmpty) {
      toToast(AppConstants.emailNotEmpty);
      return false;
    } else if (!emailPatternMatch.hasMatch(profileEmail.text.toString())) {
      toToast(AppConstants.pleaseEnterValidMail);
      return false;
    } else if(!(await validMobileNumber(profileMobile.text.replaceAll("+", Constants.emptyString)))){
      toToast(AppConstants.pleaseEnterValidMobileWithCode);
      return false;
    } /*else if (profileStatus.value.isEmpty) {
      toToast("Enter Profile Status");
      return false;
    }*/else{
      return true;
    }
  }

  Future<void> save({bool frmImage = false, required BuildContext context}) async {
    // if (await askStoragePermission(context)) {
      if (await validation()){
        loading.value = true;
        if(context.mounted)showLoader(context);
        if (imagePath.value.isNotEmpty) {
          debugPrint("profile image update");
          if(context.mounted)updateProfileImage(path: imagePath.value, update: true, context: context);
        } else {
          if (await AppUtils.isNetConnected()) {
            debugPrint("profile update");
            var formattedNumber = await lib_phone_number.parse(profileMobile.text);
            debugPrint("parse-----> $formattedNumber");
            var unformatted = formattedNumber['national_number'];//profileMobile.text.replaceAll(" ", Constants.emptyString).replaceAll("+", Constants.emptyString);
            // var unformatted = profileMobile.text;
            debugPrint('unformatted : $unformatted');
            Mirrorfly
                .updateMyProfile(
                profileName.text.toString(),
                profileEmail.text.toString(),
                unformatted,
                profileStatus.value.toString(),
                userImgUrl.value.isEmpty ? null : userImgUrl.value
            )
                .then((value) {
              mirrorFlyLog("updateMyProfile", value);
              loading.value = false;
              hideLoader(context);
              if (value != null) {
                debugPrint(value);
                var data = profileUpdateFromJson(value);
                if (data.status != null) {
                  toToast(frmImage ? AppConstants.removedProfileImage : data.message.toString());
                  if (data.status!) {
                    changed(false);
                    var userProfileData = ProData(
                        email: profileEmail.text.toString(),
                        image: userImgUrl.value,
                        mobileNumber: unformatted,
                        nickName: profileName.text,
                        name: profileName.text,
                        status: profileStatus.value);
                    SessionManagement.setCurrentUser(userProfileData);
                  }
                }
              } else {
                toToast(AppConstants.unableToUpdateProfile);
              }
            }).catchError((error) {
              loading.value = false;
              hideLoader(context);
              debugPrint("issue===> $error");
              toToast(error.toString());
            });
          } else {
            loading(false);
            if(context.mounted)hideLoader(context);
            toToast(AppConstants.noInternetConnection);
          }
        }
      }
    // }
  }

  updateProfileImage({required String path, bool update = false, required BuildContext context}) async {
    if(await AppUtils.isNetConnected()) {
      loading.value = true;

      // if(checkFileUploadSize(path, Constants.mImage)) {
      if(context.mounted)showLoader(context);
        Mirrorfly.updateMyProfileImage(path).then((value) {
          mirrorFlyLog("updateMyProfileImage", value);
          loading.value = false;
          var data = json.decode(value);
          imagePath.value = Constants.emptyString;
          userImgUrl.value = data['data']['image'];
          SessionManagement.setUserImage(data['data']['image'].toString());
          hideLoader(context);
          if (update) {
            save(context: context);
          }
        }).catchError((onError) {
          debugPrint("Profile Update on error--> ${onError.toString()}");
          loading.value = false;
          hideLoader(context);
        });
      // }else{
      //   toToast("Image Size exceeds 10MB");
      // }
    }else{
      toToast(AppConstants.noInternetConnection);
    }

  }

  removeProfileImage(BuildContext context) async {
    if(await AppUtils.isNetConnected()) {
      if(context.mounted)showLoader(context);
      loading.value = true;
      Mirrorfly.removeProfileImage().then((value) {
        loading.value = false;
        hideLoader(context);
        if (value != null) {
          SessionManagement.setUserImage(Constants.emptyString);
          isImageSelected.value = false;
          isUserProfileRemoved.value = true;
          userImgUrl(Constants.emptyString);
          /*if (from.value == Routes.login) {
            changed(true);
          } else {*/
            save(frmImage: true, context: context);
          // }
          update();
        }
      }).catchError((onError) {
        loading.value = false;
        hideLoader(context);
      });
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  getProfile() async {
    //if(await AppUtils.isNetConnected()) {
      var jid = SessionManagement.getUserJID().checkNull();
      mirrorFlyLog("jid", jid);
      if (jid.isNotEmpty) {
        mirrorFlyLog("jid.isNotEmpty", jid.isNotEmpty.toString());
        loading.value = true;
        Mirrorfly.getUserProfile(jid,await AppUtils.isNetConnected()).then((value) {
          debugPrint("profile--> $value");
          insertDefaultStatusToUser();
          loading.value = false;
          var data = profileDataFromJson(value);
          if (data.status != null && data.status!) {
            if (data.data != null) {
              profileName.text = data.data!.name ?? Constants.emptyString;
              if (data.data!.mobileNumber.checkNull().isNotEmpty) {
              //if (from.value != Routes.login) {
                validMobileNumber(data.data!.mobileNumber.checkNull()).then((valid) {
                  // if(valid) profileMobile.text = data.data!.mobileNumber.checkNull();
                  mobileEditAccess(!valid);
                });
              }else {
                var userIdentifier = SessionManagement.getuserIdentifier();
                debugPrint("userIdentifier : $userIdentifier");
                validMobileNumber(userIdentifier).then((value) => mobileEditAccess(!value));
                // mobileEditAccess(true);
              }
              profileEmail.text = data.data!.email ?? Constants.emptyString;
              profileStatus.value = data.data!.status.checkNull().isNotEmpty ? data.data!.status.checkNull() : AppConstants.defaultStatus;
              userImgUrl.value = data.data!.image ?? Constants.emptyString;//SessionManagement.getUserImage() ?? Constants.emptyString;
              SessionManagement.setUserImage(Constants.emptyString);
              // changed((from.value == Routes.login));
              changed(false);
              name(data.data!.name.toString());
              nameOnImage(data.data!.name.toString());
              var userProfileData = ProData(
                  email: profileEmail.text.toString(),
                  image: userImgUrl.value,
                  mobileNumber: data.data!.mobileNumber.checkNull(),
                  nickName: profileName.text,
                  name: profileName.text,
                  status: profileStatus.value);
              SessionManagement.setCurrentUser(userProfileData);
              update();
            }
          } else {
            debugPrint("Unable to load Profile data");
            toToast(AppConstants.unableConnectServer);
          }
        }).catchError((onError) {
          loading.value = false;
          toToast(AppConstants.unableConnectServer);
        });
      }
   /* }else{
      toToast(AppConstants.noInternetConnection);
      Get.back();
    }*/

  }

  static void insertDefaultStatusToUser() async{
    try {
      await Mirrorfly.getProfileStatusList().then((value) {
        mirrorFlyLog("status list", "$value");
        if (value != null) {
          var profileStatus = statusDataFromJson(value.toString());
          if (profileStatus.isNotEmpty) {
            debugPrint("profile status list is not empty");
            var defaultStatus = Constants.defaultStatusList;

            for (var statusValue in defaultStatus) {
              var isStatusNotExist = true;
              for (var flyStatus in profileStatus) {
                if (flyStatus.status == (statusValue)) {
                  isStatusNotExist = false;
                }
              }
              if (isStatusNotExist) {
                Mirrorfly.insertDefaultStatus(statusValue);
              }
            }
          }else{
            insertStatus();
          }
        }else{
          debugPrint("status list is empty");
          insertStatus();

        }
      });
    } on Exception catch(er){
      debugPrint("Exception ==> $er");
    }
  }

  Future imagePicker(BuildContext context) async {
    if(await AppUtils.isNetConnected()) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);
      if (result != null) {
        if(checkFileUploadSize(result.files.single.path!, Constants.mImage)) {
          isImageSelected.value = true;
          if(context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (con) =>
                CropImage(
                  imageFile: File(result.files.single.path!),
                ))).then((value) {
              value as MemoryImage;
              imageBytes = value.bytes;
              var name = "${DateTime
                  .now()
                  .millisecondsSinceEpoch}.jpg";
              writeImageTemp(value.bytes, name).then((value) {
               /* if (from.value == Routes.login) {
                  imagePath(value.path);
                  changed(true);
                  update();
                } else {*/
                  imagePath(value.path);
                  changed(true);
                  updateProfileImage(
                      path: value.path, update: false, context: context);
                // }
              });
            });
          }
        }else{
          toToast(AppConstants.imageLess10mb);
        }
      } else {
        // User canceled the picker
        isImageSelected.value = false;
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
        isImageSelected.value = true;
        if(context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (con) =>
              CropImage(
                imageFile: File(photo.path),
              ))).then((value) {
            value as MemoryImage;
            imageBytes = value.bytes;
            var name = "${DateTime
                .now()
                .millisecondsSinceEpoch}.jpg";
            writeImageTemp(value.bytes, name).then((value) {
              /*if (from.value == Routes.login) {
                imagePath(value.path);
                changed(true);
                update();
              } else {*/
                imagePath(value.path);
                changed(true);
                updateProfileImage(
                    path: value.path, update: false, context: context);
              // }
            });
          });
        }
      } else {
        // User canceled the Camera
        isImageSelected.value = false;
      }
    }else{
      toToast(AppConstants.noInternetConnection);
    }
  }

  void showLoader(BuildContext context) {
    Helper.progressLoading(context: context);
  }

  /// To hide loader
  void hideLoader(BuildContext context) {
    // Helper.hideLoading();
    Navigator.pop(context);
  }

  nameChanges(String text) {
    changed(true);
    name(profileName.text.toString());
    update();
  }

  onEmailChange(String text) {
    changed(true);
    update();
  }

  onMobileChange(String text){
    changed(true);
    validMobileNumber(text.replaceAll("+", Constants.emptyString));
    update();
  }

  Future<bool> validMobileNumber(String text)async{
    var coded = text;
    if(!text.startsWith(SessionManagement.getCountryCode().checkNull().replaceAll("+", Constants.emptyString).toString())){
      mirrorFlyLog("SessionManagement.getCountryCode()", SessionManagement.getCountryCode().toString());
      coded = SessionManagement.getCountryCode().checkNull()+text;
    }
    var m = coded.contains("+") ? coded : "+$coded";
    lib_phone_number.init();
    var formatNumberSync = lib_phone_number.formatNumberSync(m);
    try {
      var parse = await lib_phone_number.parse(formatNumberSync);
      debugPrint("parse-----> $parse");
      //{country_code: 91, e164: +91xxxxxxxxxx, national: 0xxxxx xxxxx, type: mobile, international: +91 xxxxx xxxxx, national_number: xxxxxxxxxx, region_code: IN}
      if (parse.isNotEmpty) {
        var formatted = parse['international'];//.replaceAll("+", '');
        profileMobile.text = (formatted.toString());
        return true;
      } else {
        return false;
      }
    }catch(e){
      debugPrint('validMobileNumber $e');
      return false;
    }
  }

  static void insertStatus() {
    debugPrint("Inserting Status");
    var defaultStatus = Constants.defaultStatusList;

    for (var statusValue in defaultStatus) {
      Mirrorfly.insertDefaultStatus(statusValue);

    }
    // Mirrorfly.getDefaultNotificationUri().then((value) {
    //   if (value != null) {
    //     // Mirrorfly.setNotificationUri(value);
    //     SessionManagement.setNotificationUri(value);
    //   }
    // });
  }
  static void checkAndEnableNotificationSound() {

    SessionManagement.vibrationType("0");
    SessionManagement.convSound(true);
    SessionManagement.muteAll(false);

    Mirrorfly.getDefaultNotificationUri().then((value) {
      debugPrint("getDefaultNotificationUri--> $value");
      if (value != null) {
        // Mirrorfly.setNotificationUri(value);
        SessionManagement.setNotificationUri(value);
        Mirrorfly.setNotificationSound(true);
        Mirrorfly.setDefaultNotificationSound();
        SessionManagement.setNotificationSound(true);
      }
    });
  }
}
