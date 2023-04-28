import 'package:flutter/material.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_theme.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/dashboard/views/dashboard_view.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MirrorflyUikit.initUIKIT(
      baseUrl: 'https://api-uikit-qa.contus.us/api/v1/',
      licenseKey: 'ckIjaccWBoMNvxdbql8LJ2dmKqT5bp',
      //ckIjaccWBoMNvxdbql8LJ2dmKqT5bp//2sdgNtr3sFBSM3bYRa7RKDPEiB38Xo
      iOSContainerID: 'group.com.mirrorfly.qa',theme:MirrorflyTheme.lightTheme);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.dark,
      /*routes: <String, WidgetBuilder>{
        '/chat':(context) => const ChatPageView(jid: "917010279986@xmpp-uikit-qa.contus.us",profile: ,)
      },*/
      home: Dashboard()
    );
  }

}

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(child: const Text('register'),onPressed: () async {
              try {
                var response = await MirrorflyUikit.register('919894940560');
                debugPrint("register user $response");
              }catch(e){

              }
            },),
            TextButton(child: const Text('chat page'),onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (con)=> DashboardView(title: "Chat",)));
            },),
          ],
        ),
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // var profile = Profile();
  @override
  void initState() {
    super.initState();
    /*profile.contactType= "unknown_contact";
    profile.email= "maniflutter@gmail.com";
    profile.groupCreatedTime= "917010279986";
    profile.image= "";
    profile.imagePrivacyFlag= "";
    profile.isAdminBlocked= false;
    profile.isBlocked= false;
    profile.isBlockedMe= false;
    profile.isGroupAdmin= false;
    profile.isGroupInOfflineMode= false;
    profile.isGroupProfile= false;
    profile.isItSavedContact= false;
    profile.isMuted= false;
    profile.isSelected= false;
    profile.jid= "917010279986@xmpp-uikit-qa.contus.us";
    profile.lastSeenPrivacyFlag= "";
    profile.mobileNUmberPrivacyFlag= "";
    profile.mobileNumber= "917010279986";
    profile.name= "Mani Flutter jio";
    profile.nickName= "917010279986";
    profile.status= "I am in Mirror Fly";*/
    // MirrorflyUikit.register('919894940560');
  }

  @override
  Widget build(BuildContext context) {
    /*return ChatPageView(profile:profile, jid: '917010279986@xmpp-uikit-qa.contus.us',onBack: (){
      debugPrint('onBack');
      Navigator.pop(context);
    },);*/
    return const ChatDashboard();
    /*return Scaffold(
      body: Center(
        child: TextButton(child: const Text('chat page'),onPressed: (){
          // Navigator.pushNamed(context, "/chat",arguments: profile);
          Navigator.push(context, MaterialPageRoute(builder: (con)=>ChatPageView(profile:profile, jid: '',)));
        },),
      ),
    );*/
  }
}



