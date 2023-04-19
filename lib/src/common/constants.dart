import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirrorfly_uikit_plugin/src/common/helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'apputils.dart';


//Colors
const Color appBarColor = Color(0xffF2F2F2);
const Color iconColor = Color(0xff181818);
const Color iconBgColor = Color(0xff9D9D9D);
const Color appbarTextColor = Color(0xff181818);
const Color statusBarColor = Color(0xffE5E5E5);
const Color textBlackColor = Color(0xff000000);
const Color textBlack1color = Color(0xff313131);
const Color textHintColor = Color(0xff181818);
const Color textColor = Color(0xff767676);
const Color textColorBlack = Color(0xff333333);
const Color textButtonColor = Color(0xffFFFFFF);
const Color buttonBgColor = Color(0xff3276E2);
const Color chatSentBgColor = Color(0xffe2eafc);
const Color chatReplyContainerColor = Color(0xffD0D8EB);
const Color chatReplySenderColor = Color(0xffEFEFEF);
const Color dividerColor = Color(0XffE2E2E2);
const Color audioColor = Color(0XffB9C1D6);
const Color audioColorDark = Color(0Xff848FAD);
const Color audioBgColor = Color(0Xff848FAD);
const Color bottomSheetColor = Color(0Xff242A3F);
const Color notificationTextColor = Color(0Xff565656);
const Color notificationTextBgColor = Color(0XffDADADA);
const Color chatBorderColor = Color(0XffDDE3E5);
const Color chatTimeColor = Color(0Xff959595);
const Color borderColor = Color(0xffAFB8D0);
const Color playIconColor = Color(0xff7285B5);
const Color durationTextColor = Color(0xff455E93);
const Color chatBgColor = Color(0xffD0D8EB);
const Color previewTextColor = Color(0xff7f7f7f);

//Assets
const String chatBg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/chat_bg.png';
const String registerIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/register_logo.svg';
const String statusIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/status.svg';
const String searchIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/magnifying_glass.svg';
const String chatFabIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/chat_fab.svg';
const String moreIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/shape.svg';
const String noContactsIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/no_contacts.png';
const String noChatIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/no_messages.png';
const String noCallImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_no_call_history.webp';
const String profileIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/avatar.svg';
const String rightArrowIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/forward_arrow.svg';
const String chatIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/chat.svg';
const String staredMsgIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/stared message.svg';
const String notificationIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/Notifications.svg';
const String tickRound = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/tick_round.svg';
const String tickRoundBlue = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/tick_round_blue.svg';
const String blockedIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/blocked_contacts.svg';
const String archiveIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/Archive_ic_settings.svg';
const String lockIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/lock.svg';
const String lockOutlineBlack = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/lock_outline_black.svg';
const String delete = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/delete_black.svg';
const String aboutIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/About and Help.svg';
const String connectionIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/antenna.svg';
const String toggleOffIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/toggle OFF.svg';
const String reportIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/stared message-1.svg';
const String logoutIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/logout.svg';
const String pencilEditIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/pencil.svg';
const String tickIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/tick.svg';
const String smileIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/smile.svg';
const String icQrScannerWebLogin = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_qr_scanner_web_login.png';
const String redirectLastMessage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_redirect_last_message.png';
const String sendIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/send.svg';
const String imgSendIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/img_send.svg';
const String attachIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/attach.svg';
const String icLogo = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_logo.png';
const String icChrome = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_chrome.png';
const String icEdgeBrowser = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_edge_browser.png';
const String icMozilla = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_mozilla.png';
const String icSafari = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_safari.png';
const String icIe = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_ie.png';
const String icOpera = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_opera.png';
const String icUc = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_uc.png';
const String icDefaultBrowser = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_default_browser.png';
const String eyeOn = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/eye_on.png';
const String eyeOff = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/eye_off.png';

//Dashboard Recent Chats
const String archive = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/archive.svg';
const String unarchive = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/unarchive.svg';
const String mute = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/mute.svg';
const String unMute = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/unmute.svg';
const String pushpin = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/pushpin.svg';
const String pin = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/pin.svg';
const String unpin = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/unpin.svg';

