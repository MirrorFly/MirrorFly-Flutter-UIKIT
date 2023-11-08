import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'helper.dart';

class AppPermission {
  AppPermission._();
  /*static Future<bool> getLocationPermission() async{
    var permission = await Geolocator.requestPermission();
    mirrorFlyLog(permission.name, permission.index.toString());
    return permission.index==2 || permission.index==3;
  }*/



  static Future<PermissionStatus> getContactPermission(BuildContext context) async {
    final permission = await Permission.contacts.status;
    var info = await PackageInfo.fromPlatform();
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      const newPermission = Permission.contacts;
      if(context.mounted) {
        var deniedPopupValue = await mirrorFlyPermissionDialog(
            icon: contactPermission,
            content: AppConstants.contactPermission,appName: info.appName, context: context);
        if(deniedPopupValue) {
          return await newPermission.request();
        }else {
          return newPermission.status;
        }
      }
      return newPermission.status;
    } else {
      return permission;
    }
  }

  static Future<bool> getStoragePermission(BuildContext context) async {
    var info = await PackageInfo.fromPlatform();
    var sdkVersion=0;
    if (Platform.isAndroid) {
      var sdk =  await DeviceInfoPlugin().androidInfo;
      sdkVersion=sdk.version.sdkInt;
    } else {
      sdkVersion = 0;
    }

    if (sdkVersion < 33) {
      final permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.permanentlyDenied) {
        const newPermission = Permission.storage;
        if(context.mounted) {
          var deniedPopupValue = await mirrorFlyPermissionDialog(context: context,
              icon: filePermission,
              content: AppConstants.filePermission,appName: info.appName);
          if(deniedPopupValue) {
            // return await newPermission.request().isGranted;
            var newp = await newPermission.request();
            if (newp.isGranted) {
              return true;
            } else {

                openAppSettings();
                return false;

            }
          }else{
            return newPermission.status.isGranted;
          }
        }
        return false;
      } else {
        return permission.isGranted;
      }
    } else {
      if(context.mounted) {
        return getAndroid13Permission(context);
      } else {
        return false;
      }
    }
  }
  static Future<bool> requestNotificationPermission() async {
    final PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      debugPrint('Notification permission granted');
      return true;
    } else {
      debugPrint('Notification permission denied');
      return false;
    }
  }

  static Future<bool> getAndroid13Permission(BuildContext context) async {
    var info = await PackageInfo.fromPlatform();
    final photos = await Permission.photos.status;
    final videos = await Permission.videos.status;
    ///Commenting this because mediaLibrary is only used for iOS, the above is Android 13 permission
    // final mediaLibrary = await Permission.mediaLibrary.status;
    // final audio = await Permission.audio.status;
    const newPermission = [
      Permission.photos,
      Permission.videos,
      // Permission.audio
    ];
    if ((photos != PermissionStatus.granted && photos != PermissionStatus.permanentlyDenied) ||
        (videos != PermissionStatus.granted && videos != PermissionStatus.permanentlyDenied)
        // || (mediaLibrary != PermissionStatus.granted && mediaLibrary != PermissionStatus.permanentlyDenied)
    ) {
      if(context.mounted) {
        mirrorFlyLog("showing mirror fly popup", "");
        var deniedPopupValue = await mirrorFlyPermissionDialog(context: context,
            icon: filePermission,
            content: AppConstants.filePermission,appName: info.appName);
        if(deniedPopupValue) {
          var newp = await newPermission.request();
          PermissionStatus? photo = newp[Permission.photos];
          PermissionStatus? video = newp[Permission.videos];
          // PermissionStatus? mediaLibrary = newp[Permission.mediaLibrary];
          // var audio = await newPermission[2].isGranted;
          return (photo!.isGranted && video!.isGranted);// && mediaLibrary!.isGranted);
          // ? PermissionStatus.granted
          // : PermissionStatus.denied;
        }else{
          return false;//PermissionStatus.denied;
        }
      }
      return false;
    } else {
      mirrorFlyLog("showing mirrorfly popup", "${photos.isGranted} ${videos.isGranted}");
      return (photos.isGranted && videos.isGranted);// && mediaLibrary.isGranted);
    }
  }

  static Future<bool> askAudioCallPermissions(BuildContext context) async {
    var info = await PackageInfo.fromPlatform();
    final microphone = await Permission.microphone.status; //RECORD_AUDIO
    final phone = await Permission.phone.status; //READ_PHONE_STATE
    final bluetoothConnect = await Permission.bluetoothConnect.status; //BLUETOOTH_CONNECT
    var permissions = <Permission>[];
    if(!microphone.isGranted && !SessionManagement.getBool(Constants.audioRecordPermissionAsked)){
      permissions.add(Permission.microphone);
    }
    if(!phone.isGranted && !SessionManagement.getBool(Constants.readPhoneStatePermissionAsked) && Platform.isAndroid){
      permissions.add(Permission.phone);
    }
    if(!bluetoothConnect.isGranted && !SessionManagement.getBool(Constants.bluetoothPermissionAsked) && Platform.isAndroid){
      permissions.add(Permission.bluetoothConnect);
    }
    LogMessage.d("microphone", microphone.isGranted);
    LogMessage.d("phone", phone.isGranted);
    LogMessage.d("bluetoothConnect", bluetoothConnect.isGranted);
    if ((!microphone.isGranted) ||
        (Platform.isAndroid ? !phone.isGranted : false) ||
        (Platform.isAndroid ? !bluetoothConnect.isGranted : false)) {
      var shouldShowRequestRationale = ((await Permission.microphone.shouldShowRequestRationale)
          || (await Permission.phone.shouldShowRequestRationale) ||
          (await Permission.bluetoothConnect.shouldShowRequestRationale));
      LogMessage.d("shouldShowRequestRationale audio", shouldShowRequestRationale);
      LogMessage.d("SessionManagement.getBool(Constants.audioRecordPermissionAsked) audio", (SessionManagement.getBool(Constants.audioRecordPermissionAsked)));
      LogMessage.d("permissions audio", (permissions.toString()));
      var alreadyAsked = (SessionManagement.getBool(Constants.audioRecordPermissionAsked)
          && SessionManagement.getBool(Constants.readPhoneStatePermissionAsked) &&
          SessionManagement.getBool(Constants.bluetoothPermissionAsked));
      LogMessage.d("alreadyAsked audio", alreadyAsked);

      if (shouldShowRequestRationale) {
        if(context.mounted) {
          return requestAudioCallPermissions(permissions: permissions, showFromRational: true, context: context);
        }else{
          return Future.value(false);
        }
      } else if (alreadyAsked) {
        if(context.mounted) {
          var popupValue = await customPermissionDialog(
            content: getPermissionAlertMessage("audio_call"),
            appName: info.appName,
            icon: audioPermission,
            context: context,);
          if (popupValue) {
            openAppSettings();
            return false;
          } else {
            return false;
          }
        }else{
          LogMessage.d("askAudioCallPermissions", "Context is Not Mounted");
          return false;
        }
      } else {
        if(permissions.isNotEmpty) {
          if(context.mounted) {
            return requestAudioCallPermissions(permissions: permissions, context: context);
          }else{
            return Future.value(false);
          }
        }else{
          if(context.mounted) {
            var popupValue = await customPermissionDialog(
                icon: audioPermission,
                content: getPermissionAlertMessage("audio_call"),
                appName: info.appName,
                context: context);
            if (popupValue) {
              openAppSettings();
              return false;
            } else {
              return false;
            }
          }else{
            LogMessage.d("askAudioCallPermissions", "Context is Not Mounted");
            return false;
          }
        }
      }
    }else{
      return true;
    }
  }

  static Future<bool> requestAudioCallPermissions({required List<Permission> permissions,bool showFromRational = false, required BuildContext context}) async {
    var info = await PackageInfo.fromPlatform();
    if(context.mounted) {
      var deniedPopupValue = await mirrorFlyPermissionDialog(
          icon: audioPermission,
          content: Constants.audioCallPermission,
          context: context,
          appName: info.appName);
      if (deniedPopupValue) {
        var newp = await permissions.request();
        PermissionStatus? microphone_ = newp[Permission.microphone];
        PermissionStatus? phone_ = newp[Permission.phone];
        PermissionStatus? bluetoothConnect_ = newp[Permission.bluetoothConnect];
        if (microphone_ != null && microphone_.isPermanentlyDenied) {
          LogMessage.d("microphone_", microphone_.isPermanentlyDenied);
          SessionManagement.setBool(Constants.audioRecordPermissionAsked, true);
        }
        if (phone_ != null && phone_.isPermanentlyDenied) {
          LogMessage.d("phone_", phone_.isPermanentlyDenied);
          SessionManagement.setBool(
              Constants.readPhoneStatePermissionAsked, true);
        }
        if (bluetoothConnect_ != null &&
            bluetoothConnect_.isPermanentlyDenied) {
          LogMessage.d(
              "bluetoothConnect_", bluetoothConnect_.isPermanentlyDenied);
          SessionManagement.setBool(Constants.bluetoothPermissionAsked, true);
        }
        return (microphone_?.isGranted ?? true) &&
            (phone_?.isGranted ?? true) &&
            (bluetoothConnect_?.isGranted ?? true);
      } else {
        return false;
      }
    }else{
      LogMessage.d("requestAudioCallPermissions", "Context is Not Mounted");
      return false;
    }
  }

  static Future<bool> askVideoCallPermissions(BuildContext context) async {
    var info = await PackageInfo.fromPlatform();
    final microphone = await Permission.microphone.status; //RECORD_AUDIO
    final phone = await Permission.phone.status; //READ_PHONE_STATE
    final bluetoothConnect =
    await Permission.bluetoothConnect.status; //BLUETOOTH_CONNECT
    final camera = await Permission.camera.status; //CAMERA
    var permissions = <Permission>[];
    if(!camera.isGranted && !SessionManagement.getBool(Constants.cameraPermissionAsked)){
      permissions.add(Permission.camera);
    }
    if(!microphone.isGranted && !SessionManagement.getBool(Constants.audioRecordPermissionAsked)){
      permissions.add(Permission.microphone);
    }
    if(!phone.isGranted && !SessionManagement.getBool(Constants.readPhoneStatePermissionAsked)){
      permissions.add(Permission.phone);
    }
    if(!bluetoothConnect.isGranted && !SessionManagement.getBool(Constants.bluetoothPermissionAsked)){
      permissions.add(Permission.bluetoothConnect);
    }
    if ((microphone != PermissionStatus.granted) || (phone != PermissionStatus.granted) || (camera != PermissionStatus.granted) || (bluetoothConnect != PermissionStatus.granted)) {
      var shouldShowRequestRationale = ((await Permission.camera.shouldShowRequestRationale) ||
          (await Permission.microphone.shouldShowRequestRationale)
          || (await Permission.phone.shouldShowRequestRationale) ||
          (await Permission.bluetoothConnect.shouldShowRequestRationale));
      LogMessage.d("shouldShowRequestRationale video", shouldShowRequestRationale);
      LogMessage.d("SessionManagement.getBool(Constants.cameraPermissionAsked) video", SessionManagement.getBool(Constants.cameraPermissionAsked));
      var alreadyAsked = (SessionManagement.getBool(Constants.cameraPermissionAsked) &&
          SessionManagement.getBool(Constants.audioRecordPermissionAsked)
          && SessionManagement.getBool(Constants.readPhoneStatePermissionAsked) &&
          SessionManagement.getBool(Constants.bluetoothPermissionAsked));
      LogMessage.d("alreadyAsked video", alreadyAsked);
      if (shouldShowRequestRationale) {
        if(context.mounted) {
          return requestAudioCallPermissions(permissions: permissions, context: context);
        }else{
          return Future.value(false);
        }
      } else if (alreadyAsked) {
        if(context.mounted) {
          var popupValue = await customPermissionDialog(
              icon: recordAudioVideoPermission,
              content: getPermissionAlertMessage("video_call"),
              appName: info.appName,
              context: context);
          if (popupValue) {
            openAppSettings();
            return false;
          } else {
            return false;
          }
        }else{
          LogMessage.d("requestAudioCallPermissions customPermissionDialog", "Context is Not Mounted");
          return false;
        }
      } else {
        if(permissions.isNotEmpty) {
          if(context.mounted) {
            return requestAudioCallPermissions(permissions: permissions, context: context);
          }else{
            return Future.value(false);
          }
        }else{
          if(context.mounted) {
            var popupValue = await customPermissionDialog(
                icon: recordAudioVideoPermission,
                content: getPermissionAlertMessage("video_call"),
                appName: info.appName,
                context: context);
            if (popupValue) {
              openAppSettings();
              return false;
            } else {
              return false;
            }
          }else{
            LogMessage.d("askVideoCallPermissions", "Context is Not Mounted");
            return false;
          }
        }
      }
    }else{
      return true;
    }
  }

  static Future<bool> requestVideoCallPermissions({required List<Permission> permissions, bool showFromRational = false, required BuildContext context}) async {
    var info = await PackageInfo.fromPlatform();
    if(context.mounted) {
      var deniedPopupValue = await mirrorFlyPermissionDialog(
          icon: recordAudioVideoPermission,
          content: Constants.videoCallPermission, context: context, appName: info.appName);
      if (deniedPopupValue) {
        var newp = await permissions.request();
        PermissionStatus? microphone_ = newp[Permission.microphone];
        PermissionStatus? phone_ = newp[Permission.phone];
        PermissionStatus? camera_ = newp[Permission.camera];
        PermissionStatus? bluetoothConnect_ = newp[Permission.bluetoothConnect];
        if (camera_ != null && camera_.isPermanentlyDenied) {
          SessionManagement.setBool(Constants.cameraPermissionAsked, true);
        }
        if (microphone_ != null && microphone_.isPermanentlyDenied) {
          SessionManagement.setBool(Constants.audioRecordPermissionAsked, true);
        }
        if (phone_ != null && phone_.isPermanentlyDenied) {
          SessionManagement.setBool(Constants.readPhoneStatePermissionAsked, true);
        }
        if (bluetoothConnect_ != null && bluetoothConnect_.isPermanentlyDenied) {
          SessionManagement.setBool(Constants.bluetoothPermissionAsked, true);
        }
        return (camera_?.isGranted ?? true) && (microphone_?.isGranted ?? true) && (phone_?.isGranted ?? true) &&
            (bluetoothConnect_?.isGranted ?? true);
      } else {
        return false;
      }
    }else{
      LogMessage.d("requestAudioCallPermissions", "Context is Not Mounted");
      return false;
    }
  }
  static Future<bool> askiOSVideoCallPermissions(BuildContext context) async {
    var info = await PackageInfo.fromPlatform();

    final microphone = await Permission.microphone.status;//RECORD_AUDIO
    final camera = await Permission.camera.status;
    const newPermission = [
      Permission.microphone,
      Permission.camera,
    ];
    if((microphone != PermissionStatus.granted && microphone != PermissionStatus.permanentlyDenied) || (camera != PermissionStatus.granted && camera != PermissionStatus.permanentlyDenied)){
      if(context.mounted) {
        var permissionPopupValue = await mirrorFlyPermissionDialog(
            icon: recordAudioVideoPermission,
            content: Constants.videoCallPermission,
            appName: info.appName,
            context: context);
        if (permissionPopupValue) {
          var newp = await newPermission.request();
          PermissionStatus? speech_ = newp[Permission.microphone];
          PermissionStatus? camera_ = newp[Permission.camera];
          return (speech_!.isGranted && camera_!.isGranted);
        } else {
          toToast("Need Camera and Microphone Permission to Make Video Call");
          return false;
        }
      }else{
        LogMessage.d("askiOSVideoCallPermissions mirrorFlyPermissionDialog", "Context is Not Mounted");
        return false;
      }
    }else if ((microphone == PermissionStatus.permanentlyDenied) || (camera == PermissionStatus.permanentlyDenied)){
      if(context.mounted){
        var popupValue = await customPermissionDialog(
            icon: audioPermission,
            content: getPermissionAlertMessage("audio_call"), appName: info.appName, context: context);
        if (popupValue) {
          openAppSettings();
          return false;
        } else {
          return false;
        }
      }else{
        LogMessage.d("askiOSVideoCallPermissions customPermissionDialog", "Context is Not Mounted");
        return false;
      }
    } else{
      return (microphone.isGranted && camera.isGranted);
    }
  }

  static String getPermissionAlertMessage(String permission) {
    var permissionAlertMessage = "";
    var permissionName = permission;

    switch (permissionName.toLowerCase()) {
      case "camera":
        permissionAlertMessage = Constants.cameraPermissionDenied;
        break;
      case "microphone":
        permissionAlertMessage = Constants.microPhonePermissionDenied;
        break;
      case "storage":
        permissionAlertMessage = Constants.storagePermissionDenied;
        break;
      case "contacts":
        permissionAlertMessage = Constants.contactPermissionDenied;
        break;
      case "location":
        permissionAlertMessage = Constants.locationPermissionDenied;
        break;
      case "audio_call":
        permissionAlertMessage = Constants.audioCallPermissionDenied;
        break;
      case "video_call":
        permissionAlertMessage = Constants.videoCallPermissionDenied;
        break;
      default:
        permissionAlertMessage =
        "MirrorFly need the ${permissionName.toUpperCase()} Permission. But they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"${permissionName.toUpperCase()}\"";
    }
    return permissionAlertMessage;
  }

  static Future<PermissionStatus> getManageStoragePermission() async {
    final permission = await Permission.manageExternalStorage.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      final newPermission = await Permission.manageExternalStorage.request();
      return newPermission;
    } else {
      return permission;
    }
  }

  //not used so var deniedPopupValue = await not imple
  static Future<PermissionStatus> getCameraPermission(BuildContext context) async {
    var info = await PackageInfo.fromPlatform();
    final permission = await Permission.camera.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      const newPermission = Permission.camera;
      if(context.mounted) {
        mirrorFlyPermissionDialog(
            notNowBtn: () {
              return false;
            },
            continueBtn: () async {
              newPermission.request();
            },
            icon: cameraPermission,
            content: AppConstants.cameraPermission,appName: info.appName, context: context);
      }
      return newPermission.status;
    } else {
      return permission;
    }
  }

  //not used so var deniedPopupValue = await not imple
  static Future<PermissionStatus> getAudioPermission(BuildContext context) async {
    var info = await PackageInfo.fromPlatform();
    final permission = await Permission.microphone.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      const newPermission = Permission.microphone;
      if(context.mounted) {
        mirrorFlyPermissionDialog(
            notNowBtn: () {
              return false;
            },
            continueBtn: () async {
              newPermission.request();
            },
            icon: audioPermission,
            content: AppConstants.audioPermission,appName: info.appName, context: context);
      }
      return newPermission.status;
    } else {
      return permission;
    }
  }

  //not used so var deniedPopupValue = await not imple
  static Future<bool> askFileCameraAudioPermission(BuildContext context) async {
    var info = await PackageInfo.fromPlatform();
    var filePermission = Permission.storage;
    var camerapermission = Permission.camera;
    var audioPermission = Permission.microphone;
    if (await filePermission.isGranted == false ||
        await camerapermission.isGranted == false ||
        await audioPermission.isGranted == false) {
      if(context.mounted) {
        mirrorFlyPermissionDialog(
            notNowBtn: () {
              return false;
            },
            continueBtn: () async {
              if (await requestPermission(filePermission) &&
                  await requestPermission(camerapermission) &&
                  await requestPermission(audioPermission)) {
                return true;
              } else {
                return false;
              }
            },
            icon: cameraPermission,
            content: AppConstants.cameraPermission,appName: info.appName, context: context);
      }
    } else {
      return true;
    }
    return false;
  }

  static Future<bool> requestPermission(Permission permission) async {
    var status1 = await permission.status;
    mirrorFlyLog('status', status1.toString());
    if (status1 == PermissionStatus.denied &&
        status1 != PermissionStatus.permanentlyDenied) {
      mirrorFlyLog('permission.request', status1.toString());
      final status = await permission.request();
      return status.isGranted;
    }
    return status1.isGranted;
  }

  static Future<bool> checkPermission(BuildContext context,Permission permission, String permissionIcon, String permissionContent) async {
    var info = await PackageInfo.fromPlatform();
    var status = await permission.status;
    if (status == PermissionStatus.granted) {
      debugPrint("permission granted opening");
      return true;
    }else if(status == PermissionStatus.permanentlyDenied){
      mirrorFlyLog('permanentlyDenied', 'permission');
      var permissionAlertMessage = "";
      var permissionName = "$permission";
      permissionName = permissionName.replaceAll("Permission.", "");

      switch (permissionName.toLowerCase()){
        case "camera":
          permissionAlertMessage = AppConstants.cameraPermissionDenied;
          break;
        case "microphone":
          permissionAlertMessage = AppConstants.microPhonePermissionDenied;
          break;
        case "storage":
          permissionAlertMessage = AppConstants.storagePermissionDenied;
          break;
        case "contacts":
          permissionAlertMessage = AppConstants.contactPermissionDenied;
          break;
        case "location":
          permissionAlertMessage = AppConstants.locationPermissionDenied;
          break;
        default:
          permissionAlertMessage = "${info.appName} need the ${permissionName.toUpperCase()} Permission.${AppConstants.otherPermissionDenied} \"${permissionName.toUpperCase()}\"";
      }
      if(context.mounted) {
        var deniedPopupValue = await customPermissionDialog(context : context, icon: permissionIcon, content: permissionAlertMessage, appName: info.appName);
        if(deniedPopupValue){
          openAppSettings();
          return false;
        }else{
          return false;
        }
      }else {
        return false;
      }
      /*var deniedPopupValue = await customPermissionDialog(context,icon: permissionIcon,
          content: permissionAlertMessage,appName: info.appName);
      if(deniedPopupValue){
        openAppSettings();
        return false;
      }else{
        return false;
      }*/
    }else{
      // mirrorFlyLog('denied', 'permission');
      if(context.mounted) {
        var popupValue = await customPermissionDialog(context: context,icon: permissionIcon,
            content: permissionContent,appName: info.appName);
        if(popupValue){
          return AppPermission.requestPermission(permission);
        }else{
          return false;
        }
      }else{
        return false;
      }
      /*var popupValue = await customPermissionDialog(context,icon: permissionIcon,
          content: permissionContent,appName: info.appName);
      if(popupValue){
        return AppPermission.requestPermission(permission);
      }else{
        return false;
      }*/
    }
  }

  static permissionDeniedDialog({required String content, required BuildContext context}){
    Helper.showAlert(
        message:
        content,
        title: "Permission Denied",
        actions: [
          TextButton(
              onPressed: () {
                // Get.back();
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text("OK")),
        ], context: context);
  }
  static Future<bool> mirrorFlyPermissionDialog({required BuildContext context,
      Function()? notNowBtn,
      Function()? continueBtn,
      required String icon,
      required String content,required String appName}) async {
    return await showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: MirrorflyUikit.theme == "dark" ? darkPopupColor : Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 35.0),
            color: MirrorflyUikit.getTheme?.primaryColor,// buttonBgColor,
            child: Center(child: SvgPicture.asset(icon,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnPrimary, BlendMode.srcIn),)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content.replaceAll('Mirrorfly', appName),
              style: TextStyle(fontSize: 14, color: MirrorflyUikit.getTheme?.textPrimaryColor),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context,false);
              // Get.back(result: "no");
              // notNowBtn();
            },
            child: Text(
              "NOT NOW",
              style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
            )),
        TextButton(
            onPressed: () {
              Navigator.pop(context,true);
              // Get.back(result: "yes");
              // continueBtn();
            },
            child: Text(
              "CONTINUE",
              style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
            ))
      ],
    ); },);
  }

  static Future<bool> customPermissionDialog({required BuildContext context,
      required String icon,
      required String content,required String appName}) async {
    return await showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: MirrorflyUikit.theme == "dark" ? darkPopupColor : Colors.white,
      // shadowColor: MirrorflyUikit.getTheme?.textSecondaryColor,
      // elevation: 4,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 35.0),
            color: MirrorflyUikit.getTheme?.primaryColor,
            child: Center(child: SvgPicture.asset(icon,package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnPrimary, BlendMode.srcIn),)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content.replaceAll('Mirrorfly', appName),
              style: TextStyle(fontSize: 14, color: MirrorflyUikit.getTheme?.textPrimaryColor),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context,false);
              // Get.back(result: false);
              // notNowBtn();
            },
            child: Text(
              "NOT NOW",
              style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
            )),
        TextButton(
            onPressed: () {
              Navigator.pop(context,true);
              // Get.back(result: true);
              // continueBtn();
            },
            child:  Text(
              "CONTINUE",
              style: TextStyle(color: MirrorflyUikit.getTheme?.primaryColor),
            ))
      ],
    ); },);
  }
}
