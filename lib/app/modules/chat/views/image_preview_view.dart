import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/AppConstants.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/controllers/image_preview_controller.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';


class ImagePreviewView extends GetView<ImagePreviewController> {
  const ImagePreviewView({super.key,this.enableAppBar=true});
  final bool enableAppBar;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: enableAppBar ? AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
        /*actions: [
          IconButton(
              icon: const Icon(
                Icons.delete_outline_outlined,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.crop_rotate,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.title,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.edit,
                size: 27,
              ),
              onPressed: () {}),
        ],*/
      ) : null,
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: Stack(
            children: [
              Obx(() {
                return controller.filePath.value.isNotEmpty ? SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height - 150,
                  child: PhotoView(
                    imageProvider: FileImage(File(controller.filePath.value)),
                    // Contained = the smallest possible size to fit one dimension of the screen
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    // Covered = the smallest possible size to fit the whole screen
                    maxScale: PhotoViewComputedScale.covered * 2,
                    enableRotation: true,
                    // Set the background color to the "classic white"
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent
                    ),
                    loadingBuilder: (context, event) =>
                        Center(
                          child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.primaryColor,),
                        ),
                  ),
                ) : Center(child: CircularProgressIndicator(color: MirrorflyUikit.getTheme?.primaryColor,));
              }),
              Positioned(
                bottom: 0,
                child: Container(
                  color: Colors.black38,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  padding: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 15),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                              size: 27,
                            ),
                            const SizedBox(width: 5,),
                            const Padding(
                              padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                              child: VerticalDivider(
                                color: Colors.white,
                                thickness: 1,
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Expanded(
                              child: TextFormField(
                                controller: controller.caption,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                maxLines: 6,
                                minLines: 1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: AppConstants.addCaption,
                                  hintStyle: const TextStyle(
                                    color: Colors.white,
                                  ),),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  controller.sendImageMessage(context);
                                  // controller.sendMessage(controller.profile);
                                },
                                child: SvgPicture.asset(
                                    imgSendIcon,package: package,)),
                          ],
                        ),
                        // SvgPicture.asset(
                        //   rightArrow,
                        //   width: 18,
                        //   height: 18,
                        //   fit: BoxFit.contain,
                        //   color: Colors.white,
                        // ),
                        Row(
                          children: [
                            const Icon(
                              Icons.chevron_right_sharp,
                              color: Colors.white,
                              size: 27,
                            ),
                            Text(controller.userName, style: const TextStyle(
                                color: Colors.white),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
