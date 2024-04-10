import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/model/available_features.dart';
import 'package:mirrorfly_plugin/model/callback.dart';
import 'package:mirrorfly_plugin/model/recent_chat.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/data/permissions.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/image_view/views/image_view_view.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../mirrorfly_uikit_plugin.dart';
import '../call_modules/outgoing_call/outgoing_call_view.dart';
import '../common/widgets.dart';
import '../model/chat_message_model.dart';
import 'apputils.dart';

class Helper {
  static void showLoading(
      {String? message,
      bool dismiss = false,
      required BuildContext buildContext}) {
    showDialog(
      barrierDismissible: false,
      context: buildContext,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              MirrorflyUikit.theme == "dark" ? darkPopupColor : Colors.white,
          child: PopScope(
            canPop: dismiss,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: MirrorflyUikit.getTheme?.primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    message ?? 'Loading...',
                    style: TextStyle(
                        color: MirrorflyUikit.getTheme?.textPrimaryColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void progressLoading(
      {bool dismiss = false, required BuildContext context}) {
    showDialog(
        barrierDismissible: dismiss,
        barrierColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: PopScope(
              canPop: dismiss,
              onPopInvoked: (didPop) {
                if (didPop) {
                  return;
                }
              },
              child: SizedBox(
                width: 60,
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(
                    color: MirrorflyUikit.getTheme?.primaryColor,
                  ),
                ),
              ),
            ),
          );
        });
  }

  static void showAlert(
      {String? title,
      required String message,
      List<Widget>? actions,
      Widget? content,
      required BuildContext context,
      bool? barrierDismissible}) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible ?? true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              MirrorflyUikit.theme == "dark" ? darkPopupColor : Colors.white,
          title: title != null
              ? Text(
                  title,
                  style: TextStyle(
                      fontSize: 17,
                      color: MirrorflyUikit.getTheme?.textPrimaryColor),
                )
              : const SizedBox.shrink(),
          contentPadding: title != null
              ? const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 0)
              : const EdgeInsets.only(top: 0, right: 25, left: 25, bottom: 5),
          content: content ??
              Text(
                message,
                style: TextStyle(
                    color: MirrorflyUikit.getTheme?.textSecondaryColor,
                    fontWeight: FontWeight.normal),
              ),
          contentTextStyle: TextStyle(
              color: MirrorflyUikit.getTheme?.textSecondaryColor,
              fontWeight: FontWeight.w500),
          actions: actions,
        );
      },
    );
  }

  static void showVerticalButtonAlert(
      BuildContext context, List<Widget> actions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              MirrorflyUikit.theme == "dark" ? darkPopupColor : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: actions,
          ),
        );
      },
    );
  }

  static void showButtonAlert(
      {List<Widget>? actions, required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: actions,
        );
      },
    );
  }

