import 'dart:io';

import 'package:better_video_player/better_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/widgets.dart';
import '../../../model/user_list_model.dart';
import '../controllers/media_preview_controller.dart';


class MediaPreviewView extends StatefulWidget {
  const MediaPreviewView(
      {Key? key, required this.filePath, required this.userName, required this.profile, required this.caption, required this.showAdd, this.isFromGalleryPicker = false})
      : super(key: key);
  final List filePath;
  final String userName;
  final Profile profile;
  final String caption;
  final bool showAdd;
  final bool isFromGalleryPicker;

  @override
  State<MediaPreviewView> createState() => _MediaPreviewViewState();
}

class _MediaPreviewViewState extends State<MediaPreviewView> {
  var controller = Get.put(MediaPreviewController());

  @override
  void initState() {
    controller.init(
        widget.filePath, widget.userName, widget.profile, widget.caption,
        widget.showAdd, widget.isFromGalleryPicker);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<MediaPreviewController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          leadingWidth: 80,
          leading: InkWell(
            onTap: () {
              // Get.back();
              Navigator.pop(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 10,
                ),
                const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 10,
                ),
                Obx(() {
                  return ImageNetwork(
                    url: (controller.profile.value.image).checkNull(),
                    width: 35,
                    height: 35,
                    clipOval: true,
                    errorWidget: controller.profile.value.isGroupProfile ??
                        false
                        ? ClipOval(
                      child: Image.asset(
                        groupImg, package: package,
                        height: 35,
                        width: 35,
                        fit: BoxFit.cover,
                      ),
                    )
                        : ProfileTextImage(
                      text: controller.profile.value.getName() /*controller.profile?.name.checkNull().isEmpty
                              ? controller.profile.nickName.checkNull().isEmpty
                                  ? controller.profile.mobileNumber.checkNull()
                                  : controller.profile.nickName.checkNull()
                              : controller.profile.name.checkNull()*/,
                      radius: 18,
                    ),
                    isGroup: (controller.profile.value.isGroupProfile)
                        .checkNull(),
                    blocked: (controller.profile.value.isBlockedMe)
                        .checkNull() ||
                        controller.profile.value.isAdminBlocked.checkNull(),
                    unknown: (!controller.profile.value.isItSavedContact
                        .checkNull() ||
                        controller.profile.value.isDeletedContact()),
                  );
                }),
              ],
            ),
          ),
          actions: [
            Obx(() {
              return controller.filePath.length > 1
                  ? IconButton(
                  onPressed: () {
                    controller.deleteMedia();
                  },
                  icon: SvgPicture.asset(deleteBinWhite, package: package,))
                  : const SizedBox.shrink();
            })
          ],
        ),
        body: WillPopScope(
          onWillPop: () {
            Navigator.pop(context,"back");
            // Get.back(result: "back");
            return Future.value(false);
          },
          child: SafeArea(
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              color: Colors.black,
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      return controller.filePath.isEmpty
                      /// no images selected
                          ? Container(
                        height: double.infinity,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: 8,
                              child: const Icon(
                                Icons.image_outlined,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                            const SizedBox(height: 50),
                            const Text(
                              'No Media selected',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70),
                            )
                          ],
                        ),
                      )

                      /// selected media
                          : PageView(
                        controller: controller.pageViewController,
                        onPageChanged: onMediaPreviewPageChanged,
                        children: [
                          ...controller.filePath.map((data) {
                            /// show image
                            if (data.type == 'image') {
                              return Center(
                                  child: PhotoView(
                                    imageProvider: FileImage(File(data.path)),
                                    // Contained = the smallest possible size to fit one dimension of the screen
                                    minScale:
                                    PhotoViewComputedScale.contained * 1,
                                    // Covered = the smallest possible size to fit the whole screen
                                    maxScale:
                                    PhotoViewComputedScale.covered * 2,
                                    enableRotation: true,
                                    basePosition: Alignment.center,
                                    // Set the background color to the "classic white"
                                    backgroundDecoration: const BoxDecoration(
                                        color: Colors.transparent),
                                    loadingBuilder: (context, event) =>
                                        Center(
                                          child: CircularProgressIndicator(
                                            color: MirrorflyUikit.getTheme
                                                ?.primaryColor,),
                                        ),
                                  )
                                // PhotoView.customChild(
                                //   enablePanAlways: true,
                                //   maxScale: 2.0,
                                //   minScale: 1.0,
                                //   child: Image.file(File(data.path)),
                                // ),
                              );
                            }

                            /// show video
                            else {
                              return AspectRatio(
                                aspectRatio: 16.0 / 9.0,
                                child: BetterVideoPlayer(
                                  configuration:
                                  const BetterVideoPlayerConfiguration(
                                    looping: false,
                                    autoPlay: false,
                                    allowedScreenSleep: false,
                                    autoPlayWhenResume: false,
                                  ),
                                  controller:
                                  BetterVideoPlayerController(),
                                  dataSource: BetterVideoPlayerDataSource(
                                    BetterVideoPlayerDataSourceType.file,
                                    data.path,
                                  ),
                                ),
                              );
                            }
                          })
                        ],
                      );
                    }),
                  ),
                  Container(
                    color: Colors.black38,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Obx(() {
                                    return controller.isFocused.value ||
                                        controller.showEmoji.value ||
                                        !controller.showAdd
                                        ? InkWell(
                                        onTap: () {
                                          if (!controller.showEmoji.value) {
                                            controller.captionFocusNode
                                                .unfocus();
                                          }
                                          Future.delayed(
                                              const Duration(
                                                  milliseconds: 100), () {
                                            controller.showEmoji(!controller
                                                .showEmoji.value);
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          smileIcon, package: package,color: previewTextColor,))
                                        : controller.filePath.length < 10 &&
                                        controller.showAdd
                                        ? InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        // Get.back();
                                      },
                                      child: SvgPicture.asset(
                                        previewAddImg, package: package,),
                                    )
                                        : const SizedBox.shrink();
                                  }),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    color: previewTextColor,
                                    width: 1,
                                    height: 25,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Focus(
                                      onFocusChange: (isFocus) =>
                                          controller.isFocused(isFocus),
                                      child: TextFormField(
                                        focusNode: controller.captionFocusNode,
                                        controller: controller.caption,
                                        onChanged: controller.onCaptionTyped,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        maxLines: 6,
                                        minLines: 1,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Add Caption...",
                                          hintStyle: TextStyle(
                                            color: previewTextColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  FloatingActionButton(
                                    backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
                                    onPressed: () { controller.sendMedia(context); },
                                    child: Center(child: Icon(Icons.send,color: MirrorflyUikit.getTheme?.colorOnPrimary,))/*SvgPicture.asset(
                                      imgSendIcon, package: package,color: MirrorflyUikit.getTheme?.primaryColor,),*/
                                  ),
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
                                    Icons.keyboard_arrow_right,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  Text(
                                    controller.userName,
                                    style: const TextStyle(
                                        color: previewTextColor, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Obx(() {
                          return controller.filePath.length > 1
                              ? SizedBox(
                            height: 45,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.filePath.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Obx(() {
                                        return InkWell(
                                          onTap: () {
                                            controller
                                                .currentPageIndex(index);
                                            controller.pageViewController
                                                .animateToPage(index,
                                                duration:
                                                const Duration(
                                                    milliseconds:
                                                    1),
                                                curve: Curves.easeIn);
                                          },
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: controller
                                                .currentPageIndex
                                                .value ==
                                                index
                                                ? BoxDecoration(
                                                border: Border.all(
                                                  color: MirrorflyUikit.getTheme!.primaryColor,
                                                  width: 1,
                                                ))
                                                : null,
                                            margin: const EdgeInsets
                                                .symmetric(horizontal: 1),
                                            child: Image.memory(controller
                                                .filePath[index]
                                                .thumbnail),
                                          ),
                                        );
                                      }),
                                      controller.filePath[index].type ==
                                          "image"
                                          ? const SizedBox.shrink()
                                          : Positioned(
                                          bottom: 4,
                                          left: 4,
                                          child: SvgPicture.asset(
                                            videoCamera, package: package,
                                            width: 5,
                                            height: 5,
                                          )),
                                    ],
                                  );
                                }),
                          )
                              : const SizedBox.shrink();
                        }),
                        emojiLayout(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void onMediaPreviewPageChanged(int value) {
    debugPrint(value.toString());
    // final deBouncer = DeBouncer(milliseconds: 200);
    // deBouncer.run(() {
    controller.currentPageIndex(value);
    controller.caption.text = controller.captionMessage[value];
    controller.captionFocusNode.unfocus();
    // });
    // Future.delayed(const Duration(milliseconds: 200), (){
    //   controller.currentPageIndex(value);
    //   controller.caption.text = controller.captionMessage[value];
    // });
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return EmojiLayout(
            textController: controller.caption,
            onEmojiSelected: (cat, emoji) => controller.onChanged());
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}