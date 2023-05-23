import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../media_preview/views/media_preview_view.dart';
import '../controllers/gallery_picker_controller.dart';
import '../src/presentation/pages/gallery_media_picker.dart';

class GalleryPickerView extends StatefulWidget {
  const GalleryPickerView({Key? key, required this.senderJid, required this.caption}) : super(key: key);

  final String senderJid;
  final String caption;

  @override
  State<GalleryPickerView> createState() => _GalleryPickerViewState();
}

class _GalleryPickerViewState extends State<GalleryPickerView> {
  final controller = Get.put(GalleryPickerController());

  @override
  void initState() {
    controller.init(widget.senderJid, widget.caption);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<GalleryPickerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: AppBar(
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
        actionsIconTheme: IconThemeData(
            color: MirrorflyUikit.getTheme?.colorOnAppbar),
        iconTheme: IconThemeData(
            color: MirrorflyUikit.getTheme?.colorOnAppbar),
        title: Row(
          children: [
            Obx(() {
              return Text('Send to ${controller.profile.value.getName()}', style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),);
            }),
          ],
        ),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Column(
          children: [
            Expanded(
              child: GalleryMediaPicker(
                childAspectRatio: 1,
                crossAxisCount: 3,
                thumbnailQuality: 200,
                thumbnailBoxFix: BoxFit.cover,
                singlePick: false,
                gridViewBackgroundColor: MirrorflyUikit.getTheme!.scaffoldColor,
                imageBackgroundColor: MirrorflyUikit.getTheme!.scaffoldColor,
                maxPickImages: controller.maxPickImages,
                appBarHeight: 60,
                selectedBackgroundColor: Colors.black,
                selectedCheckColor: MirrorflyUikit.getTheme!.primaryColor,
                selectedCheckBackgroundColor: Colors.white,
                pathList: (paths) {
                  debugPrint("file selected");
                  controller.addFile(paths);
                },
                appBarColor: MirrorflyUikit.getTheme!.scaffoldColor,
                appBarIconColor: MirrorflyUikit.getTheme?.textPrimaryColor,
                appBarTextColor: MirrorflyUikit.getTheme!.textPrimaryColor,
                albumBackGroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
                albumTextColor: MirrorflyUikit.getTheme!.textPrimaryColor,
                appBarLeadingWidget: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15, bottom: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Obx(() {
                          return Text("${controller.pickedFile.length} / ${controller.maxPickImages}", style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),);
                        }),

                        const SizedBox(width: 20,),
                        GestureDetector(
                          onTap: () async {
                            List<String> mediaPath = [];
                            // media.pickedFile.map((p) {
                            //   setState(() {
                            //     mediaPath.add(p.path);
                            //   });
                            // }).toString();
                            if (controller.pickedFile.isNotEmpty) {
                              // await Share.shareFiles(mediaPath);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (con) =>
                                          MediaPreviewView(
                                            filePath: controller.pickedFile,
                                            userName: controller.profile.value.getName(),
                                            profile: controller.profile.value,
                                            caption: controller.textMessage.value,
                                            showAdd: false,
                                            isFromGalleryPicker: true,
                                          ))).then((value) {
                                value != null ? Navigator.pop(context) : null;
                              });
                              /*Get.toNamed(Routes.mediaPreview, arguments: {
                                    "filePath": controller.pickedFile,
                                    "userName": controller.userName,
                                    'profile': controller.profile,
                                    'caption': controller.textMessage
                                  })?.then((value) {
                                    value != null ? Get.back() : null;

                                  });*/
                            } else {
                              // Get.back();
                              Navigator.pop(context);
                            }
                            mediaPath.clear();
                          },
                          child: Container(
                              height: 30,
                              width: 55,
                              decoration: BoxDecoration(
                                color: MirrorflyUikit.getTheme?.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: MirrorflyUikit.getTheme!.primaryColor, width: 1.5),
                              ),
                              child: Center(child: Text("Done", style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnPrimary),))
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
