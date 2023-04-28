import 'package:flutter/material.dart';
import 'constants.dart';

class MirrorFlyTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color appBarColor;
  final Color scaffoldColor;
  final Color colorOnPrimary;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color chatBubblePrimaryColor; //chat bubble sender
  final Color chatBubbleSecondaryColor; //chat bubble receiver

  MirrorFlyTheme(
      {required this.primaryColor,
      required this.secondaryColor,
      required this.appBarColor,
      required this.scaffoldColor,
      required this.colorOnPrimary,
      required this.textPrimaryColor,
      required this.textSecondaryColor,
      required this.chatBubblePrimaryColor,
      required this.chatBubbleSecondaryColor});
}

class MirrorFlyAppTheme {
  static get mirrorFlyLightTheme => MirrorFlyTheme(
        primaryColor: buttonBgColor,
        appBarColor: Colors.white,
        secondaryColor: Colors.grey,
        scaffoldColor: Colors.white,
        colorOnPrimary: Colors.black,
        textPrimaryColor: Colors.black,
        textSecondaryColor: Colors.black45,
        chatBubblePrimaryColor: Colors.blue,
        chatBubbleSecondaryColor: Colors.black12);

  static get mirrorFlyDarkTheme => MirrorFlyTheme(
        primaryColor: Colors.black,
        secondaryColor: Colors.black12,
        appBarColor: Colors.black,
        scaffoldColor: Colors.black,
        colorOnPrimary: Colors.white,
        textPrimaryColor: Colors.white,
        textSecondaryColor: Colors.black12,
        chatBubblePrimaryColor: Colors.blue,
        chatBubbleSecondaryColor: Colors.black12);

  static late var mirrorflyTheme;

  static customTheme(
      {required Color primaryColor,
      required Color secondaryColor,
      required Color scaffoldColor,
      required Color colorOnPrimary,
      required Color textPrimaryColor,
      required Color textSecondaryColor,
      required Color chatBubblePrimaryColor,
      required Color chatBubbleSecondaryColor}) {
    return mirrorflyTheme = MirrorFlyTheme(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        appBarColor: primaryColor,
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

  const CustomSafeArea({Key? key, required this.child, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? appBarColor,
      child: SafeArea(
        child: child,
      ),
    );
  }
}