// const String audioImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/audio.svg';
const String audioImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/headset_img.svg';
const String headsetImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/headset_white.svg';
const String documentImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/document_icon.svg';
const String cameraImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/camera.svg';
const String contactImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/contact_icon.svg';
const String galleryImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/gallery.svg';
const String locationImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/location_icon.svg';
const String rightArrow = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/right_arrow.svg';
const String previewAddImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/preview_add.svg';

const String downloading = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/downloading.svg';
const String videoPlay = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/video_play.svg';
const String videoCamera = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/video_camera.svg';
const String audioPlay = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/audio_play.svg';
const String audioMicBg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/audio_mic.svg';
const String audioMic = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/mic.svg';
const String audioMic1 = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/mic1.svg';
const String musicIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/music_icon.svg';
const String profileImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/profile_img.png';

const String linkImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/link.svg';
const String txtImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/txt.svg';
const String csvImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/csv.svg';
const String pdfImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/pdf.svg';
const String pptImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ppt.svg';
const String pptxImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/pptx.svg';
const String xlsImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/xls.svg';
const String xlsxImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/xlsx.svg';
const String docImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/doc.svg';
const String docxImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/docx.svg';
const String apkImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/apk.svg';
const String mContactIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/contact_chat.svg';
const String mDocumentIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/document_chat.svg';
const String zipImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/zip.svg';
const String rarImage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/rar.svg';
const String mImageIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/image.svg';
const String mLocationIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/location_chat.svg';
const String mVideoIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_video.svg';
const String mAudioIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/noun_Audio_3408360.svg';
const String mAudioRecordIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/record_reply_preview.svg';
const String audioWhite = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/audio_white.svg';
const String videoWhite = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/video_icon.svg';
const String cornerShadow = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_baloon.png';
const String disabledIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/disabled.png';

const String phoneCall = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/phonecall.svg';
const String videoCall = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/videocall.svg';
const String call = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/call.svg';

const String quickCall = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/quick_call.svg';
const String quickInfo = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/quick_info.svg';
const String quickMessage = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/quick_message.svg';
const String quickVideo = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/quick_video.svg';

const String replyIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/reply.svg';
const String forwardIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/forward.svg';
const String deleteIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/delete_black.svg';
const String cancelIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/close.svg';
const String favouriteIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/star.svg';
const String unFavouriteIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/unstar.svg';
const String copyIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/copy.svg';
const String infoIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/info.svg';
const String uploadIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/upload.svg';
const String downloadIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/download.svg';
const String playIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/play.svg';
const String pauseIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/pause.svg';
const String shareIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/share.svg';
const String starSmallIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/star_small_icon.svg';

const String seenIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/seen.svg';
const String unSendIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/unsent.svg';
const String deliveredIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/delivered.svg';
const String acknowledgedIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/acknowledged.svg';

//Animation
const String deleteDustbin = 'packages/mirrorfly_uikit_plugin/lib/assets/animation/delete_dustbin.json';
const String audioJson = 'packages/mirrorfly_uikit_plugin/lib/assets/animation/enable_mic.json';
const String audioJson1 = 'packages/mirrorfly_uikit_plugin/lib/assets/animation/enable_mic1.json';

const String profileImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/profile_img.png';
const String groupImg = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_grp_bg.png';
const String imageEdit = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_image_edit.svg';
const String edit = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_edit.svg';
const String imageOutline = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/image_outline.svg';
const String addUser = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/add_user.svg';
const String reportUser = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/report_user.svg';
const String reportGroup = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/report_group.svg';
const String leaveGroup = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/leave_group.svg';

const String contactSelectTick = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/contact_select.svg';
const String rightArrowProceed = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/right_arrow_proceed.svg';
const String closeContactIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/close_icon_contact.svg';

const String emailIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/email.svg';
const String phoneIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/phone.svg';
const String deleteBin = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/delete_bin.svg';
const String deleteBinWhite = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/delete_bin_white.svg';
const String warningIcon = 'packages/mirrorfly_uikit_plugin/lib/assets/logos/warning.svg';

