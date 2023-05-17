// To parse this JSON data, do
//
//     final appConfig = appConfigFromJson(jsonString);

import 'dart:ui';

import 'dart:convert';

AppConfig appConfigFromJson(String str) => AppConfig.fromJson(json.decode(str));

String appConfigToJson(AppConfig data) => json.encode(data.toJson());

class AppConfig {
  ProjectInfo projectInfo;
  AppTheme appTheme;

  AppConfig({
    required this.projectInfo,
    required this.appTheme,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    projectInfo: ProjectInfo.fromJson(json["projectInfo"]),
    appTheme: AppTheme.fromJson(json["AppTheme"]),
  );

  Map<String, dynamic> toJson() => {
    "projectInfo": projectInfo.toJson(),
    "AppTheme": appTheme.toJson(),
  };
}

class AppTheme {
  String theme;
  MirrorFlyAppTheme? customTheme;

  AppTheme({
    required this.theme,
    this.customTheme,
  });

  factory AppTheme.fromJson(Map<String, dynamic> json) => AppTheme(
    theme: json["theme"],
    customTheme: json["customTheme"] == null ? null : MirrorFlyAppTheme.fromJson(json["customTheme"]),
  );

  Map<String, dynamic> toJson() => {
    "theme": theme,
    "customTheme": customTheme?.toJson(),
  };
}

class MirrorFlyAppTheme {
  Color primaryColor;
  Color secondaryColor;
  Color appBarColor;
  Color colorOnAppbar;
  Color scaffoldColor;
  Color colorOnPrimary;
  Color textPrimaryColor;
  Color textSecondaryColor;
  ChatBubbleColor chatBubblePrimaryColor;
  ChatBubbleColor chatBubbleSecondaryColor;

  MirrorFlyAppTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.appBarColor,
    required this.colorOnAppbar,
    required this.scaffoldColor,
    required this.colorOnPrimary,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.chatBubblePrimaryColor,
    required this.chatBubbleSecondaryColor,
  });

  factory MirrorFlyAppTheme.fromJson(Map<String, dynamic> json) => MirrorFlyAppTheme(
    primaryColor: json["primaryColor"].toString().toColor(),
    secondaryColor: json["secondaryColor"].toString().toColor(),
    appBarColor: json["appBarColor"].toString().toColor(),
    colorOnAppbar: json["colorOnAppbar"].toString().toColor(),
    scaffoldColor: json["scaffoldColor"].toString().toColor(),
    colorOnPrimary: json["colorOnPrimary"].toString().toColor(),
    textPrimaryColor: json["textPrimaryColor"].toString().toColor(),
    textSecondaryColor: json["textSecondaryColor"].toString().toColor(),
    chatBubblePrimaryColor: ChatBubbleColor.fromJson(json["chatBubblePrimaryColor"]),
    chatBubbleSecondaryColor: ChatBubbleColor.fromJson(json["chatBubbleSecondaryColor"]),
  );

  Map<String, dynamic> toJson() => {
    "primaryColor": primaryColor,
    "secondaryColor": secondaryColor,
    "appBarColor": appBarColor,
    "colorOnAppbar": colorOnAppbar,
    "scaffoldColor": scaffoldColor,
    "colorOnPrimary": colorOnPrimary,
    "textPrimaryColor": textPrimaryColor,
    "textSecondaryColor": textSecondaryColor,
    "chatBubblePrimaryColor": chatBubblePrimaryColor.toJson(),
    "chatBubbleSecondaryColor": chatBubbleSecondaryColor.toJson(),
  };
}

class ChatBubbleColor {
  Color color;
  Color textPrimaryColor;
  Color textSecondaryColor;

  ChatBubbleColor({
    required this.color,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
  });

  factory ChatBubbleColor.fromJson(Map<String, dynamic> json) => ChatBubbleColor(
    color: json["color"].toString().toColor(),
    textPrimaryColor: json["textPrimaryColor"].toString().toColor(),
    textSecondaryColor: json["textSecondaryColor"].toString().toColor(),
  );

  Map<String, dynamic> toJson() => {
    "color": color,
    "textPrimaryColor": textPrimaryColor,
    "textSecondaryColor": textSecondaryColor,
  };
}

extension AppColor on String{
  Color toColor(){
    return Color(int.parse(this));
  }
}

class ProjectInfo {
  String projectId;
  String serverAddress;
  String licenseKey;
  String googleMapKey;
  String iOSContainerId;
  String storageFolderName;
  bool isTrialLicenceKey;
  bool enableMobileNumberLogin;

  ProjectInfo({
    required this.projectId,
    required this.serverAddress,
    required this.licenseKey,
    required this.googleMapKey,
    required this.iOSContainerId,
    this.storageFolderName="",
    this.isTrialLicenceKey=true,
    this.enableMobileNumberLogin=true,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) => ProjectInfo(
    projectId: json["projectId"],
    serverAddress: json["serverAddress"],
    licenseKey: json["licenseKey"],
    googleMapKey: json["googleMapKey"],
    iOSContainerId: json["iOSContainerId"],
    storageFolderName: json["storageFolderName"] ?? "",
    isTrialLicenceKey: json["isTrialLicenceKey"] ?? true,
    enableMobileNumberLogin: json["enableMobileNumberLogin"] ?? true,
  );

  Map<String, dynamic> toJson() => {
    "projectId": projectId,
    "serverAddress": serverAddress,
    "licenseKey": licenseKey,
    "googleMapKey": googleMapKey,
    "iOSContainerId": iOSContainerId,
    "storageFolderName": storageFolderName,
    "isTrialLicenceKey": isTrialLicenceKey,
    "enableMobileNumberLogin": enableMobileNumberLogin,
  };
}
