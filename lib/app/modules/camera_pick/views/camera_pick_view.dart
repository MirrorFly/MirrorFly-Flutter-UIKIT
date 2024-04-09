import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../controllers/camera_pick_controller.dart';

class CameraPickView extends StatelessWidget {
  CameraPickView({super.key});
  final controller = Get.put(CameraPickController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                return controller.cameraInitialized.value
                    ? Stack(alignment: Alignment.topCenter, children: [
                        Listener(
                          onPointerDown: (_) => controller.pointers++,
                          onPointerUp: (_) => controller.pointers--,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: CameraPreview(
                              controller.cameraController!,
                              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onScaleStart: controller.handleScaleStart,
                                  onScaleUpdate: controller.handleScaleUpdate,
                                  onTapDown: (TapDownDetails details) => controller.onViewFinderTap(details, constraints),
                                );
                              }),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                // Get.back();
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: controller.isRecording.value
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            height: 12,
                                            width: 12,
                                            child: CircularProgressIndicator(
                                                backgroundColor: Colors.red,
                                                value: controller.progress / controller.maxVideoDuration,
                                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            controller.timeString,
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        )
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            )
                          ],
                        ),
                  Positioned(
                    bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Obx(() {
                                  return IconButton(
                                    onPressed: () {
                                      controller.toggleFlash();
                                    },
                                    icon: controller.flash.value
                                        ? const Icon(
                                      Icons.flash_on,
                                      size: 30,
                                    )
                                        : const Icon(
                                      Icons.flash_off,
                                      size: 30,
                                    ),
                                    color: Colors.white,
                                  );
                                }),
                                Obx(() {
                                  return GestureDetector(
                                    onLongPress: () async {
                                      controller.startVideoRecording(context);
                                    },
                                    onLongPressUp: () async {
                                      // to preview
                                      controller.stopRecord(context);
                                    },
                                    onTap: () {
                                      if (!controller.isRecording.value) {
                                        controller.takePhoto(context);
                                      }
                                    },
                                    child: controller.isRecording.value
                                        ? const Icon(
                                      Icons.radio_button_on,
                                      color: Colors.red,
                                      size: 80,
                                    )
                                        : const Icon(
                                      Icons.panorama_fish_eye,
                                      color: Colors.white,
                                      size: 70,
                                    ),
                                  );
                                }),
                                IconButton(
                                    onPressed: () async {
                                      if (!controller.isRecording.value) {
                                        controller.toggleCamera();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.flip_camera_ios,
                                      color: Colors.white,
                                      size: 30,
                                    ))
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              AppConstants.holdToRecord,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                  ),
                ])
                    : Center(
                        child: CircularProgressIndicator(
                          color: MirrorflyUikit.getTheme?.primaryColor,
                        ),
                      );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
