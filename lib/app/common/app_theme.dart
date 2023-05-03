import 'package:flutter/material.dart';
import '../model/app_config.dart';
import 'constants.dart';


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
      chatBubblePrimaryColor: ChatBubbleColor(color: const Color(0xffe2e8f7), textPrimaryColor: Colors.black, textSecondaryColor: durationTextColor),
      chatBubbleSecondaryColor: ChatBubbleColor(color: const Color(0xcbd7d6d6), textPrimaryColor: const Color(0xff313131), textSecondaryColor: const Color(0xff959595)));

  static MirrorFlyAppTheme get mirrorFlyDarkTheme => MirrorFlyAppTheme(
      primaryColor: buttonBgColor,
      secondaryColor: const Color(0xff676767),
      appBarColor: const Color(0xff2A2A2A),
      colorOnAppbar: Colors.white,
      scaffoldColor: Colors.black,
      colorOnPrimary: Colors.white,
      textPrimaryColor: Colors.white,
      textSecondaryColor: const Color(0xff767676),
      chatBubblePrimaryColor: ChatBubbleColor(color: const Color(0xff2f55c7), textPrimaryColor: Colors.white, textSecondaryColor: const Color(0xffB6CAFF)),
      chatBubbleSecondaryColor: ChatBubbleColor(color: const Color(0xff26262a), textPrimaryColor: const Color(0xfffafafa), textSecondaryColor: const Color(0xff959595)));

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
      required ChatBubbleColor chatBubblePrimaryColor,
      required ChatBubbleColor chatBubbleSecondaryColor}) {
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
