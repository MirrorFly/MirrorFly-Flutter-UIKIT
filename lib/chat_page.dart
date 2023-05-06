
/*class ChatDashboard extends StatelessWidget {
  const ChatDashboard({Key? key,this.title}) : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // theme: MirrorFlyAppTheme.lightTheme,
      // darkTheme: MirrorFlyAppTheme.darkTheme,
      // themeMode: ThemeMode.light,
      onInit: (){
        mirrorFlyLog('Mirrorfly', 'GetMaterialApp onInit');
        mirrorFlyLog('Mirrorfly', '${SessionManagement.getLogin()}');
      },
      debugShowCheckedModeBanner: false,
      //initialBinding: getBinding(),
      initialRoute: getInitialRoute(),//SessionManagement.getEnablePin() ? Routes.pin : getInitialRoute(),
      //initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
String getInitialRoute() {
  if(!SessionManagement.adminBlocked()) {
    if (SessionManagement.getLogin()) {
      if (SessionManagement
          .getName()
          .checkNull()
          .isNotEmpty && SessionManagement
          .getMobileNumber()
          .checkNull()
          .isNotEmpty) {
        if (SessionManagement
            .getChatJid()
            .checkNull()
            .isEmpty) {
          if(!MirrorflyUikit.isTrialLicence) {
            // mirrorFlyLog("nonChatUsers", nonChatUsers.toString());
            if (!SessionManagement.isContactSyncDone() *//*|| nonChatUsers.isEmpty*//*) {
              return AppPages.contactSync;
            }else{
              return AppPages.dashboard;
            }
          }else{
            return AppPages.dashboard;
          }
        } else {
          return "${AppPages.chat}?jid=${SessionManagement.getChatJid()
              .checkNull()}&from_notification=true";
        }
      } else {
        return AppPages.profile;
      }
    } else {
      return AppPages.initial;
    }
  }else{
    return AppPages.adminBlocked;
  }
}*/
