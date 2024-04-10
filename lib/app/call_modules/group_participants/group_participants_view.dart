import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../common/constants.dart';
import '../../modules/dashboard/widgets.dart';
import 'group_participants_controller.dart';

class GroupParticipantsView extends StatefulWidget {
  const GroupParticipantsView(
      {super.key, required this.groupId, required this.callType});

  final String groupId;
  final String callType;

  @override
  State<GroupParticipantsView> createState() => _GroupParticipantsViewState();
}

class _GroupParticipantsViewState extends State<GroupParticipantsView> {
  final controller = Get.put(GroupParticipantsController());

  @override
  void initState() {
    super.initState();
    controller.initGroupParticipantController(
        buildContext: context,
        groupId: widget.groupId,
        callType: widget.callType);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              controller.search ? controller.backFromSearch() : Get.back();
            },
          ),
          title: controller.search
              ? TextField(
                  onChanged: (text) {
                    controller.searchListener(text);
                  },
                  focusNode: controller.searchFocus,
                  style: const TextStyle(fontSize: 16),
                  controller: controller.searchQuery,
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: "Search...", border: InputBorder.none),
                )
              : const Text(
                  "Add Participants",
                  overflow: TextOverflow.fade,
                ),
          actions: [
            Visibility(
              visible: controller.isSearchVisible,
              child: IconButton(
                  onPressed: () => controller.onSearchPressed(),
                  icon: SvgPicture.asset(searchIcon)),
            ),
            Visibility(
              visible: controller.isClearVisible,
              child: IconButton(
                  onPressed: () => controller.clearSearch(),
                  icon: const Icon(Icons.clear)),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                      itemCount: controller.usersList.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= controller.usersList.length &&
                            controller.usersList.isNotEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (controller.usersList.isNotEmpty) {
                          var item = controller.usersList[index];
                          return ContactItem(
                            item: item,
                            onAvatarClick: () {
                              controller.showProfilePopup(item.obs);
                            },
                            spanTxt: controller.searchQuery.text,
                            isCheckBoxVisible: true,
                            checkValue: controller.selectedUsersJIDList
                                .contains(item.jid),
                            onCheckBoxChange: (value) {
                              controller.onListItemPressed(item);
                            },
                            onListItemPressed: () {
                              controller.onListItemPressed(item);
                            },
                          );
                        } else {
                          return const SizedBox();
                        }
                      });
                }),
              ),
              Obx(() {
                return InkWell(
                  onTap: () {
                    controller.makeCall();
                  },
                  child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: controller.selectedUsersJIDList.isNotEmpty
                              ? buttonBgColor
                              : chatTimeColor,
                          shape: BoxShape.rectangle,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(2),
                              topRight: Radius.circular(2))),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SvgPicture.asset(
                              controller.callType.value == CallType.audio
                                  ? audioCallSmallIcon
                                  : videoCallSmallIcon,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              "CALL NOW ( ${(controller.groupCallMembersCount.value - 1)} )",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'sf_ui'),
                            )
                          ],
                        ),
                      )),
                );
              })
            ],
          ),
        ),
      );
    });
  }
}
