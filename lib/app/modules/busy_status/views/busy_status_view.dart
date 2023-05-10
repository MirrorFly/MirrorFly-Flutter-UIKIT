import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../controllers/busy_status_controller.dart';
import 'add_busy_status_view.dart';

class BusyStatusView extends StatefulWidget {
  const BusyStatusView({Key? key, this.status}) : super(key: key);
  final String? status;
  @override
  State<BusyStatusView> createState() => _BusyStatusViewState();
}

class _BusyStatusViewState extends State<BusyStatusView> {
  final controller = Get.put(BusyStatusController());

  @override
  void initState() {
    controller.init(widget.status);
    super.initState();
  }
  @override
  void dispose() {
    Get.delete<BusyStatusController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: AppBar(
          title: Text(Constants.editBusyStatus, style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
          iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
          backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Constants.yourBusyStatus,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                ),
                const SizedBox(
                  height: 15,
                ),
                const AppDivider(),
                Obx(
                      () =>
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(controller.busyStatus.value,
                            maxLines: null,
                            style: TextStyle(
                                color: MirrorflyUikit.getTheme?.textPrimaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal)),
                        trailing: SvgPicture.asset(
                          pencilEditIcon,
                          package: package,
                          fit: BoxFit.contain,
                          color: MirrorflyUikit.getTheme?.textSecondaryColor,
                        ),
                        onTap: () {
                          controller.addStatusController.text = controller.busyStatus.value;
                          controller.onChanged();
                          // Get.to(const AddBusyStatusView(),arguments: {"status":controller.selectedStatus.value})?.then((value){
                          //   if(value!=null){
                          //     controller.insertBusyStatus(value);
                          //   }
                          // });
                          Navigator.push(context, MaterialPageRoute(builder: (con) => AddBusyStatusView(status: controller.selectedStatus.value))).then((value) {
                            if(value!=null){
                              controller.insertBusyStatus(value);
                            }
                          });
                        },
                      ),
                ),
                const SizedBox(
                  height: 5,
                ),

                Text(
                  Constants.busyStatusDescription,
                  style: TextStyle(fontSize: 15, color: MirrorflyUikit.getTheme?.textSecondaryColor),
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  Constants.newBusyStatus,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                ),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: Obx(() {
                    debugPrint("reloading list");
                    return controller.busyStatusList.isNotEmpty
                        ?  ListView.builder(
                        itemCount: controller.busyStatusList.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var item = controller.busyStatusList[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.status.checkNull(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: item.status ==
                                        controller.busyStatus.value
                                        ? MirrorflyUikit.getTheme?.textPrimaryColor
                                        : MirrorflyUikit.getTheme?.textSecondaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            trailing: item.status == controller.busyStatus.value
                                ? SvgPicture.asset(
                              tickIcon,
                              package: package,
                              fit: BoxFit.contain,
                            ) : const SizedBox(),
                            onTap: () {
                              controller.updateBusyStatus(
                                  index, item.status.checkNull());
                            },
                            onLongPress: () {
                              controller.deleteBusyStatus(item, context);
                            },
                          );
                        }) : const SizedBox();
                  }),
                ),
              ],
            ),
          ),
        ));
  }
}