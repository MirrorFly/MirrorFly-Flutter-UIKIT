import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/controllers/contact_controller.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/dashboard/widgets.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../widgets/custom_action_bar_icons.dart';

class ContactListView extends StatefulWidget {
   const ContactListView({super.key,this.messageIds,this.group= false,this.groupJid = '', this.enableAppBar=true, this.showSettings=false});
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if(controller.search) {
          controller.backFromSearch();
          return;
        }
        Navigator.pop(context);
      },
      child: Obx(
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
                        hintText: AppConstants.searchPlaceHolder, border: InputBorder.none, hintStyle: TextStyle(
                    color: MirrorflyUikit
                        .getTheme?.colorOnAppbar.withOpacity(0.5))),
                  )
                : controller.isForward.value
                    ? Text(AppConstants.forwardTo, style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar))
                    : controller.isCreateGroup.value
                        ? Text(
                AppConstants.addParticipants,
                            overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 16, color: MirrorflyUikit.getTheme?.colorOnAppbar)
                          )
                        : Text(AppConstants.contacts, style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar)),
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
                    icon: SvgPicture.asset(searchIcon,package: package,colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn))),
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
                      controller.groupJid.value.isNotEmpty ? AppConstants.next.toUpperCase() : AppConstants.create.toUpperCase(),
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
                    //mani said to comment this bcz this option seems not necessary for this screen
                    // CustomAction(
                    //   visibleWidget: IconButton(
                    //       onPressed: () {}, icon: Icon(Icons.settings, color: MirrorflyUikit.getTheme?.colorOnAppbar,)),
                    //   overflowWidget: InkWell(
                    //     child: Text(AppConstants.settings, style: TextStyle(fontSize: 16, color: MirrorflyUikit.getTheme?.colorOnAppbar)),
                    //     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (con)=> const SettingsView())),
                    //   ),
                    //   showAsAction: widget.showSettings ? ShowAsAction.never : ShowAsAction.gone,
                    //   keyValue: AppConstants.settings,
                    //   onItemClick: () {
                    //     Navigator.push(context, MaterialPageRoute(builder: (con)=> const SettingsView()));
                    //   },
                    // ),
                    CustomAction(
                      visibleWidget: IconButton(
                          onPressed: () {}, icon: const Icon(Icons.refresh)),
                      overflowWidget: InkWell(
                        child: Text(AppConstants.refresh, style: TextStyle(fontSize: 16, color: MirrorflyUikit.getTheme?.colorOnAppbar)),
                        onTap: (){
                          Navigator.pop(context);
                          controller.refreshContacts(true);
                        },
                      ),
                      showAsAction: (Constants.enableContactSync && !controller.progressSpinner.value) ? ShowAsAction
                          .never : ShowAsAction.gone,
                      keyValue: AppConstants.refresh,
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
                  tooltip: AppConstants.forward,
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
                          child: Text(AppConstants.noContactsFound, style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor)),
                        ),)),
                    controller.isPageLoading.value
                        ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.primaryColor),
                        )) : const Offstage(),
                    Column(
                          children: [
                            controller.isPageLoading.value ? Expanded(child: Container()) : Expanded(
                            child: ListView.builder(
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
                                    return ContactItem(item: item,onAvatarClick: (){
                                      controller.showProfilePopup(item.obs,context);
                                    },
                                      spanTxt: controller.searchQuery.text,
                                      isCheckBoxVisible: controller.isCheckBoxVisible,
                                      checkValue: controller.selectedUsersJIDList.contains(item.jid),
                                      onCheckBoxChange: (value){
                                        controller.onListItemPressed(item,context);
                                      },onListItemPressed: (){
                                        controller.onListItemPressed(item,context);
                                      },);
                                  } else {
                                    return const Offstage();
                                  }
                                }),
                            ),
                            Obx(() {
                              return controller.groupCallMembersCount.value>1 ? InkWell(
                                onTap: (){
                                  controller.makeCall(context);
                                },
                                child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: MirrorflyUikit.getTheme?.primaryColor,
                                        shape: BoxShape.rectangle,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(2), topRight: Radius.circular(2))
                                    ),
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
                                          const SizedBox(width: 8,),
                                          Text(AppConstants.callNow.replaceAll("%d", (controller.groupCallMembersCount.value -1).toString()),
                                            style: TextStyle(
                                                color: MirrorflyUikit.getTheme?.colorOnPrimary, fontSize: 14, fontWeight: FontWeight.w500,
                                                fontFamily: 'sf_ui'),)
                                        ],
                                      ),
                                    )),
                              ) : const Offstage();
                            })
                          ],
                        )
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
