import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/controllers/forwardchat_controller.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../dashboard/widgets.dart';

class ForwardChatView extends StatefulWidget {
  const ForwardChatView({Key? key, required this.forwardMessageIds})
      : super(key: key);
  final List<String> forwardMessageIds;

  @override
  State<ForwardChatView> createState() => _ForwardChatViewState();
}

class _ForwardChatViewState extends State<ForwardChatView> {
  final controller = Get.put(ForwardChatController());

  @override
  void dispose() {
    super.dispose();
    Get.delete<ForwardChatController>();
  }

  @override
  void initState() {
    controller.init(widget.forwardMessageIds);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
          backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              !controller.isSearchVisible
                  ? controller.backFromSearch()
                  : Navigator.pop(context);
            },
          ),
          title: !controller.isSearchVisible
              ? TextField(
                  onChanged: (text) {
                    mirrorFlyLog("text", text);
                    controller.onSearch(text);
                  },
                  style: TextStyle(fontSize: 16,color: MirrorflyUikit.getTheme?.colorOnAppbar),
                  controller: controller.searchQuery,
                  autofocus: true,
                  cursorColor: MirrorflyUikit.getTheme?.colorOnAppbar,
                  keyboardAppearance: MirrorflyUikit.theme == "dark"
                      ? Brightness.dark
                      : Brightness.light,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: MirrorflyUikit
                        .getTheme?.colorOnAppbar.withOpacity(0.5)),
                      hintText: "Search...", border: InputBorder.none),
                )
              : Text("Forward to...",style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
          actions: [
            Visibility(
              visible: controller.isSearchVisible,
              child: IconButton(
                  onPressed: () => controller.onSearchPressed(),
                  icon: SvgPicture.asset(
                    searchIcon,
                    package: package,
                    color: MirrorflyUikit.getTheme?.colorOnAppbar,
                  )),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                child: ListView(
                  controller: controller.userlistScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Column(
                      children: [
                        Visibility(
                          visible: !controller.searchLoading.value &&
                              controller.recentChats.isEmpty &&
                              controller.groupList.isEmpty &&
                              controller.userList.isEmpty,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text('No Results found',style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: controller.recentChats.isNotEmpty,
                          child: searchHeader("Recent Chat", "", context),
                        ),
                        ListView.builder(
                            itemCount: controller.recentChats.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              var item = controller.recentChats[index];
                              return Opacity(
                                opacity: item.isBlocked.checkNull() ? 0.3 : 1.0,
                                child: RecentChatItem(
                                    item: item,
                                    onTap: () {
                                      //chat page
                                      controller.onItemSelect(
                                          item.jid.checkNull(),
                                          getRecentName(
                                              item) /*item.profileName.checkNull()*/,
                                          item.isBlocked.checkNull(),
                                          context);
                                    },
                                    spanTxt:
                                        controller.searchQuery.text.toString(),
                                    isCheckBoxVisible: true,
                                    isForwardMessage: true,
                                    isChecked: controller
                                        .isChecked(item.jid.checkNull()),
                                    onchange: (value) {
                                      controller.onItemSelect(
                                          item.jid.checkNull(),
                                          getRecentName(
                                              item) /*item.profileName.checkNull()*/,
                                          item.isBlocked.checkNull(),
                                          context);
                                    }),
                              );
                            }),
                        Visibility(
                          visible: controller.groupList.isNotEmpty,
                          child: searchHeader("Groups", "", context),
                        ),
                        ListView.builder(
                            itemCount: controller.groupList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              var item = controller.groupList[index];
                              return FutureBuilder(
                                  future: controller.getParticipantsNameAsCsv(
                                      item.jid.checkNull()),
                                  builder: (cxt, data) {
                                    if (data.hasError) {
                                      return const SizedBox();
                                    } else {
                                      if (data.data != null) {
                                        return Opacity(
                                          opacity: item.isBlocked.checkNull()
                                              ? 0.3
                                              : 1.0,
                                          child: memberItem(
                                            name: getName(item),
                                            //item.name.checkNull(),
                                            image: item.image.checkNull(),
                                            status: data.data.checkNull(),
                                            spantext: controller
                                                .searchQuery.text
                                                .toString(),
                                            onTap: () {
                                              controller.onItemSelect(
                                                  item.jid.checkNull(),
                                                  getName(
                                                      item) /*item.name.checkNull()*/,
                                                  item.isBlocked.checkNull(),
                                                  context);
                                            },
                                            isCheckBoxVisible: true,
                                            isChecked: controller.isChecked(
                                                item.jid.checkNull()),
                                            onchange: (value) {
                                              controller.onItemSelect(
                                                  item.jid.checkNull(),
                                                  getName(
                                                      item) /*item.name.checkNull()*/,
                                                  item.isBlocked.checkNull(),
                                                  context);
                                            },
                                            blocked: item.isBlockedMe
                                                    .checkNull() ||
                                                item.isAdminBlocked.checkNull(),
                                            unknown: (!item.isItSavedContact
                                                    .checkNull() ||
                                                item.isDeletedContact()),
                                          ),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    }
                                  });
                            }),
                        Visibility(
                          visible: controller.userList.isNotEmpty,
                          child: searchHeader("Contacts", "", context),
                        ),
                        Visibility(
                          visible: controller.searchLoading.value ||
                              controller.contactLoading.value,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(
                                color: MirrorflyUikit.getTheme?.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        /*Visibility(
                          visible: !controller.searchLoading.value && controller.userList.isEmpty,
                          child: const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('No Contacts found'),
                          ),),
                        ),*/
                        Visibility(
                          visible: controller.userList.isNotEmpty,
                          child: controller.searchLoading.value
                              ? const SizedBox.shrink()
                              : ListView.builder(
                                  itemCount: controller.scrollable.value
                                      ? controller.userList.length + 1
                                      : controller.userList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (index >= controller.userList.length) {
                                      return Center(
                                          child: CircularProgressIndicator(
                                        color: MirrorflyUikit
                                            .getTheme?.primaryColor,
                                      ));
                                    } else {
                                      var item = controller.userList[index];
                                      return Opacity(
                                        opacity: item.isBlocked.checkNull()
                                            ? 0.3
                                            : 1.0,
                                        child: memberItem(
                                          name: getName(item),
                                          image: item.image.checkNull(),
                                          status: item.status.checkNull(),
                                          spantext: controller.searchQuery.text
                                              .toString(),
                                          onTap: () {
                                            controller.onItemSelect(
                                                item.jid.checkNull(),
                                                getName(
                                                    item) /*item.name.checkNull()*/,
                                                item.isBlocked.checkNull(),
                                                context);
                                          },
                                          isCheckBoxVisible: true,
                                          isChecked: controller
                                              .isChecked(item.jid.checkNull()),
                                          onchange: (value) {
                                            controller.onItemSelect(
                                                item.jid.checkNull(),
                                                getName(
                                                    item) /*item.name.checkNull()*/,
                                                item.isBlocked.checkNull(),
                                                context);
                                          },
                                          blocked: item.isBlockedMe
                                                  .checkNull() ||
                                              item.isAdminBlocked.checkNull(),
                                          unknown: (!item.isItSavedContact
                                                  .checkNull() ||
                                              item.isDeletedContact()),
                                        ),
                                      );
                                    }
                                  }),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: controller.selectedNames.isEmpty
                          ? Text("No Users Selected",
                              style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor))
                          : Text(
                              controller.selectedNames.join(","),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),
                            ),
                    ),
                    Visibility(
                      visible: controller.selectedNames.isNotEmpty,
                      child: InkWell(
                        onTap: () {
                          controller.forwardMessages(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "NEXT",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500,color: MirrorflyUikit.getTheme?.primaryColor),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              /*ListTile(
                leading:
                    Flexible(child: Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Text(controller.selectedNames.value.join(",")),
                    )),
                trailing: InkWell(
                  onTap: () {
                    controller.forwardMessages();
                  },
                  child: Text("NEXT",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                ),
              )*/
            ],
          ),
        ),
      );
    });
  }
}
