// To parse this JSON data, do
//
//     final appConfig = appConfigFromJson(jsonString);

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
  CustomTheme customTheme;

  AppTheme({
    required this.theme,
    required this.customTheme,
  });

  factory AppTheme.fromJson(Map<String, dynamic> json) => AppTheme(
    theme: json["theme"],
    customTheme: CustomTheme.fromJson(json["customTheme"]),
  );

  Map<String, dynamic> toJson() => {
    "theme": theme,
    "customTheme": customTheme.toJson(),
  };
}

class CustomTheme {
  int primaryColor;
  int secondaryColor;
  int appBarColor;
  int colorOnAppbar;
  int scaffoldColor;
  int colorOnPrimary;
  int textPrimaryColor;
  int textSecondaryColor;
  int chatBubblePrimaryColor;
  int chatBubbleSecondaryColor;

  CustomTheme({
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

  factory CustomTheme.fromJson(Map<String, dynamic> json) => CustomTheme(
    primaryColor: int.parse(json["primaryColor"]),
    secondaryColor: int.parse(json["secondaryColor"]),
    appBarColor: int.parse(json["appBarColor"]),
    colorOnAppbar: int.parse(json["colorOnAppbar"]),
    scaffoldColor: int.parse(json["scaffoldColor"]),
    colorOnPrimary: int.parse(json["colorOnPrimary"]),
    textPrimaryColor: int.parse(json["textPrimaryColor"]),
    textSecondaryColor: int.parse(json["textSecondaryColor"]),
    chatBubblePrimaryColor: int.parse(json["chatBubblePrimaryColor"]),
    chatBubbleSecondaryColor: int.parse(json["chatBubbleSecondaryColor"]),
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
    "chatBubblePrimaryColor": chatBubblePrimaryColor,
    "chatBubbleSecondaryColor": chatBubbleSecondaryColor,
  };
}

class ProjectInfo {
  String projectId;
  String serverAddress;
  String licenseKey;
  String iOSContainerId;
  String storageFolderName;
  bool isTrialLicenceKey;
  bool enableMobileNumberLogin;

  ProjectInfo({
    required this.projectId,
    required this.serverAddress,
    required this.licenseKey,
    required this.iOSContainerId,
    required this.storageFolderName,
    required this.isTrialLicenceKey,
    required this.enableMobileNumberLogin,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) => ProjectInfo(
    projectId: json["projectId"],
    serverAddress: json["serverAddress"],
    licenseKey: json["licenseKey"],
    iOSContainerId: json["iOSContainerId"],
    storageFolderName: json["storageFolderName"],
    isTrialLicenceKey: json["isTrialLicenceKey"],
    enableMobileNumberLogin: json["enableMobileNumberLogin"],
  );

  Map<String, dynamic> toJson() => {
    "projectId": projectId,
    "serverAddress": serverAddress,
    "licenseKey": licenseKey,
    "iOSContainerId": iOSContainerId,
    "storageFolderName": storageFolderName,
    "isTrialLicenceKey": isTrialLicenceKey,
    "enableMobileNumberLogin": enableMobileNumberLogin,
  };
}
