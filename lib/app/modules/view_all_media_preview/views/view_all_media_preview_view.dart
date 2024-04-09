import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_plugin/message_params.dart';
import 'package:mirrorfly_uikit_plugin/app/common/extensions.dart';
import 'package:mirrorfly_uikit_plugin/app/model/chat_message_model.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../widgets/video_player_widget.dart';
import '../controllers/view_all_media_preview_controller.dart';

class ViewAllMediaPreviewView extends StatefulWidget {
  const ViewAllMediaPreviewView(
      {super.key,
      required this.images,
      required this.index,
      this.enableAppBar = true});
  final List<ChatMessageModel> images;
  final int index;
  final bool enableAppBar;

  @override
  State<ViewAllMediaPreviewView> createState() =>
      _ViewAllMediaPreviewViewState();
}

class _ViewAllMediaPreviewViewState extends State<ViewAllMediaPreviewView> {
  var controller = Get.put(ViewAllMediaPreviewController());

  @override
  void initState() {
    controller.init(widget.images, widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: widget.enableAppBar
          ? AppBar(
              backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
              actionsIconTheme: IconThemeData(
                  color: MirrorflyUikit.getTheme?.colorOnAppbar ?? iconColor),
              iconTheme: IconThemeData(
                  color: MirrorflyUikit.getTheme?.colorOnAppbar ?? iconColor),
              title: Obx(() {
                return Text(controller.title.value,
                    style: TextStyle(
                        color: MirrorflyUikit.getTheme?.colorOnAppbar));
              }),
              centerTitle: false,
              actions: [
                IconButton(
                    onPressed: () {
                      controller.shareMedia();
                    },
                    icon: SvgPicture.asset(
                      shareIcon,
                      package: package,
                      colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)
                    ))
              ],
            )
          : null,
      body: SafeArea(
        child: PageView(
          controller: controller.pageViewController,
          onPageChanged: controller.onMediaPreviewPageChanged,
          children: [
            ...controller.previewMediaList.where((p0) => p0.isMediaMessage() && checkFile(p0.mediaChatMessage!.mediaLocalStoragePath.value.checkNull())).map((data) {
              /// show image
              if (data.messageType.toLowerCase() == 'image') {
                return Center(
                  child: PhotoView(
                    imageProvider: FileImage(
                        File(data.mediaChatMessage!.mediaLocalStoragePath.value)),
                    // Contained = the smallest possible size to fit one dimension of the screen
                    minScale: PhotoViewComputedScale.contained * 1,
                    // Covered = the smallest possible size to fit the whole screen
                    maxScale: PhotoViewComputedScale.covered * 2,
                    enableRotation: true,
                    basePosition: Alignment.center,
                    // Set the background color to the "classic white"
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.transparent),
                    loadingBuilder: (context, event) => Center(
                      child: CircularProgressIndicator(
                        color: MirrorflyUikit.getTheme?.primaryColor,
                      ),
                    ),
                  ),
                );
              }
              /// show video
              else if(data.messageType == MessageType.video.value){
                return VideoPlayerWidget(
                  videoPath: data.mediaChatMessage?.mediaLocalStoragePath.value ?? "", videoTitle: data.mediaChatMessage?.mediaFileName ?? "Video",
                );
              } else {
                return Container(
                  color: const Color(0xff97A5C7),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(data.mediaChatMessage!.isAudioRecorded.checkNull() ? audioMic1 : headsetImg,height: 150,width: 150,
                        package: package,colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn)
                      ),
                      FloatingActionButton.small(
                        onPressed: (){
                          openDocument(data.mediaChatMessage!.mediaLocalStoragePath.value.checkNull());
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: buttonBgColor,
                        ),
                      )
                    ],
                  ),
                );
              }
            })
          ],
        ),
      ),
    );
  }
}
