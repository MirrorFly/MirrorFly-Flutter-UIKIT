import 'package:flutter/material.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

import '../common/constants.dart';
import '../common/widgets.dart';
import '../model/user_list_model.dart';

Widget buildProfileImage(Profile item) {
  return ImageNetwork(
    url: item.image.toString(),
    width: 105,
    height: 105,
    clipOval: true,
    errorWidget: item.isGroupProfile.checkNull()
        ? ClipOval(
      child: Image.asset(
        groupImg,
        height: 48,
        width: 48,
        fit: BoxFit.cover,
      ),
    )
        : ProfileTextImage(
      text: item.getName(),
      radius: 50,
    ),
    isGroup: item.isGroupProfile.checkNull(),
    blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
    unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
  );
}