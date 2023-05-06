import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/routes/app_pages.dart';

import 'app/common/constants.dart';
import 'app/data/session_management.dart';
import 'app/model/user_list_model.dart';
import 'app/modules/chat/bindings/chat_binding.dart';
import 'app/modules/chat/controllers/chat_controller.dart';
import 'app/modules/chat/views/chat_view.dart';
import 'mirrorfly_uikit_plugin.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}
class ChatPage {

  static GetPage chatPage(){
    return GetPage(
      name: Routes.chat,
      page: () => ChatView(jid:""),
      // arguments: Profile(),
      binding: ChatBinding(),
    );
  }

  static openChatPage({required Profile profile}){
    Get.toNamed(Routes.chat,arguments: profile);
    Get.to(const ChatDashboard());
  }
}
openChatPage({required Profile profile}){
  Get.toNamed(Routes.chat,arguments: profile);
  Get.to(const ChatDashboard());
}

class ChatDashboard extends StatelessWidget {
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
            if (!SessionManagement.isContactSyncDone() /*|| nonChatUsers.isEmpty*/) {
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
}


class ChatPageView extends StatefulWidget {
  const ChatPageView({Key? key,required this.jid, required this.profile, required this.onBack }) : super(key: key);
  final String jid;
  final Profile profile;
  final Function() onBack;

  @override
  State<ChatPageView> createState() => _ChatPageViewState();
}

class _ChatPageViewState extends State<ChatPageView> {
  @override
  void initState() {
    super.initState();
    Get.put(ChatController());
  }
  @override
  Widget build(BuildContext context) {
    // return GetMaterialApp(home: ChatView(profile: widget.profile,onBack: widget.onBack,));
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
        onInit: (){
        },
        getPages: AppPages.routes,
        // home: ChatView(profile: widget.profile,onBack: widget.onBack,)
    );
  }
}
