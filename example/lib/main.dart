import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MirrorflyUikit.instance.initUIKIT(
      baseUrl: 'YOUR_BASE_URL',
      licenseKey: 'Your_Mirrorfly_licence_key',
      googleMapKey: 'Your_Google_Map_Key_for_location_messages',
      iOSContainerID: 'Your_iOS_app_Container_id');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
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
                              var response =
                                  await MirrorflyUikit.registerUser(uniqueId);
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