const String filePermission = "packages/mirrorfly_uikit_plugin/lib/assets/logos/file_permission.svg";
const String audioPermission = "packages/mirrorfly_uikit_plugin/lib/assets/logos/audio_permission.svg";
const String cameraPermission = "packages/mirrorfly_uikit_plugin/lib/assets/logos/camera_permission.svg";
const String contactPermission = "packages/mirrorfly_uikit_plugin/lib/assets/logos/contact_permission.svg";
const String contactSyncPermission = "packages/mirrorfly_uikit_plugin/lib/assets/logos/contact_media_permission.svg";
const String settingsPermission = "packages/mirrorfly_uikit_plugin/lib/assets/logos/settings_permission.svg";
const String locationPinPermission = "packages/mirrorfly_uikit_plugin/lib/assets/logos/location_pin_permission.svg";
const String recordAudioVideoPermission =
    "packages/mirrorfly_uikit_plugin/lib/assets/logos/record_audio_video_permission.svg";

const String icAdminBlocked = "packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_admin_blocked.svg";
const String icExpand = "packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_expand.svg";
const String icCollapse = "packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_collapse.svg";

const String forwardMedia = "packages/mirrorfly_uikit_plugin/lib/assets/logos/forward_media.svg";
const String arrowDown = "packages/mirrorfly_uikit_plugin/lib/assets/logos/arrow_down.svg";
const String arrowUp = "packages/mirrorfly_uikit_plugin/lib/assets/logos/arrow_up.svg";

const String mediaBg = "packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_baloon.svg";

//contact sync
const String syncIcon = "packages/mirrorfly_uikit_plugin/lib/assets/logos/sync.svg";
const String contactSyncBg = "packages/mirrorfly_uikit_plugin/lib/assets/logos/contact_sync_bg.png";
const String contactBookFill = "packages/mirrorfly_uikit_plugin/lib/assets/logos/contacts_book_fill.svg";
const String emailContactIcon = "packages/mirrorfly_uikit_plugin/lib/assets/logos/emailcontact_icon.svg";

// const String icBioBackground = "packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_bio_background.svg";
const String icBioBackground = "packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_bio_background.png";
const String icDeleteIcon = "packages/mirrorfly_uikit_plugin/lib/assets/logos/ic_delete_icon.svg";


//About us
const String titleContactMsg =
    "Mirror Fly is a ready-to-go messaging solution for building enterprise-grade real-time chat IM applications that meet various degrees of requirements like team discussion, data sharing, task delegation and information handling on the go.";
const String titleContactUs = "Contact Us";
const String titleContactMsgTime =
    "To have a detailed interaction with our experts";
const String titleFaq = "FAQ";
const String titleFaqMsg =
    "Kindly checkout FAQ section for doubts regarding Mirror fly. We might have already answered your question.";
const String mirrorFly = "Mirror Fly";
const String websiteMirrorFly = "https://www.mirrorfly.com/";
const String notificationNotWorkingURL =
    "https://app.mirrorfly.com/notifications/";

toToast(String text) {
  if(Platform.isIOS) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      textColor: Colors.black,
      backgroundColor: Colors.white,
      fontSize: 16.0);
  // Get.showSnackbar(
  //   GetSnackBar(
  //     message: text,
  //     isDismissible: false,
  //     // icon: const Icon(Icons.refresh),
  //     duration: const Duration(seconds: 5),
  //     animationDuration: const Duration(seconds: 1),
  //   ),
  // );
}

mirrorFlyLog(String tag, String msg) {
  if (kDebugMode) {
    // print("MirrorFly : $tag ==> $msg");
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
        .allMatches(msg)
        .forEach((match) => debugPrint("MirrorFly : $tag==>${match.group(0)}"));
  }
}

class Constants {
  static const String package = 'com.mirrorfly.uikit_flutter';
  static const String webChatLogin = 'https://webchat-uikit-qa.contus.us/';
  static const String tag = 'Contus Fly';
  static const String googleMapKey = "AIzaSyBaKkrQnLT4nacpKblIE5d4QK6GpaX5luQ";
  static const String googleMapPackageName = "com.google.android.apps.maps";
  static const String packageName = "com.contus.flycommons.";

  static const String applicationLink = "https://app.contusfly.contus.com";
  static const String smsContent =
      "Hey, MirrorFly is a real time chat, Audio and Video call solution for B2B and B2C.\n Download the app from this URL: https://app.mirrorfly.com";

