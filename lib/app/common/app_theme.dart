import 'package:flutter/material.dart';
import 'constants.dart';

class MirrorFlyAppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
        color: appBarColor,
        iconTheme: IconThemeData(color: iconColor),
        titleTextStyle: TextStyle(
            color: appbarTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'sf_ui')),
    hintColor: Colors.black26,
    fontFamily: 'sf_ui',
    textTheme: const TextTheme(
      titleLarge: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.bold, fontFamily: 'sf_ui'),
      titleMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
          fontFamily: 'sf_ui',
          color: textHintColor),
      titleSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'sf_ui',
          color: textColor),
    ),
  );
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: iconColor),
        titleTextStyle: TextStyle(
            color: appbarTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'sf_ui')),
    hintColor: Colors.black26,
    fontFamily: 'sf_ui',
    textTheme: const TextTheme(
      titleLarge: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.bold, fontFamily: 'sf_ui'),
      titleMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
          fontFamily: 'sf_ui',
          color: textHintColor),
      titleSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'sf_ui',
          color: textColor),
    ),
  );
}

class CustomSafeArea extends StatelessWidget {
  final Widget child;
  final Color? color;

  const CustomSafeArea({Key? key, required this.child, this.color})
      : super(key: key);

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

/*class AppColors {
  AppColors({this.primaryColor,
      this.secondaryColor,
      this.scaffoldColor,
      this.colorOnPrimary,
      this.textPrimaryColor,
      this.textSecondaryColor,
      this.chatBubblePrimaryColor,
      this.chatBubbleSecondaryColor});
  Color? primaryColor;
  Color? secondaryColor;
  Color? scaffoldColor;
  Color? colorOnPrimary;
  Color? textPrimaryColor;
  Color? textSecondaryColor;
  Color? chatBubblePrimaryColor;//chat bubble sender
  Color? chatBubbleSecondaryColor;//chat bubble receiver
}*/

enum MirrorflyTheme  {
  lightTheme(
      primaryColor: Colors.white,
      secondaryColor: Colors.grey,
      scaffoldColor: Colors.white,
      colorOnPrimary: Colors.black,
      textPrimaryColor: Colors.black,
      textSecondaryColor: Colors.black45,
      chatBubblePrimaryColor: Colors.blue,
      chatBubbleSecondaryColor: Colors.black12),
  darkTheme(
      primaryColor: Colors.black,
      secondaryColor: Colors.black12,
      scaffoldColor: Colors.black,
      colorOnPrimary: Colors.white,
      textPrimaryColor: Colors.white,
      textSecondaryColor: Colors.black12,
      chatBubblePrimaryColor: Colors.blue,
      chatBubbleSecondaryColor: Colors.black12);

  const MirrorflyTheme(
      {this.primaryColor,
      this.secondaryColor,
      this.scaffoldColor,
      this.colorOnPrimary,
      this.textPrimaryColor,
      this.textSecondaryColor,
      this.chatBubblePrimaryColor,
      this.chatBubbleSecondaryColor});

  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? scaffoldColor;
  final Color? colorOnPrimary;
  final Color? textPrimaryColor;
  final Color? textSecondaryColor;
  final Color? chatBubblePrimaryColor; //chat bubble sender
  final Color? chatBubbleSecondaryColor; //chat bubble receiver

  static customTheme({required Color primaryColor,
    required Color secondaryColor,
    required Color scaffoldColor,
    required Color colorOnPrimary,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color chatBubblePrimaryColor,
    required Color chatBubbleSecondaryColor}){
    return MirrorflyTheme.customTheme(primaryColor: primaryColor, secondaryColor: secondaryColor, scaffoldColor: scaffoldColor, colorOnPrimary: colorOnPrimary, textPrimaryColor: textPrimaryColor, textSecondaryColor: textSecondaryColor, chatBubblePrimaryColor: chatBubblePrimaryColor, chatBubbleSecondaryColor: chatBubbleSecondaryColor);
  }
  // const MirrorflyTheme(this.value);
  // final AppColors value;
}
