import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/profile/controllers/status_controller.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import 'add_status_view.dart';

class StatusListView extends StatefulWidget {
  const StatusListView({Key? key, required this.status,this.enableAppBar=true}) : super(key: key);
  final bool enableAppBar;
  final String status;

  @override
  State<StatusListView> createState() => _StatusListViewState();
}

class _StatusListViewState extends State<StatusListView> {
  var controller = Get.put(StatusListController());

  @override
  void initState() {
    controller.init(widget.status);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: widget.enableAppBar ? AppBar(
        automaticallyImplyLeading: true,
        title: Text('Status', style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
        iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      ):null,
      body: WillPopScope(
        onWillPop: () {
          // Get.back(result: controller.selectedStatus.value);
          Navigator.pop(context, controller.selectedStatus.value);
          return Future.value(false);
        },
        child: Container(
          padding: const EdgeInsets.all(
            20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your current status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MirrorflyUikit.getTheme?.textPrimaryColor,),
              ),
              Obx(
                () => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(controller.selectedStatus.value,
                      maxLines: null,
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.textSecondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal)),
                  trailing: SvgPicture.asset(
                    pencilEditIcon,package: package,
                    fit: BoxFit.contain,
                    color: MirrorflyUikit.getTheme?.textSecondaryColor,
                  ),
                  onTap: () async {
                    // Get.to(const AddStatusView(), arguments: {
                    //   "status": controller.selectedStatus.value
                    // })?.then((value) {
                    //   if (value != null) {
                    //     controller.insertStatus();
                    //   }
                    // });
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (con)=> AddStatusView(status: controller.selectedStatus.value)));
                    if (result != null) {
                      if(context.mounted)controller.insertStatus(context);
                    }
                  },
                ),
              ),
              const AppDivider(),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Select your new status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MirrorflyUikit.getTheme?.textPrimaryColor),
              ),
              Obx(() => controller.statusList.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                          itemCount: controller.statusList.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var item = controller.statusList[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.status.checkNull(),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: item.status ==
                                              controller.selectedStatus.value
                                          ? MirrorflyUikit.getTheme?.textPrimaryColor
                                          : MirrorflyUikit.getTheme?.textSecondaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              trailing:
                                  item.status == controller.selectedStatus.value
                                      ? SvgPicture.asset(
                                          tickIcon,package: package,
                                          fit: BoxFit.contain,
                                        )
                                      : const SizedBox(),
                              onTap: () {
                                controller.updateStatus(context, item.status.checkNull(),
                                    item.id.checkNull());
                              },
                              onLongPress: (){
                                debugPrint("Status list long press");
                                controller.deleteStatus(item, context);
                              },
                            );
                          }),
                    )
                  : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