  static const String rosterJid = "roster_jid";
  static const String isLiveUser = "is_live_user";
  static const String ifBlockedMe = "ifBlockedMe";
  static const String blockedMe = "BlockedMe";
  static const String isMute = "is_mute";
  static const String mobileNo = "mobileNumber";
  static const String email = "email";
  static const String title = "title";
  static const String titleMessage = "Messages";
  static const String profile = "profile";
  static const String selectedImage = "selected_image";
  static const int countOne = 1;
  static const int countZero = 0;
  static const String totalPages = "total_pages";
  static const String isNewUser = "is_new_user";
  static const String mediaUrl = "url";
  static const String response = "response";
  static const String message = "message";
  static const String error = "error";
  static const String userStatus = "user_status";
  static const String userBusyStatus = "user_busy_status";
  static const String android = "android";
  static const String image = "image";
  static const String emptyString = "";
  static const String encryptString = " Encrypted";
  static const String composing = "composing";
  static const String gone = "Gone";
  static const String lastSeen = "lastseen";
  static const String online = "Online";
  static const String presenceAvailable = "presence_available";
  static const String presenceChanged = "presence_changed";
  static const String fromSplash = "from_splash";
  static const String inviteList = "invite_list";
  static const String data = "data";
  static const String userList = "user_list";
  static const String isBroadCast = "is_broadcast";
  static const String isUploadSuccess = "is_upload_success";
  static const String quickShare = "QUICK_SHARE";
  static const String seenUpdated = "Seenupdated";
  static const String isArchivedSettingsEnabled =
      "com.contus.flycommons.is_archived_settings_enabled";
  static const int maxReportMessagesCount = 5;
  static const String chatType = "chatType";
  static const String fromUser = "from";
  static const String toUser = "to";
  static const String dataArray = "data";
  static const String messageTxt = "message";
  static const String msgID = "msgId";
  static const String fileName = "filename";
  static const String messageType = "msgType";
  static const String timeStamp = "timestamp";
  static const String publisherID = "publisherId";
  static const String name = "name";
  static const String page = "page";
  static const String size = "size";
  static const String isBusyStatusEnabled =
      "com.contus.flycommons.is_busy_status_enabled";
  static const String xmppDomain = "xmppDomain";
  static const String xmppPort = "xmppPort";
  static const String xmppHost = "xmppHost";
  static const String signalServerDomain = "signalServerDomain";
  static const String callRoutingServer = "callRoutingServer";
  static const String stuns = "stuns";
  static const String turns = "turns";
  static const String messageIV = "iv";
  static const String profileIV = "ivProfile";
  static const String responseParameterStatus = "status";
  static const String responseParameterData = "data";
  static const String statusCodeSuccess = "200";
  static const String statusCodeSecurityTokenError = "401";
  static const String statusInternalServerError = "500";
  static const String deviceType = "deviceType";
  static const String deviceOS = "deviceOs";
  static const String deviceOSVersion = "deviceOsVersion";
  static const String mode = "mode";
  static const String userIdentifier = "userIdentifier";
  static const String voipDeviceToken = "voipDeviceToken";
  static const String deviceModel = "deviceModel";
  static const String appVersion = "appVersion";
  static const String description = "description";
  static const String fileToken = "fileToken";
  static const String statusCodeNotFound = "204";
  static const String backType = "chatBackupType";
  static const String backupFrequency = "chatBackupFrequency";
  static const String sameUser = "same_user";
  static const String notificationNotWorkingURL = "notificationHelpUrl";
  static const String latitude = "latitude";
  static const String longitude = "longitude";
  static const String chatMessage = "chatmessage";
  static const String messageID = "messageId";
  static const String networkFailure = "network_failure";
  static const String messageIDS = "messageIds";
  static const String otp = "otp";
  static const String googleToken = "google_token";
  static const String messageFrom = "messageFrom";
  static const String messageTo = "messageTo";
  static const String type = "type";
  static const String messageTime = "message_time";
  static const String messageTitle = "title";
  static const String chaTType = "chat_type";
  static const String groupVCard = "group_vcard";
  static const String publisherProfile = "publisher_profile";
  static const String addFromInfo = "add_info_info";
  static const String deleteType = "delete_type";
  static const String messageFavourite = "message_favourite";
  static const String messageContent = "message_content";
  static const String isFirstLogin = "is_first";
  static const String domain = "domain";
  static const String videoLimit = "videoLimit";
  static const String audioLimit = "audioLimit";
  static const String profileName = "profile_name";
  static const String createGroup = "create_group";
  static const String createBroadCast = "create_broadcast";
  static const String profileImage = "profile_image";
  static const String username = "username";
  static const String secretKey = "password";
  static const String currentTimeStamp = "currentTimestamp";
  static const String loginData = "loginData";
  static const String stringData = "string";
  static const String config = "config";
  static const String deviceToken = "deviceToken";
  static const String userBusy = "user_busy";
  static const String selectedImages = "selected_images";
  static const String selectedVideo = "selected_video";
  static const String selectedVideoCaption = "selected_video_caption";
  static const int activityReqCode = 111;
  static const int editReqCode = 112;
  static const int pickContactReqCode = 123;
  static const int selectContactReqCode = 124;
  static const int selectImageReqCode = 125;
  static const int selectMapReqCode = 118;
  static const int countryReqCode = 118;

