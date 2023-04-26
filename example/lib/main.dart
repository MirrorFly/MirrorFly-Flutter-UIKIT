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
      iOSContainerID: 'group.com.mirrorfly.qa',theme: MirrorflyTheme.customTheme(primaryColor: Colors.white,
      secondaryColor: Colors.grey,
      scaffoldColor: Colors.white,
      colorOnPrimary: Colors.black,
      textPrimaryColor: Colors.black,
      textSecondaryColor: Colors.black45,
      chatBubblePrimaryColor: Colors.blue,
      chatBubbleSecondaryColor: Colors.black12));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Dashboard()
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Navigator.push(context, MaterialPageRoute(builder: (con)=> DashboardView()));
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
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    // This is the Return Chat Widget from our UI KIT
    return const ChatDashboard();
  }
}



