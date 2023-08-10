
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';

Widget lockItem(
    {required String title, required String subtitle, required bool on, Widget? trailing, required Function(bool value) onToggle, Function()? onTap}) {
  return ListItem(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: MirrorflyUikit.getTheme?.textPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
          const SizedBox(
            height: 4,
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: MirrorflyUikit.getTheme?.textSecondaryColor),
          ),
        ],
      ),
      trailing: trailing ?? FlutterSwitch(
        width: 40.0,
        height: 20.0,
        valueFontSize: 12.0,
        toggleSize: 12.0,
        activeColor: MirrorflyUikit.getTheme!.primaryColor,//Colors.white,
        activeToggleColor: MirrorflyUikit.getTheme?.colorOnPrimary, //Colors.blue,
        inactiveToggleColor: Colors.grey,
        inactiveColor: Colors.white,
        switchBorder: Border.all(
            color: on ? MirrorflyUikit.getTheme!.colorOnPrimary : Colors
                .grey,
            width: 1),
        value: on,
        onToggle: (value) => onToggle(value),
      ),
      dividerPadding: EdgeInsets.zero,
      onTap: onTap);
}

ListItem notificationItem({required String title,
  required String subtitle,
  bool on = false,
  required Function() onTap}) {
  return ListItem(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: MirrorflyUikit.getTheme?.textPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
          const SizedBox(
            height: 4,
          ),

          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: MirrorflyUikit.getTheme?.textSecondaryColor),
          ),
        ],
      ),
      dividerPadding: const EdgeInsets.symmetric(horizontal: 16),
      trailing:
      // SvgPicture.asset(
      //   on ? tickRoundBlue : tickRound,package: package,
      // ),
       on ? Icon(Icons.check_circle_rounded, color: MirrorflyUikit.getTheme?.primaryColor, size: 20,) :
  const Icon(Icons.check_circle_rounded, color: Colors.grey, size: 20,),
      onTap: onTap);
}

Widget settingListItem(
    String title, String? leading, String trailing, Function() onTap) {
  return Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Row(
          children: [
            leading != null ? Padding(
              padding: const EdgeInsets.all(18.0),
              child: SvgPicture.asset(leading,package: package, colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.textSecondaryColor, BlendMode.srcIn),),
            ) : const SizedBox(height: 4,),
            Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'sf_ui',
                      color: MirrorflyUikit.getTheme?.textPrimaryColor,
                      fontWeight: FontWeight.w400),
                )),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SvgPicture.asset(trailing,package: package,),
            ),
          ],
        ),
      ),
      const AppDivider(),
    ],
  );
}


Widget chatListItem(
    Widget title, String trailing, Function() onTap) {
  return Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: title,
                )),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SvgPicture.asset(trailing,package: package,),
            ),
          ],
        ),
      ),
      const AppDivider(),
    ],
  );
}