//hide loading
  static void hideLoading({required BuildContext context}) {
    // if (Get.isDialogOpen!) {
    //   Get.back(
    //     canPop: true,
    //   );
    // }
    Navigator.pop(context);
  }

  static void showFeatureUnavailable(BuildContext context) {
    Helper.showAlert(
        message: "Feature unavailable for your plan",
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Ok")),
        ],
        context: context);
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String durationToString(Duration duration) {
    debugPrint("duration conversion $duration");
    String hours = (duration.inHours == 00)
        ? ""
        : "${duration.inHours.toStringAsFixed(0).padLeft(2, '0')}:"; // Get hours
    int minutes = duration.inMinutes % 60; // Get minutes
    var seconds =
        ((duration.inSeconds % 60)).toStringAsFixed(0).padLeft(2, '0');
    return '$hours${minutes.toStringAsFixed(0).padLeft(2, '0')}:$seconds';
  }

  static String getMapImageUri(double latitude, double longitude) {
    var key = MirrorflyUikit.instance.googleMapKey; //Constants.googleMapKey;
    return ("https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=300x200&markers=color:red|$latitude,$longitude&key=$key");
  }

  static int getColourCode(String name) {
    if (name == Constants.you) return 0Xff000000;
    var colorsArray = AppConstants.defaultColorList;
    var hashcode = name.hashCode;
    var rand = hashcode % colorsArray.length;
    return colorsArray[(rand).abs()];
  }

  static Widget forMessageTypeIcon(String? messageType,
      [bool isAudioRecorded = false]) {
    mirrorFlyLog("iconfor", messageType.toString());
    switch (messageType?.toUpperCase()) {
      case Constants.mImage:
        return SvgPicture.asset(
          mImageIcon,
          package: package,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mAudio:
        return SvgPicture.asset(
          isAudioRecorded ? mAudioRecordIcon : mAudioIcon,
          package: package,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mVideo:
        return SvgPicture.asset(
          mVideoIcon,
          package: package,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mDocument:
        return SvgPicture.asset(
          mDocumentIcon,
          package: package,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mFile:
        return SvgPicture.asset(
          mDocumentIcon,
          package: package,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mContact:
        return SvgPicture.asset(
          mContactIcon,
          package: package,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mLocation:
        return SvgPicture.asset(
          mLocationIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static String forMessageTypeString(String? messageType) {
    switch (messageType?.toUpperCase()) {
      case Constants.mImage:
        return "Image";
      case Constants.mAudio:
        return "Audio";
      case Constants.mVideo:
        return "Video";
      case Constants.mDocument:
        return "Document";
      case Constants.mFile:
        return "Document";
      case Constants.mContact:
        return "Contact";
      case Constants.mLocation:
        return "Location";
      default:
        return "";
    }
  }

  static String capitalize(String str) {
    return "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}";
  }
}

bool checkFileUploadSize(String path, String mediaType) {
  var file = File(path);
  int sizeInBytes = file.lengthSync();
  // debugPrint("file size --> $sizeInBytes");
  double sizeInMb = sizeInBytes / (1024 * 1024);
  // debugPrint("sizeInBytes $sizeInMb");

  // debugPrint(getFileSizeText(sizeInBytes.toString()));

  if (mediaType == Constants.mImage && sizeInMb <= Constants.maxImageFileSize) {
    return true;
  } else if (mediaType == Constants.mAudio &&
      sizeInMb <= Constants.maxAudioFileSize) {
    return true;
  } else if (mediaType == Constants.mVideo &&
      sizeInMb <= Constants.maxVideoFileSize) {
    return true;
  } else if (mediaType == Constants.mDocument &&
      sizeInMb <= Constants.maxDocFileSize) {
    return true;
  } else {
    return false;
  }
}

String getFileSizeText(String fileSizeInBytes) {
  var fileSizeBuilder = "";
  var fileSize = int.parse(fileSizeInBytes);
  if (fileSize > 1073741824) {
    fileSizeBuilder =
        (getRoundedFileSize(fileSize / 1073741824)).toString() + (" ") + ("GB");
  } else if (fileSize > 1048576) {
    fileSizeBuilder =
        (getRoundedFileSize(fileSize / 1048576)).toString() + (" ") + ("MB");
  } else if (fileSize > 1024) {
    fileSizeBuilder =
        (getRoundedFileSize(fileSize / 1024)).toString() + (" ") + ("KB");
  } else {
    fileSizeBuilder = (fileSizeInBytes).toString() + (" ") + ("bytes");
  }
  return fileSizeBuilder.toString();
}

double getRoundedFileSize(double unscaledValue) {
  //return BigDecimal.valueOf(unscaledValue).setScale(2, RoundingMode.HALF_UP).toDouble()
  return unscaledValue.roundToDouble();
}

extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0";
    final units = ["bytes", "KB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).round();
    return "${NumberFormat("#,##0.#").format(this / pow(base, digitGroups))} ${units[digitGroups]}";
  }
}

String getDateFromTimestamp(int convertedTime, String format) {
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  return DateFormat(format).format(calendar);
}

Future<ProfileDetails> getProfileDetails(String jid) async {
  // debugPrint("getProfileDetails jid $jid");
  var value = await Mirrorfly.getProfileDetails(jid: jid.checkNull());
  // var profile = profiledata(value.toString());
  // var profile = await compute(profiledata, value.toString());
  // debugPrint("profile ${profile.name}");
  var profile = ProfileDetails.fromJson(json.decode(value.toString()));
  return profile;
}

Future<ChatMessageModel> getMessageOfId(String mid) async {
  var value = await Mirrorfly.getMessageOfId(messageId: mid.checkNull());
  // debugPrint("message--> $value");
  var chatMessage = await compute(sendMessageModelFromJson, value.toString());
  return chatMessage;
}

String returnFormattedCount(int count) {
  return (count > 99) ? "99+" : count.toString();
}

InkWell listItem(
    {Widget? leading,
    required Widget title,
    Widget? trailing,
    required Function() onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          leading != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0), child: leading)
              : const SizedBox(),
          Expanded(
            child: title,
          ),
          trailing ?? const SizedBox()
        ],
      ),
    ),
  );
}

String getRecentChatTime(BuildContext context, int? epochTime) {
  if (epochTime == null) return "";
  if (epochTime == 0) return "";
  var convertedTime = epochTime; // / 1000;
  //messageDate.time = convertedTime
  var hourTime = manipulateMessageTime(
      context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
  var currentYear = DateTime.now().year;
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  var time = (currentYear == calendar.year)
      ? DateFormat("dd-MMM").format(calendar)
      : DateFormat("yyyy/MM/dd").format(calendar);
  return (equalsWithYesterday(calendar, Constants.today))
      ? hourTime
      : (equalsWithYesterday(calendar, Constants.yesterday))
          ? AppConstants.yesterday.toUpperCase()
          : time;
}

String manipulateMessageTime(BuildContext context, DateTime messageDate) {
  var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
  calendar = messageDate;
  var hours = calendar.hour; //calendar[Calendar.HOUR]
  var dateHourFormat = setDateHourFormat(format, hours);
  return DateFormat(dateHourFormat).format(messageDate);
}

String setDateHourFormat(int format, int hours) {
  var dateHourFormat = (format == 12)
      ? (hours < 10)
          ? "hh:mm aa"
          : "h:mm aa"
      : (hours < 10)
          ? "HH:mm"
          : "H:mm";
  return dateHourFormat;
}

bool equalsWithYesterday(DateTime srcDate, String day) {
  if (day == Constants.yesterday) {
    var messageDate = DateFormat('yyyy/MM/dd').format(srcDate);
    var yesterdayDate = DateFormat('yyyy/MM/dd').format(DateTime.now().subtract(
        const Duration(
            days: 1, hours: 0, minutes: 0, seconds: 0, milliseconds: 0)));
    return yesterdayDate == messageDate;
  } else {
    return equalsWithToday(srcDate, day);
  }
}

bool equalsWithToday(DateTime srcDate, String day) {
  var today = DateFormat('yyyy/MM/dd').format(DateTime.now());
  var messageDate = DateFormat('yyyy/MM/dd').format(srcDate);
  return messageDate == today;
}

var calendar = DateTime.now();

String getChatTime(BuildContext context, int? epochTime) {
  // debugPrint("epochTime--> $epochTime");
  if (epochTime == null) return "";
  if (epochTime == 0) return "";
  var convertedTime = epochTime;
  // var convertedTime = Platform.isAndroid ? epochTime : epochTime * 1000; // / 1000;
  // debugPrint("epoch convertedTime---> $convertedTime");
  var hourTime = manipulateMessageTime(
      context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
  // calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  //debugPrint('hourTime $hourTime');
  return hourTime;
}

bool checkFile(String mediaLocalStoragePath) {
  return mediaLocalStoragePath.isNotEmpty &&
      File(mediaLocalStoragePath).existsSync();
}

/*checkIosFile(String mediaLocalStoragePath) async {
  var isExists = await Mirrorfly.iOSFileExist(mediaLocalStoragePath);
  return isExists;
}*/

openDocument(String mediaLocalStoragePath) async {
  // if (await askStoragePermission()) {
  if (mediaLocalStoragePath.isNotEmpty) {
    final result = await OpenFile.open(mediaLocalStoragePath);
    debugPrint(result.message);
    if (result.message.contains("file does not exist")) {
      toToast(AppConstants.fileDoesNotExist);
    } else if (result.message.contains('No APP found to open this file')) {
      toToast(AppConstants.youDoNotHaveApp);
    }
  } else {
    debugPrint("media does not exist");
  }
  // }
}

Future<void> launchInBrowser(String url) async {
  if (await AppUtils.isNetConnected()) {
    var webUrl = url.replaceAll("http://", "").replaceAll("https://", "");
    final Uri toLaunch = Uri(scheme: 'https', host: webUrl);
    if (!await launchUrl(
      toLaunch,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  } else {
    toToast(AppConstants.noInternetConnection);
  }
}

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  // if (await canLaunch(launchUri.toString())) {
  //   await launch(launchUri.toString());
  // } else {
  //   throw 'Could not launch $launchUri';
  // }
  // try {
  //   var cellphone = '7192822224';
  //   await launch('tel://$cellphone');
  //
  // }catch (e){
  //   throw 'Could not launch $e';
  // }
  await launchUrl(launchUri);
}

launchCaller(String phoneNumber) async {
  // var url = "tel:$phoneNumber";
  // if (await canLaunch(url)) {
  //   await launch(url);
  // } else {
  //   throw 'Could not launch $url';
  // }
  canLaunchUrl(Uri(scheme: 'tel', path: phoneNumber)).then((bool result) {
    debugPrint("success");
  });
}

Future<void> launchEmail(String emailID) async {
  // String? encodeQueryParameters(Map<String, String> params) {
  //   return params.entries
  //       .map((MapEntry<String, String> e) =>
  //   '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
  //       .join('&');
  // }

  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: emailID,
    // query: encodeQueryParameters(<String, String>{
    //   'subject': 'Example Subject & Symbols are allowed!',
    // }),
  );
  await launchUrl(emailLaunchUri);
}

class Triple {
  Triple(this.singleOrgroupJid, this.userId, this.typingStatus);

  String singleOrgroupJid;
  String userId;
  bool typingStatus;
}

Future<RecentChatData?> getRecentChatOfJid(String jid) async {
  var value = await Mirrorfly.getRecentChatOf(jid: jid);
  mirrorFlyLog("chat", value.toString());
  var data = recentChatDataFromJson(value);
  return data;
}

String getName(ProfileDetails item) {
  if (!Constants.enableContactSync) {
    /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
    return item.name.checkNull().isEmpty
        ? (item.nickName.checkNull().isEmpty
            ? item.mobileNumber.checkNull()
            : item.nickName.checkNull())
        : item.name.checkNull();
  } else {
    if (item.jid.checkNull() == SessionManagement.getUserJID()) {
      return Constants.you;
    } else if (item.isDeletedContact()) {
      mirrorFlyLog('isDeletedContact', item.isDeletedContact().toString());
      return Constants.deletedUser;
    } else if (item.isUnknownContact() || item.nickName.checkNull().isEmpty) {
      mirrorFlyLog('isUnknownContact', item.isUnknownContact().toString());
      return item.mobileNumber.checkNull().isNotEmpty
          ? item.mobileNumber.checkNull()
          : getMobileNumberFromJid(item.jid.checkNull());
    } else {
      mirrorFlyLog('nickName', item.nickName.toString());
      return item.nickName.checkNull();
    }
    /*var status = true;
    if(status) {
      return item.nickName
          .checkNull()
          .isEmpty
          ? (item.name
          .checkNull()
          .isEmpty
          ? item.mobileNumber.checkNull()
          : item.name.checkNull())
          : item.nickName.checkNull();
    }else{
      return item.mobileNumber.checkNull();
    }*/
  }
}

String getRecentName(RecentChatData item) {
  if (!Constants.enableContactSync) {
    /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
    return item.profileName.checkNull().isEmpty
        ? item.nickName.checkNull()
        : item.profileName.checkNull();
  } else {
    if (item.jid.checkNull() == SessionManagement.getUserJID()) {
      return Constants.you;
    } else if (item.isDeletedContact()) {
      mirrorFlyLog('isDeletedContact', item.isDeletedContact().toString());
      return Constants.deletedUser;
    } else if (item.isUnknownContact() || item.nickName.checkNull().isEmpty) {
      mirrorFlyLog('isUnknownContact', item.jid.toString());
      return getMobileNumberFromJid(item.jid.checkNull());
    } else {
      mirrorFlyLog('nickName', item.nickName.toString());
      return item.nickName.checkNull();
    }
  }
}

String getMemberName(ProfileDetails item) {
  if (!Constants.enableContactSync) {
    /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
    return item.name.checkNull().isEmpty
        ? (item.nickName.checkNull().isEmpty
            ? item.mobileNumber.checkNull()
            : item.nickName.checkNull())
        : item.name.checkNull();
  } else {
    if (item.jid.checkNull() == SessionManagement.getUserJID()) {
      return Constants.you;
    } else if (item.isDeletedContact()) {
      mirrorFlyLog('isDeletedContact', item.isDeletedContact().toString());
      return Constants.deletedUser;
    } else if (item.isUnknownContact() || item.nickName.checkNull().isEmpty) {
      mirrorFlyLog('isUnknownContact', item.isUnknownContact().toString());
      return item.mobileNumber.checkNull().isNotEmpty
          ? item.mobileNumber.checkNull()
          : getMobileNumberFromJid(item.jid.checkNull());
    } else {
      mirrorFlyLog('nickName', item.nickName.toString());
      return item.nickName.checkNull();
    }
    /*var status = true;
    if(status) {
      return item.nickName
          .checkNull()
          .isEmpty
          ? (item.name
          .checkNull()
          .isEmpty
          ? item.mobileNumber.checkNull()
          : item.name.checkNull())
          : item.nickName.checkNull();
    }else{
      return item.mobileNumber.checkNull();
    }*/
  }
}

bool isValidPhoneNumber(String s) {
  if (s.length > 13 || s.length < 6) return false;
  return hasMatch(s, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
}

bool hasMatch(String? value, String pattern) {
  return (value == null) ? false : RegExp(pattern).hasMatch(value);
}

String getMobileNumberFromJid(String jid) {
  var str = jid.split('@');
  return str[0];
}

String convertSecondToLastSeen(String seconds) {
  if (seconds.isNotEmpty) {
    if (seconds == "0") return AppConstants.online;
    // var userLastSeenDate = DateTime.now().subtract(Duration(milliseconds: double.parse(seconds).toInt()));
    DateTime lastSeen =
        DateTime.fromMillisecondsSinceEpoch(double.parse(seconds).toInt());
    Duration diff = DateTime.now().difference(lastSeen);

    if (int.parse(DateFormat('yyyy').format(lastSeen)) <
        int.parse(DateFormat('yyyy').format(DateTime.now()))) {
      return '${AppConstants.lastSeenOn} ${DateFormat('dd/mm/yyyy')}';
    } else if (diff.inDays > 1) {
      return '${AppConstants.lastSeenOn} ${DateFormat('dd MMM').format(lastSeen)}';
    } else if (diff.inDays == 1) {
      return AppConstants.lastSeenYesterday;
    } else if (diff.inHours >= 1 ||
        diff.inMinutes >= 1 ||
        diff.inSeconds >= 1) {
      return '${AppConstants.lastSeenAt} ${DateFormat('hh:mm a').format(lastSeen)}';
    } else {
      return AppConstants.online;
    }
  } else {
    return Constants.emptyString;
  }
}

String getDisplayImage(RecentChatData recentChat) {
  var imageUrl = recentChat.profileImage ?? Constants.emptyString;
  if (recentChat.isBlockedMe.checkNull() ||
      recentChat.isAdminBlocked.checkNull()) {
    imageUrl = Constants.emptyString;
    //drawable = CustomDrawable(context).getDefaultDrawable(recentChat)
  } else if (!recentChat.isItSavedContact.checkNull() ||
      recentChat.isDeletedContact()) {
    imageUrl = recentChat.profileImage ?? Constants.emptyString;
    // drawable = CustomDrawable(context).getDefaultDrawable(recentChat)
  }
  return imageUrl;
}

void showQuickProfilePopup(
    {required context,
    required Function() chatTap,
    Function()? callTap,
    Function()? videoTap,
    required Function() infoTap,
    required Rx<ProfileDetails> profile,
    required Rx<AvailableFeatures> availableFeatures}) {
  var isAudioCallAvailable = profile.value.isGroupProfile.checkNull()
      ? false
      : availableFeatures.value.isOneToOneCallAvailable.checkNull();
  var isVideoCallAvailable = profile.value.isGroupProfile.checkNull()
      ? false
      : availableFeatures.value.isOneToOneCallAvailable.checkNull();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Obx(() {
        return Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 300,
            child: Column(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      mirrorFlyLog('image click', 'true');
                      // debugPrint(
                      //     "quick profile click--> ${profile.toJson().toString()}");
                      if (profile.value.image!.isNotEmpty &&
                          !(profile.value.isBlockedMe.checkNull() ||
                              profile.value.isAdminBlocked.checkNull()) &&
                          !( //!profile.value.isItSavedContact.checkNull() || //This is commented because Android side received as true and iOS side false
                              profile.value.isDeletedContact())) {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (con) => ImageViewView(
                                      imageName: getName(profile.value),
                                      imageUrl: profile.value.image,
                                    )));
                        /*Get.back();
                      Get.toNamed(Routes.imageView, arguments: {
                        'imageName': getName(profile.value),
                        'imageUrl': profile.value.image.checkNull()
                      });*/
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            child: ImageNetwork(
                              url: profile.value.image.toString(),
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 250,
                              clipOval: false,
                              errorWidget: profile.value.isGroupProfile!
                                  ? Image.asset(
                                      groupImg,
                                      package: package,
                                      height: 250,
                                      width: MediaQuery.of(context).size.width *
                                          0.72,
                                      fit: BoxFit.cover,
                                    )
                                  : ProfileTextImage(
                                      text: getName(profile.value),
                                      fontSize: 75,
                                      radius: 0,
                                    ),
                              isGroup: profile.value.isGroupProfile.checkNull(),
                              blocked: profile.value.isBlockedMe.checkNull() ||
                                  profile.value.isAdminBlocked.checkNull(),
                              unknown: (!profile.value.isItSavedContact
                                      .checkNull() ||
                                  profile.value.isDeletedContact()),
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          child: Text(
                            profile.value.isGroupProfile!
                                ? profile.value.name.checkNull()
                                : !Constants.enableContactSync
                                    ? profile.value.mobileNumber.checkNull()
                                    : profile.value.nickName.checkNull(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: chatTap,
                          child: SvgPicture.asset(
                            quickMessage,
                            package: package,
                            fit: BoxFit.contain,
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                      isAudioCallAvailable
                          ? Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  makeVoiceCall(profile.value.jid.checkNull(),
                                      availableFeatures, context);
                                },
                                child: SvgPicture.asset(
                                  quickCall,
                                  package: package,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      isVideoCallAvailable
                          ? Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  makeVideoCall(profile.value.jid.checkNull(),
                                      availableFeatures, context);
                                },
                                child: SvgPicture.asset(
                                  quickVideo,
                                  package: package,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      Expanded(
                        child: InkWell(
                          onTap: infoTap,
                          child: SvgPicture.asset(
                            quickInfo,
                            package: package,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}

makeVoiceCall(String toUser, Rx<AvailableFeatures> availableFeatures,
    BuildContext context) async {
  if (!availableFeatures.value.isOneToOneCallAvailable.checkNull()) {
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
  if (await AppPermission.askAudioCallPermissions(context)) {
    Mirrorfly.makeVoiceCall(
        toUserJid: toUser.checkNull(),
        flyCallBack: (FlyResponse response) {
          if (response.isSuccess) {
            /*Get.toNamed(Routes.outGoingCallView, arguments: {
          "userJid": [toUser],
          "callType": CallType.audio
        });*/
            MirrorflyUikit.instance.navigationManager.navigateTo(
                context: context,
                pageToNavigate: OutGoingCallView(userJid: [toUser]),
                routeName: Constants.outGoingCallView,
                onNavigateComplete: () {});
          }
        });
  } else {
    debugPrint("permission not given");
  }
}

makeVideoCall(String toUser, Rx<AvailableFeatures> availableFeatures,
    BuildContext context) async {
  if (await AppUtils.isNetConnected()) {
    if (await AppPermission.askVideoCallPermissions(context)) {
      if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
        debugPrint("#Mirrorfly Call You are on another call");
        toToast(Constants.msgOngoingCallAlert);
      } else {
        Mirrorfly.makeVideoCall(
            toUserJid: toUser.checkNull(),
            flyCallBack: (FlyResponse response) {
              if (response.isSuccess) {
                /*Get.toNamed(Routes.outGoingCallView, arguments: {
              "userJid": [toUser],
              "callType": CallType.video// removed
            });*/
                MirrorflyUikit.instance.navigationManager.navigateTo(
                    context: context,
                    pageToNavigate: OutGoingCallView(userJid: [toUser]),
                    routeName: Constants.outGoingCallView,
                    onNavigateComplete: () {});
              }
            });
      }
    } else {
      LogMessage.d("askVideoCallPermissions", "false");
    }
  } else {
    toToast(Constants.noInternetConnection);
  }
}

String getDocAsset(String filename) {
  if (filename.isEmpty || !filename.contains(".")) {
    return "";
  }
  // debugPrint(
  //     "helper document--> ${filename.toLowerCase().substring(filename.lastIndexOf(".") + 1)}");
  switch (filename.toLowerCase().substring(filename.lastIndexOf(".") + 1)) {
    case "csv":
      return csvImage;
    case "pdf":
      return pdfImage;
    case "doc":
      return docImage;
    case "docx":
      return docxImage;
    case "txt":
      return txtImage;
    case "xls":
      return xlsImage;
    case "xlsx":
      return xlsxImage;
    case "ppt":
      return pptImage;
    case "pptx":
      return pptxImage;
    case "zip":
      return zipImage;
    case "rar":
      return rarImage;
    case "apk":
      return apkImage;
    default:
      return "";
  }
}

String getCallLogDateFromTimestamp(int convertedTime, String format) {
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  if (isToday(convertedTime)) {
    return "Today";
  } else if (isYesterday(convertedTime)) {
    return "Yesterday";
  } else {
    return DateFormat(format).format(calendar);
  }
}

bool isToday(int convertedTime) {
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  final now = DateTime.now();
  return now.day == calendar.day &&
      now.month == calendar.month &&
      now.year == calendar.year;
}

bool isYesterday(int convertedTime) {
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return yesterday.day == calendar.day &&
      yesterday.month == calendar.month &&
      yesterday.year == calendar.year;
}

String getCallLogDuration(int startTime, int endTime) {
  var millis = endTime - startTime;
  var duration = Duration(microseconds: millis);

  if (startTime == 0 || endTime == 0 || millis == 0) {
    return "";
  } else {
    var seconds =
        ((duration.inSeconds % 60)).toStringAsFixed(0).padLeft(2, '0');
    return '${(duration.inMinutes).toStringAsFixed(0).padLeft(2, '0')}:$seconds';
  }
}

// ranges from 0.0 to 1.0

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