  static const String msgTypeText = "text";
  static const String msgTypeContact = "contact";
  static const String msgTypeNotification = "notification";

  static const String emailPattern =
      ("^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,3})\$");
  static const String mobilePattern = r'([0-9]{5,9})';

  static const String textPattern = r'[a-zA-Z]';
  static const String countryCodePattern = r'(^(\+?[0-9]{1,4}\-?)$)';
  // static const String websitePattern =
  //     r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+';
  // final RegExp websitePattern = RegExp(r"^(?:http|https):\/\/[\w\-_]+(?:\.[\w\-_]+)+[\w\-.,@?^=%&:/~\\+#]*$");
  static const String websitePattern = r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})';
  // static const String websitePattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
  // static const String websitePattern = r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?";
  // static const String websitePattern = ("^((http?|https?)://)?[-a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)\$");

  static const String O = "o";
  static const String N = "n";

  static const String typeSearchRecent = "Chats";
  static const String typeSearchContact = "Contact";
  static const String typeSearchMessage = "Message";

  static const String you = "You";
  static const String deletedUser = "Deleted User";

  static const int minGroupMembers = 2;

  static const String yesterday = "yesterday";
  static const String today = "today";
  static const String yesterdayUpper = "YESTERDAY";
  static const bool isMobileLogin = true;
  static const String baseUrl = "com.contus.flycommons.base_url";
  static const String apiKey = "com.contus.flycommons.api_key";
  static const String mix = "@mix.";

  static const String bulletPoint = "\u2022 ";

  static const String groupEvent = "group_events";
  static const String archiveEvent = "archive_events";
  static const String messageReceived = "message_received";
  static const String messageUpdated = "message_updated";
  static const String mediaStatusUpdated = "media_status_updated";
  static const String mediaUploadDownloadProgress =
      "media_upload_download_progress";
  static const String muteEvent = "mute_event";
  static const String pinEvent = "pin_event";

  static const String typeChat = "chat";
  static const String typeGroupChat = "groupchat";
  static const String typeBroadcastChat = "broadcast";

  static const String termsConditions =
      "https://www.mirrorfly.com/terms-and-conditions.php";
  static const String privacyPolicy =
      "https://www.mirrorfly.com/privacy-policy.php";

  static const List<String> defaultStatusList = [
    "Available",
    "Sleeping...",
    "Urgent calls only",
    "At the movies",
    "I am in Mirror Fly"
  ];
  static const List<int> defaultColorList = [
    0Xff9068BE,
    0XffE62739,
    0Xff845007,
    0Xff3A4660,
    0Xff1D1E22,
    0XffBE7D6A,
    0Xff005995,
    0Xff600473,
    0XffCD5554,
    0Xff00303F,
    0XffBE4F0C,
    0Xff4ABDAC,
    0XffFC4A1A,
    0Xff368CBF,
    0Xff7EBC59,
    0Xff201D3A,
    0Xff269CCC,
    0Xff737272,
    0Xff237107,
    0Xff52028E,
    0XffAF0D74,
    0Xff6CB883,
    0Xff0DAFA4,
    0XffA71515,
    0Xff157FA7,
    0Xff7E52B1,
    0Xff27956A,
    0Xff9A4B70,
    0XffFBBE30,
    0XffED3533,
    0Xff571C8D,
    0Xff54181C,
    0Xff9B6700,
    0Xff6E8E14,
    0Xff0752A1,
    0XffBF6421,
    0Xff00A59C,
    0Xff9F0190,
    0XffAE3A3A,
    0Xff858102,
    0Xff027E02,
    0XffF66E54
  ];
  static const String defaultStatus = "I am in Mirror Fly";

  static const int mediaDownloading = 3;
  static const int mediaDownloaded = 4;
  static const int mediaNotDownloaded = 5;
  static const int mediaDownloadedNotAvailable = 6;
  static const int mediaNotUploaded = 0;
  static const int mediaUploading = 1;
  static const int mediaUploaded = 2;
  static const int mediaUploadedNotAvailable = 7;

  static const int mediaDownloadFailed = 401;
  static const int mediaUploadFailed = 401;

  static const double borderRadius = 27;
  static const double defaultPadding = 8;

  // static GlobalKey<AnimatedListState> audioListKey =
  // GlobalKey<AnimatedListState>();

  static const String pdf = "pdf";
  static const String ppt = "ppt";
  static const String doc = "doc";
  static const String docx = "docx";
  static const String apk = "apk";
  static const String xls = "xls";
  static const String xlsx = "xlsx";

  //Message Types
  static const String mText = "TEXT";
  static const String mImage = "IMAGE";
  static const String mAudio = "AUDIO";
  static const String mVideo = "VIDEO";
  static const String mContact = "CONTACT";
  static const String mLocation = "LOCATION";
  static const String mDocument = "DOCUMENT";
  static const String mFile = "FILE";
  static const String mNotification = "NOTIFICATION";

  //Audio Recording Types
  static const String audioRecording = "AUDIO_RECORDING";
  static const String audioRecordDone = "AUDIO_RECORDING_COMPLETED";
  static const String audioRecordDelete = "AUDIO_RECORDING_DELETE";
  static const String audioRecordInitial = "AUDIO_RECORDING_NOT_INITIALIZED";

  //Permission dialog contents
  static const String settingPermission =
      "You will not receive notifications while the app is in background if you disable these permissions";
  static const String filePermission =
      "To send media, allow MirrorFly access to your device's photos,media, and files.";
  static const String cameraPermission =
      "To capture photos and video, allow MirrorFly access to the camera and storage.";
  static const String locationPermission =
      "MirrorFly needs access to your location in order to share your current location.";
  static const String contactPermission =
      "To help you connect with friends and family, allow Mirrorfly access to your contacts.";
  static const String contactSyncPermission =
      "MirrorFly will continuously upload your contacts to its encrypted servers to let you discover and connect with your friends. Your contacts are uploaded using MirrorFly private contact discovery which means they are end-to-end encrypted and secured.";

  static const String audioPermission =
      "To send audio messages, allow MirrorFly access to your Microphone.";

  static const String contactPermissionDenied =
      "MirrorFly need the Contacts Permission in order to help you connect with friends and family, but they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"Contacts\"";
  static const String locationPermissionDenied =
      "MirrorFly need the Location Permission in order to attach a location, but they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"Location\".";
  static const String cameraPermissionDenied =
      "MirrorFly need the Camera and Storage Permission in order to capture photos and video, but they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"Camera\" and \"Storage\".";
  static const String storagePermissionDenied =
      "MirrorFly need the Storage Permission in order to attach photos, media, and files, but they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"Storage\".";
  static const String microPhonePermissionDenied =
      "MirrorFly need the Microphone Permission in order to send audio messages, but they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"Microphone\".";
  static const String audioCallPermissionDenied =
      "MirrorFly need the Microphone Permission in order to call Family, but they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"Microphone\".";
  static const String videoCallPermissionDenied =
      "MirrorFly need the Microphone and Camera Permissions in order to call Family, but they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"Microphone\" and \"Camera\".";

  static const String noInternetConnection =
      "Please check your internet connection";
  static const String adminBlockedMessage =
      "This application is no longer available for you.";
  static const String adminBlockedMessageLabel =
      "Please contact admin if you have any query.";
  static const String supportMail = "contussupport@gmail.com";
  static const String httpStatusCode = "http_status_code";

  static const String googleTranslationLabel = "Translate Message";
  static const String googleTranslationMessage =
      "Enable Translate Message to choose Translation Language";
  static const String googleTranslationLanguageLable =
      "Choose Translation Language";
  static const String googleTranslationLanguageDoubleTap =
      "Double Tap the received messages to translate";
  static const String googleTranslateKey =
      "AIzaSyCdwzAZR6tx8KB-2dMn0KzSI1V0LpsYdH0";

  static const String editBusyStatus = "Edit Busy Status Message";
  static const String yourBusyStatus = "Your Busy Status";
  static const String newBusyStatus = "Select your new Status";
  static const String busyStatusDescription =
      "Your busy status will be set as auto-response to the messages received from individuals.";

  static const String autoDownload = "Auto Download";
  static const String autoDownloadLable =
      "Enable “Auto download” to turn all types of files received readily viewable";
  static const String dataUsageSettings = "Data Usage Settings";
  static const String dataUsageSettingsLable =
      "Setup your mobile and wifi data usage based on media type";
  static const String mediaAutoDownload = "Media Auto download";
  static const String whenUsingMobileData = "When using Mobile Data";
  static const String whenUsingWifiData = "When connected on Wi-Fi";
  static const List<String> mediaTypes = [
    "Photos",
    "Videos",
    "Audio",
    "Documents"
  ];
  static const photo = "Photos";
  static const audio = "Audio";
  static const video = "Videos";
  static const document = "Documents";

  static const appSession = 'app_session';
  static const changedPinAt = 'pin_changed_at';
  static const alertDate = 'alertDate';
  static const expiryDate = 'expiryDate';
  static const sessionLockTime = 32;//in Seconds
  static const pinExpiry = 31;//in Days
  static const pinAlert = pinExpiry-5;//in Days
  static const forgetPinOTPText ='Generate OTP to your registered mobile number';
  static const invalidPinOTPText ='Invalid PIN, Generate OTP to your registered mobile number';
}

