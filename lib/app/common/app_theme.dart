import 'package:flutter/material.dart';
import 'constants.dart';

class MirrorFlyAppTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color appBarColor;
  final Color colorOnAppbar;
  final Color scaffoldColor;
  final Color colorOnPrimary;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color chatBubblePrimaryColor; //chat bubble sender
  final Color chatBubbleSecondaryColor; //chat bubble receiver

  MirrorFlyAppTheme(
      {required this.primaryColor,
      required this.secondaryColor,
      required this.appBarColor,
      required this.colorOnAppbar,
      required this.scaffoldColor,
      required this.colorOnPrimary,
      required this.textPrimaryColor,
      required this.textSecondaryColor,
      required this.chatBubblePrimaryColor,
      required this.chatBubbleSecondaryColor});
}

class MirrorFlyTheme {
  static MirrorFlyAppTheme get mirrorFlyLightTheme => MirrorFlyAppTheme(
      primaryColor: buttonBgColor,
      appBarColor: Colors.white,
      colorOnAppbar: Colors.black,
      secondaryColor: notificationTextBgColor,
      scaffoldColor: Colors.white,
      colorOnPrimary: Colors.white,
      textPrimaryColor: Colors.black,
      textSecondaryColor: Colors.black45,
      chatBubblePrimaryColor: Colors.blue,
      chatBubbleSecondaryColor: Colors.black12);

  static MirrorFlyAppTheme get mirrorFlyDarkTheme => MirrorFlyAppTheme(
      primaryColor: buttonBgColor,
      secondaryColor: const Color(0xff676767),
      appBarColor: const Color(0xff2A2A2A),
      colorOnAppbar: Colors.white,
      scaffoldColor: Colors.black,
      colorOnPrimary: Colors.white,
      textPrimaryColor: Colors.white,
      textSecondaryColor: const Color(0xffFAFAFA),
      chatBubblePrimaryColor: chatSentBgColor,
      chatBubbleSecondaryColor: Colors.black12);

  static late var mirrorflyTheme;

  static customTheme(
      {required Color primaryColor,
      required Color secondaryColor,
      required Color appBarColor,
      required Color colorOnAppbar,
      required Color scaffoldColor,
      required Color colorOnPrimary,
      required Color textPrimaryColor,
      required Color textSecondaryColor,
      required Color chatBubblePrimaryColor,
      required Color chatBubbleSecondaryColor}) {
    return mirrorflyTheme = MirrorFlyAppTheme(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        appBarColor: appBarColor,
        colorOnAppbar: colorOnAppbar,
        scaffoldColor: scaffoldColor,
        colorOnPrimary: colorOnPrimary,
        textPrimaryColor: textPrimaryColor,
        textSecondaryColor: textSecondaryColor,
        chatBubblePrimaryColor: chatBubblePrimaryColor,
        chatBubbleSecondaryColor: chatBubbleSecondaryColor);
  }

  static MaterialColor getMaterialColor(Color color) {
    final Map<int, Color> shades = {
      50: const Color.fromRGBO(136, 14, 79, .1),
      100: const Color.fromRGBO(136, 14, 79, .2),
      200: const Color.fromRGBO(136, 14, 79, .3),
      300: const Color.fromRGBO(136, 14, 79, .4),
      400: const Color.fromRGBO(136, 14, 79, .5),
      500: const Color.fromRGBO(136, 14, 79, .6),
      600: const Color.fromRGBO(136, 14, 79, .7),
      700: const Color.fromRGBO(136, 14, 79, .8),
      800: const Color.fromRGBO(136, 14, 79, .9),
      900: const Color.fromRGBO(136, 14, 79, 1),
    };
    return MaterialColor(color.value, shades);
  }
}

class CustomSafeArea extends StatelessWidget {
  final Widget child;
  final Color? color;

  const CustomSafeArea({Key? key, required this.child, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: color ?? appBarColor,
      child: SafeArea(
        child: child,
      ),
    );
  }
}
