import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirrorfly_uikit_plugin/app/model/arguments.dart';
import 'package:mirrorfly_uikit_plugin/app/routes/mirrorfly_navigation_observer.dart';
import 'package:mirrorfly_uikit_plugin/app/routes/route_settings.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MirrorflyUikit.instance.initUIKIT(
    navigatorKey: navigatorKey,
    licenseKey: 'LICENSE_KEY',
    iOSContainerID: 'group.com.mirrorfly.flutter',
  );

  /// Use this method to add the locale you want to support in the UIKIT Plugin.
  AppLocalizations.addSupportedLocales(const Locale("hi", "IN"));

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
                              var response = await MirrorflyUikit.login(
                                  userIdentifier: uniqueId);
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
    MirrorflyUikit.logoutFromUIKIT().then((value) {
      debugPrint("logout user $value");
      showSnack(value['message']);
    }).catchError((er) {});
  }
}
