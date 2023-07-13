import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/controllers/contact_controller.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/widgets.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../settings/views/settings_view.dart';

class ContactListView extends StatefulWidget {
   const ContactListView({Key? key,this.messageIds,this.group= false,this.groupJid = '', this.enableAppBar=true, this.showSettings=false}) : super(key: key);
   final List<String>? messageIds;
   final bool group;
   final String groupJid;
   final bool enableAppBar;
   final bool showSettings;

   @override
  State<ContactListView> createState() => _ContactListViewState();
}

class _ContactListViewState extends State<ContactListView> {
  ContactController controller = Get.put(ContactController());
  @override
  void initState() {
    controller.init(context,messageIds: widget.messageIds,group: widget.group,groupjid: widget.groupJid);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ContactController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: widget.enableAppBar ? AppBar(
          backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
          leading: IconButton(
            icon: controller.isForward.value
                ? const Icon(Icons.close)
                : const Icon(Icons.arrow_back),
            onPressed: () {
              controller.isForward.value
                  ? Navigator.pop(context)
                  : controller.search
                      ? controller.backFromSearch()
                      : Navigator.pop(context);
            },
          ),
          iconTheme: IconThemeData(
              color: MirrorflyUikit.getTheme?.colorOnAppbar ??
                  iconColor),
          title: controller.search
              ? TextField(
                  onChanged: (text) {
                    controller.searchListener(text);
                  },
            cursorColor: MirrorflyUikit.getTheme?.colorOnAppbar,
            focusNode: controller.searchFocus,
                  style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
                  controller: controller.searchQuery,
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: "Search...", border: InputBorder.none, hintStyle: TextStyle(
                  color: MirrorflyUikit
                      .getTheme?.colorOnAppbar.withOpacity(0.5))),
                )
              : controller.isForward.value
                  ? Text("Forward to...", style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar))
                  : controller.isCreateGroup.value
                      ? Text(
                          "Add Participants",
                          overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 16, color: MirrorflyUikit.getTheme?.colorOnAppbar)
                        )
                      : Text('Contacts', style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar)),
          actions: [
            Visibility(
              visible: controller.progressSpinner.value,
              child: Center(
                child: SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.colorOnAppbar,strokeWidth: 2,),
                ),
              ),
            ),
            Visibility(
              visible: controller.isSearchVisible,
              child: IconButton(
                  onPressed: () => controller.onSearchPressed(),
                  icon: SvgPicture.asset(searchIcon,package: package,color: MirrorflyUikit.getTheme?.colorOnAppbar)),
            ),
            Visibility(
              visible: controller.isClearVisible,
              child: IconButton(
                  onPressed: () => controller.backFromSearch(),
                  icon: Icon(Icons.clear, color: MirrorflyUikit.getTheme?.colorOnAppbar,)),
            ),
            Visibility(
              visible: controller.isCreateVisible,
              child: TextButton(
                  onPressed: () => controller.backToCreateGroup(context),
                  child: Text(
                    controller.groupJid.value.isNotEmpty ? "NEXT" : "CREATE",
                    style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
                  )),
            ),
            Visibility(
              visible: controller.isSearchVisible,
              child: CustomActionBarIcons(
                availableWidth: MediaQuery.of(context).size.width /
                    2, // half the screen width
                actionWidth: 48,
                actions: [
                  CustomAction(
                    visibleWidget: IconButton(
                        onPressed: () {}, icon: Icon(Icons.settings, color: MirrorflyUikit.getTheme?.colorOnAppbar,)),
                    overflowWidget: InkWell(
                      child: Text("Settings", style: TextStyle(fontSize: 16, color: MirrorflyUikit.getTheme?.colorOnAppbar)),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (con)=> const SettingsView())),
                    ),
                    showAsAction: widget.showSettings ? ShowAsAction.never : ShowAsAction.gone,
                    keyValue: 'Settings',
                    onItemClick: () {
                      Navigator.push(context, MaterialPageRoute(builder: (con)=> const SettingsView()));
                    },
                  ),
                  CustomAction(
                    visibleWidget: IconButton(
                        onPressed: () {}, icon: const Icon(Icons.refresh)),
                    overflowWidget: InkWell(
                      child: Text("Refresh", style: TextStyle(fontSize: 16, color: MirrorflyUikit.getTheme?.colorOnAppbar)),
                      onTap: (){
                        Navigator.pop(context);
                        controller.refreshContacts(true);
                      },
                    ),
                    showAsAction: (!MirrorflyUikit.instance.isTrialLicenceKey && !controller.progressSpinner.value) ? ShowAsAction.never : ShowAsAction.gone,
                    keyValue: 'Refresh',
                    onItemClick: () {
                      // Get.back();
                      controller.refreshContacts(true);
                    },
                  )
                ],
              ),
            ),
          ],
        ) : null,
        floatingActionButton: controller.isForward.value &&
                controller.selectedUsersList.isNotEmpty
            ? FloatingActionButton(
                tooltip: "Forward",
                onPressed: () {
                  FocusManager.instance.primaryFocus!.unfocus();
                  controller.forwardMessages(context);
                }, backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
                child: Icon(Icons.check, color: MirrorflyUikit.getTheme?.colorOnPrimary ??
                  Colors.white,))
            : const SizedBox.shrink(),
        body: Obx(() {
          return RefreshIndicator(
            key: controller.refreshIndicatorKey,
            onRefresh: (){
              return Future(()=>controller.refreshContacts(true));
            },
            child: SafeArea(
              child: Stack(
                children: [
                  Visibility(
                    visible: !controller.isPageLoading.value && controller.usersList.isEmpty,
                      child: Center(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text("No Contacts found", style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                      ),)),
                  controller.isPageLoading.value
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.primaryColor),
                        ))
                      : ListView.builder(
                          itemCount: controller.scrollable.value
                              ? controller.usersList.length + 1
                              : controller.usersList.length,
                          controller: controller.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            if (index >= controller.usersList.length &&
                                controller.usersList.isNotEmpty) {
                              return Center(
                                  child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.primaryColor,));
                            } else if (controller.usersList.isNotEmpty) {
                              var item = controller.usersList[index];
                              return Opacity(
                                opacity: item.isBlocked.checkNull() ? 0.3 : 1.0,
                                child: InkWell(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        child: Container(
                                            margin: const EdgeInsets.only(
                                                left: 19.0,
                                                top: 10,
                                                bottom: 10,
                                                right: 10),
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: item.image.checkNull().isEmpty
                                                  ? iconBgColor
                                                  : buttonBgColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: ImageNetwork(
                                              url: item.image.toString(),
                                              width: 48,
                                              height: 48,
                                              clipOval: true,
                                              errorWidget: getName(item)//item.nickName
                                                      .checkNull()
                                                      .isNotEmpty
                                                  ? ProfileTextImage(
                                                      text:
                                                          getName(item)/*item.nickName.checkNull().isEmpty
                                                              ? item.mobileNumber
                                                                  .checkNull()
                                                              : item.nickName.checkNull()*/,
                                                    )
                                                  : const Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                    ),
                                              blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
                                              unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),isGroup: item.isGroupProfile.checkNull(),
                                            )),
                                        onTap: (){
                                          controller.showProfilePopup(item.obs, context);
                                        },
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getName(item),
                                              style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            // Text(
                                            //   item.mobileNumber.toString(),
                                            //   style: Theme.of(context)
                                            //       .textTheme
                                            //       .titleSmall,
                                            // )
                                            Text(
                                              item.status.toString(),
                                              style: TextStyle(color: MirrorflyUikit.getTheme?.textSecondaryColor)
                                            )
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: controller.isCheckBoxVisible,
                                        child: Theme(
                                          data: ThemeData(
                                            unselectedWidgetColor: Colors.grey,
                                          ),
                                          child: Checkbox(
                                            activeColor: MirrorflyUikit.getTheme!.primaryColor,//Colors.white,
                                            checkColor: MirrorflyUikit.getTheme?.colorOnPrimary,
                                            value: controller.selectedUsersJIDList
                                                .contains(item.jid),
                                            onChanged: (value) {
                                              controller.onListItemPressed(item, context);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    controller.onListItemPressed(item, context);
                                  },
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          })
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
