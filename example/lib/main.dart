import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/dashboard/views/dashboard_view.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MirrorflyUikit.initUIKIT();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme()
      ),
      home: const Dashboard()
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
                var response = await MirrorflyUikit.register('918973725802');
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