Future<void> launchWeb(String url) async {
  if (await AppUtils.isNetConnected()) {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw "Could not launch $url";
    }
  } else {
    toToast(Constants.noInternetConnection);
  }
}

Future<void> launchInWebViewOrVC(String url, String title) async {
  if (await AppUtils.isNetConnected()) {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: WebViewConfiguration(
          headers: <String, String>{'my_header_key': title}),
    )) {
      throw Exception('Could not launch $url');
    }
  } else {
    toToast(Constants.noInternetConnection);
  }
}

Widget forMessageTypeIcon(String messageType,[MediaChatMessage? mediaChatMessage]) {
  // debugPrint("messagetype $messageType");
  switch (messageType.toUpperCase()) {
    case Constants.mImage:
      return SvgPicture.asset(
        mImageIcon,
        fit: BoxFit.contain,
      );
    case Constants.mAudio:
      return SvgPicture.asset(
        mediaChatMessage != null ? mediaChatMessage.isAudioRecorded ? mAudioRecordIcon : mAudioIcon : mAudioIcon,
        fit: BoxFit.contain,
        color: textColor,
      );
    case Constants.mVideo:
      return SvgPicture.asset(
        mVideoIcon,
        fit: BoxFit.contain,
      );
    case Constants.mDocument:
      return SvgPicture.asset(
        mDocumentIcon,
        fit: BoxFit.contain,
      );
    case Constants.mFile:
      return SvgPicture.asset(
        mDocumentIcon,
        fit: BoxFit.contain,
      );
    case Constants.mContact:
      return SvgPicture.asset(
        mContactIcon,
        fit: BoxFit.contain,
      );
    case Constants.mLocation:
      return SvgPicture.asset(
        mLocationIcon,
        fit: BoxFit.contain,
      );
    default:
      return const SizedBox();
  }
}

String? forMessageTypeString(String messageType, {String? content}) {
  // mirrorFlyLog("Recent Chat content", content.toString());
  switch (messageType.toUpperCase()) {
    case Constants.mImage:
      return content.checkNull().isNotEmpty ? content : "Image";
    case Constants.mAudio:
      return "Audio";
    case Constants.mVideo:
      return content.checkNull().isNotEmpty ? content : "Video";
    case Constants.mDocument:
      return "Document";
    case Constants.mFile:
      return "Document";
    case Constants.mContact:
      return "Contact";
    case Constants.mLocation:
      return "Location";
    default:
      return null;
  }
}

Future<File> writeImageTemp(dynamic bytes, String imageName) async {
  final dir = await getTemporaryDirectory();
  await dir.create(recursive: true);
  final tempFile = File("${dir.path}/$imageName");
  await tempFile.writeAsBytes(bytes);
  return tempFile;
}
