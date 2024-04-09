import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/main_controller.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../controllers/image_view_controller.dart';

class ImageViewView extends StatefulWidget {
  const ImageViewView(
      {super.key,
      required this.imageName,
      this.imagePath,
      this.imageUrl,
      this.enableAppBar = true});

  final String imageName;
  final String? imagePath;
  final String? imageUrl;
  final bool enableAppBar;

  @override
  State<ImageViewView> createState() => _ImageViewViewState();
}

class _ImageViewViewState extends State<ImageViewView> {
  var controller = Get.put(ImageViewController());

  @override
  void initState() {
    controller.init(
        imageName: widget.imageName,
        imagePath: widget.imagePath,
        imageUrl: widget.imageUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var main = Get.find<MainController>();
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: widget.enableAppBar
          ? AppBar(
              iconTheme:
                  IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
              backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
              title: Text(
                controller.imageName.value,
                style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
                overflow: TextOverflow.clip,
              ),
              centerTitle: false,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() {
            return controller.imagePath.value.isNotEmpty
                ? PhotoView(
                    imageProvider: FileImage(File(controller.imagePath.value)),
                    // Contained = the smallest possible size to fit one dimension of the screen
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    // Covered = the smallest possible size to fit the whole screen
                    maxScale: PhotoViewComputedScale.covered * 2,
                    enableRotation: false,
                    // Set the background color to the "classic white"
                    backgroundDecoration: BoxDecoration(
                      color: MirrorflyUikit.getTheme?.scaffoldColor,
                    ),
                    loadingBuilder: (context, event) => Center(
                      child: CircularProgressIndicator(
                        color: MirrorflyUikit.getTheme?.primaryColor,
                      ),
                    ),
                  )
                : controller.imageUrl.value.isNotEmpty
                    ? PhotoView(
                        imageProvider: CachedNetworkImageProvider(
                            controller.imageUrl.value,
                            headers: {
                              "Authorization": main.currentAuthToken.value
                            }),
                        // Contained = the smallest possible size to fit one dimension of the screen
                        minScale: PhotoViewComputedScale.contained * 0.8,
                        // Covered = the smallest possible size to fit the whole screen
                        maxScale: PhotoViewComputedScale.covered * 2,
                        enableRotation: false,
                        // Set the background color to the "classic white"
                        backgroundDecoration: BoxDecoration(
                          color: MirrorflyUikit.getTheme?.scaffoldColor,
                        ),
                        loadingBuilder: (context, event) => Center(
                          child: CircularProgressIndicator(
                            color: MirrorflyUikit.getTheme?.primaryColor,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(AppConstants.unableToLoad),
                      );
          }),
        ),
      ),
    );
  }
}
