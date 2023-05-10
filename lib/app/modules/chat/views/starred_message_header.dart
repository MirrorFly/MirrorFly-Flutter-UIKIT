import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_uikit_plugin/mirrorfly_uikit.dart';
import '../../../models.dart';

import '../../../common/widgets.dart';
import '../../starred_messages/controllers/starred_messages_controller.dart';

/*
class StarredMessageHeader extends StatefulWidget {
  const StarredMessageHeader(
      {Key? key, required this.chatList, required this.isTapEnabled})
      : super(key: key);

  final ChatMessageModel chatList;
  final bool isTapEnabled;

  @override
  State<StarredMessageHeader> createState() => _StarredMessageHeaderState();
}
*/

class StarredMessageHeader extends StatelessWidget {
  StarredMessageHeader(
      {Key? key, required this.chatList, required this.isTapEnabled})
      : super(key: key);
  final ChatMessageModel chatList;
  final bool isTapEnabled;
  final controller = Get.find<StarredMessagesController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      margin: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: getHeader(chatList, context),
    );
  }

  Future<Profile> getProfile() async {
    var value = await Mirrorfly.getProfileDetails(chatList.chatUserJid, true);
    return Profile.fromJson(json.decode(value.toString()));
  }

  getHeader(ChatMessageModel chatList, BuildContext context) {
    return FutureBuilder(
        future: getProfile(),
        builder: (context, d) {
          var userProfile = d.data;
          if (userProfile != null) {
            if (chatList.isMessageSentByMe) {
              return Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getChatTime(chatList.messageSentTime.toInt()),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            userProfile.name.checkNull(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                            decoration: BoxDecoration(
                              color: MirrorflyUikit.getTheme?.secondaryColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(2)),
                            ),
                            margin: const EdgeInsets.all(5),
                            // padding: const EdgeInsets.all(1),
                            child: Icon(
                              Icons.arrow_left,
                              color: MirrorflyUikit.getTheme?.textPrimaryColor,
                              size: 14,
                            )),
                        Text("You",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15, color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                  getProfileImage(userProfile),
                ],
              );
            } else {
              return Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getProfileImage(userProfile),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                        userProfile.isGroupProfile.checkNull() ? chatList.senderNickName : userProfile.name.checkNull(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                            decoration: BoxDecoration(
                              color: MirrorflyUikit.getTheme?.secondaryColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(2)),
                            ),
                            margin: const EdgeInsets.all(5),
                            child: Icon(
                              Icons.arrow_right,
                              color: MirrorflyUikit.getTheme?.textPrimaryColor,
                              size: 14,
                            )),
                        userProfile.isGroupProfile.checkNull()
                            ? Flexible(
                                child: Text(
                                  userProfile.name.checkNull(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, color: MirrorflyUikit.getTheme?.textPrimaryColor,
                                      fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Text("You",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15, color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                  getChatTime(chatList.messageSentTime.toInt()),
                ],
              );
            }
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  getChatTime(int messageSentTime) {
    return Text(
      controller.getChatTime(messageSentTime),
      style: TextStyle(fontSize: 12, color: MirrorflyUikit.getTheme?.textSecondaryColor),
    );
  }

  getProfileImage(Profile userProfile) {
    if (userProfile.image.checkNull().isNotEmpty) {
      return ImageNetwork(
        url: userProfile.image.checkNull(),
        width: 48,
        height: 48,
        clipOval: true,
        errorWidget: ProfileTextImage(
          text: userProfile.name.checkNull().isEmpty
              ? userProfile.mobileNumber.checkNull()
              : userProfile.name.checkNull(),
        ),
        isGroup: userProfile.isGroupProfile.checkNull(),
        blocked: userProfile.isBlockedMe.checkNull() || userProfile.isAdminBlocked.checkNull(),
        unknown: (!userProfile.isItSavedContact.checkNull() || userProfile.isDeletedContact()),
      );
    } else {
      return ProfileTextImage(
        text: userProfile.name.checkNull().isEmpty
            ? userProfile.mobileNumber.checkNull()
            : userProfile.name.checkNull(),
      );
    }
  }
}