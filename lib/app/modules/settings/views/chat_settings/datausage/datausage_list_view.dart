import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';

import '../../../../../../mirrorfly_uikit_plugin.dart';
import 'datausage_controller.dart';

class DataUsageListView extends StatefulWidget {
  const DataUsageListView({super.key,this.enableAppBar=true});
  final bool enableAppBar;
  @override
  State<DataUsageListView> createState() => _DataUsageListViewState();
}

class _DataUsageListViewState extends State<DataUsageListView> {
  final controller = Get.put(DataUsageController());

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    Get.delete<DataUsageController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar:widget.enableAppBar ?  AppBar(
          title: Text(AppConstants.dataUsageSettings, style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar)),
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
          backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
        ):null,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      AppConstants.mediaAutoDownload,
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.textPrimaryColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      AppConstants.whenUsingMobileData,
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.textPrimaryColor,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600),
                    ),
                    trailing: SvgPicture.asset(
                        controller.openMobileData ? arrowUp : arrowDown,package: package,),
                    onTap: () {
                      controller.openMobile();
                    },
                  ),
                  Visibility(
                    visible: controller.openMobileData,
                    child: Column(
                      children: [
                        mediaItem(Constants.photo, controller.autoDownloadMobilePhoto, controller.mobile),
                        mediaItem(Constants.video, controller.autoDownloadMobileVideo, controller.mobile),
                        mediaItem(Constants.audio, controller.autoDownloadMobileAudio, controller.mobile),
                        mediaItem(Constants.document, controller.autoDownloadMobileDocument, controller.mobile),
                      ],
                    )//buildMediaTypeList(controller.mobile),
                  ),
                  ListTile(
                    title: Text(
                      AppConstants.whenUsingWifiData,
                      style: TextStyle(
                          color: MirrorflyUikit.getTheme?.textPrimaryColor,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600),
                    ),
                    trailing: SvgPicture.asset(
                        controller.openWifiData ? arrowUp : arrowDown,package: package,),
                    onTap: () {
                      controller.openWifi();
                    },
                  ),
                  Visibility(
                    visible: controller.openWifiData,
                      child: Column(
                        children: [
                          mediaItem(Constants.photo, controller.autoDownloadWifiPhoto, controller.wifi),
                          mediaItem(Constants.video, controller.autoDownloadWifiVideo, controller.wifi),
                          mediaItem(Constants.audio, controller.autoDownloadWifiAudio, controller.wifi),
                          mediaItem(Constants.document, controller.autoDownloadWifiDocument, controller.wifi),
                        ],
                      )//buildMediaTypeList(controller.wifi),
                  ),
                ],
              );
            }),
          ),
        ));
  }

  String getItemTitle(String item){
    switch (item) {
      case Constants.photo:
        return AppConstants.autoDownloadPhoto;
      case Constants.audio:
        return AppConstants.autoDownloadAudio;
      case Constants.video:
        return AppConstants.autoDownloadVideo;
      case Constants.document:
        return AppConstants.autoDownloadDocument;
      default: return Constants.emptyString;
    }
  }

  Widget mediaItem(String item, bool on, String type) {
    return Padding(
          padding: const EdgeInsets.only(
              left: 15.0, right: 5, bottom: 5),
          child: InkWell(
            child: Row(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(getItemTitle(item),
                          style: TextStyle(
                              color: MirrorflyUikit.getTheme?.textPrimaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: on ? Icon(Icons.check_circle_rounded, color: MirrorflyUikit.getTheme?.primaryColor, size: 20,) :
                  const Icon(Icons.check_circle_rounded, color: Colors.grey, size: 20,),
                ),
              ],
            ),
            onTap: () {
              controller.onClick(type,item);
            },
          ),
        );
  }
}
