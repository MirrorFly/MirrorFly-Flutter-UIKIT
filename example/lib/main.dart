import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirrorfly_uikit_plugin/app/model/arguments.dart';
import 'package:mirrorfly_uikit_plugin/app/routes/mirrorfly_navigation_observer.dart';
import 'package:mirrorfly_uikit_plugin/app/routes/route_settings.dart';
import 'package:mirrorfly_uikit_plugin/app/stylesheet/stylesheet.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var response = await MirrorflyUikit.instance.initUIKIT(
    navigatorKey: navigatorKey,
    licenseKey: 'lKbpoxlB2Yu5zRXS1WSl0Xi7jU99mL',
    iOSContainerID: 'group.com.mirrorfly.flutter',
  );

  debugPrint("init response $response");

  /// Use this method to add the locale you want to support in the UIKIT Plugin.
  AppLocalizations.addSupportedLocales(const Locale("hi", "IN"));
  AppStyleConfig.setChatPageStyle(
      ChatPageStyle(attachmentViewStyle: AttachmentViewStyle()));

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,

        /// CHANGE THE LOCALE TO 'en' TO SEE THE LOCALIZATION IN ENGLISH, 'ar' FOR ARABIC, 'hi' FOR HINDI
        locale: const Locale('en'),

        /// ADD THE SUPPORTED LOCALES TO THE APP
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        /// ADD THE NAVIGATION OBSERVER TO THE APP, TO HANDLE THE NAVIGATION EVENTS
        navigatorObservers: [MirrorFlyNavigationObserver()],

        /// ADD THE ROUTE GENERATOR TO THE APP, TO HANDLE THE ROUTES
        onGenerateRoute: (settings) {
          switch (settings.name) {
            default:
              return mirrorFlyRoute(settings);
          }
        },
        theme: ThemeData(textTheme: GoogleFonts.latoTextTheme()),
        home: const Dashboard());
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
      body: SingleChildScrollView(
        child: Center(
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
                                var response = await MirrorflyUikit.instance
                                    .login(userIdentifier: uniqueId);
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
                              builder: (con) => const DashboardView(),
                              settings: const RouteSettings(
                                  name: 'DashboardView',
                                  arguments: DashboardViewArguments(
                                      didMissedCallNotificationLaunchApp:
                                          false))));
                      // Mirrorfly.getUserProfile(jid: 'testdoctordedicatedforchat@firstresponsehe-xmpp.mirrorfly.com',fetchFromServer: true, saveAsFriend: true, flyCallback:(FlyResponse response){
                      //   if(response.isSuccess) {
                      //     debugPrint("User Profile ${response.data}");
                      //     Navigator.push(context, MaterialPageRoute(builder: (con) => ChatView(chatViewArguments: ChatViewArguments(chatJid: 'testdoctordedicatedforchat@firstresponsehe-xmpp.mirrorfly.com'))));
                      //     // Navigator.push(context, MaterialPageRoute(builder: (con) => ChatView(), settings: const RouteSettings(name: 'ChatView', arguments: ChatViewArguments(chatJid: 'testdoctordedicatedforchat@firstresponsehe-xmpp.mirrorfly.com'))));
                      //   }
                      // });
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (con) => ChatView(
                      //             chatViewArguments: const ChatViewArguments(
                      //                 chatJid:
                      //                     '918973725802@xmpp-uikit-qa.contus.us'))));
                    },
                    text: 'chat page',
                  ),
                ),
                Column(
                  children: [
                    buildTextButton(text: "Create Topic", onPressed: () {
                      Mirrorfly.createTopic(topicName: "lunch", flyCallBack: (FlyResponse response) {
                        if(response.isSuccess) {
                          debugPrint("lunch Topic created successfully ${response.data}");
                        } else {
                          debugPrint("lunch Topic creation failed");
                        }
                      });
                      // Mirrorfly.createTopic(topicName: "laptop", flyCallBack: (FlyResponse response) {
                      //   if(response.isSuccess) {
                      //     debugPrint("laptop Topic created successfully ${response.data}");
                      //   } else {
                      //     debugPrint("laptop Topic creation failed");
                      //   }
                      // });
                    }),
                    const SizedBox(
                      height: 20,
                    ),
                    buildTextButton(
                        text: "Topic : computer",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (con) => ChatView(
                                      chatViewArguments: const ChatViewArguments(
                                          chatJid:
                                              '918973725802@xmpp-uikit-qa.contus.us',
                                          topicId: '90b08813-710a-4224-9a0d-5fae65c0a362'/*'bf0d5c32-5f1a-4037-b814-1c013394c730'*/))));

                        }),

                    const SizedBox(
                      height: 20,
                    ),
                    buildTextButton(
                        text: "GET GROUP INFO",
                        onPressed: () async {
                          var groupJid = await Mirrorfly.getGroupJid(groupId: "55983501-60a2-4ea2-952d-779a302f4bd2");

                          debugPrint("Group Jid $groupJid");

                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    buildTextButton(
                        text: "Open Group",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (con) => ChatView(
                                      chatViewArguments: const ChatViewArguments(
                                          chatJid:
                                          '14f98552-2e4a-487b-8e23-36c1008346e6@mix.firstresponsehe-xmpp.mirrorfly.com',/*082d1057-a8be-4fa4-9c63-2b25b906152c*/))));

                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    buildTextButton(
                        text: "Open Group1",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (con) => ChatView(
                                      chatViewArguments: const ChatViewArguments(
                                          chatJid:
                                          '1681190a-e906-4064-a54c-3b44dc8f219a@mix.firstresponsehe-xmpp.mirrorfly.com',/*082d1057-a8be-4fa4-9c63-2b25b906152c*/))));

                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    buildTextButton(
                        text: "Open Group1 Created By Us",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (con) => ChatView(
                                      chatViewArguments: const ChatViewArguments(
                                          chatJid:
                                          '226f56f0-0c9e-44cb-93dd-614acf28d51e@mix.firstresponsehe-xmpp.mirrorfly.com',/*082d1057-a8be-4fa4-9c63-2b25b906152c*/))));

                        }),

                  ],
                )
              ],
            ),
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
            WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
        padding: WidgetStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
    MirrorflyUikit.instance.logoutFromUIKIT().then((value) {
      debugPrint("logout user $value");
      showSnack(value['message']);
    }).catchError((er) {});
  }
}
