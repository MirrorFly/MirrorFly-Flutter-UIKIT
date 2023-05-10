import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/blocked/blocked_list_controller.dart';

import '../../../../../mirrorfly_uikit_plugin.dart';
import '../../../../common/widgets.dart';

class BlockedListView extends StatefulWidget {
  const BlockedListView({Key? key}) : super(key: key);

  @override
  State<BlockedListView> createState() => _BlockedListViewState();
}

class _BlockedListViewState extends State<BlockedListView> {
  final controller = Get.put(BlockedListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: AppBar(
        title: Text('Blocked Contact List', style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      ),
      body: Obx(() {
        return Center(
          child: controller.blockedUsers.isEmpty ? Text(
            "No Blocked Contacts found",
            style: TextStyle(fontSize: 17, color: MirrorflyUikit.getTheme?.textPrimaryColor),) :
          ListView.builder(
            itemCount: controller.blockedUsers.length,
              itemBuilder: (context, index) {
            var item = controller.blockedUsers[index];
            return memberItem(name :getMemberName(item).checkNull(),image: item.image.checkNull(),status: item.mobileNumber.checkNull(),onTap: (){
              if (item.jid.checkNull().isNotEmpty) {
                controller.unBlock(item, context);
              }
            },blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
              unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),);
          }),
        );
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<BlockedListController>();
  }
}