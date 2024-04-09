import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirrorfly_uikit_plugin/app/common/notification_service.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
var isOnGoingCall = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MirrorflyUikit.instance.initUIKIT(
    navigatorKey:navigatorKey,
  licenseKey: 'ckIjaccWBoMNvxdbql8LJ2dmKqT5bp',
  googleMapKey: 'AIzaSyBaKkrQnLT4nacpKblIE5d4QK6GpaX5luQ',
  iOSContainerID: 'group.com.mirrorfly.flutter');
  isOnGoingCall = (await MirrorflyUikit.isOnGoingCall()) ?? false;
  //if isOnGoingCall is returns True then Navigate to OnGoingCallView() this will only for app killed state, call received via FCM

  // AppConstants.newGroup = "New Group Create";
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    _configureSelectNotificationSubject();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(textTheme: GoogleFonts.latoTextTheme()),
        home: const Dashboard());
  }

  void _configureSelectNotificationSubject() {
    ///Used to perform the action when local notification is selected.
    selectNotificationStream.stream.listen((String? payload) async {
      debugPrint("payload $payload");
    });
  }


}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var uniqueId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter Unique Id :'),
              const SizedBox(
                height: 10,
              ),
              TextField(
                onChanged: (String text) {
                  setState(() {
                    uniqueId = text;
                  });
                },
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]"))
                ],
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildTextButton(
                        onPressed: () {
                          logoutFromSDK();
                        },
                        text: 'Logout'),
                    const SizedBox(
                      width: 10,
                    ),
                    buildTextButton(
                        onPressed: () async {
                          if (uniqueId.isNotEmpty) {
                            try {
                              var response =
                                  await MirrorflyUikit.login(userIdentifier: uniqueId);
                              debugPrint("register user $response");
                              showSnack(response['message']);
                            } catch (e) {
                              showSnack(e.toString());
                            }
                          } else {
                            showSnack('Unique id must not be empty');
                          }
                        },
                        text: 'Register'),
                  ],
                ),
              ),
              Center(
                child: buildTextButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (con) => const DashboardView(
                                  title: "Chats",
                              enableAppBar: true,
                              showChatDeliveryIndicator: true,
                                )));
                  },
                  text: 'chat page',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextButton buildTextButton({Function()? onPressed, required String text}) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  showSnack(String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(
      content: Text(text),
      action:
          SnackBarAction(label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
    ));
  }

  logoutFromSDK() async {
    MirrorflyUikit.logoutFromUIKIT().then((value) {
      debugPrint("logout user $value");
      showSnack(value['message']);
    }).catchError((er) {});
  }
}
