import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../common/app_localizations.dart';
import '../../data/utils.dart';
import 'package:mirrorfly_plugin/mirrorfly_view.dart';

import '../../app_style_config.dart';
import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../data/session_management.dart';
import '../../extensions/extensions.dart';
import '../call_utils.dart';
import '../call_widgets.dart';
import 'join_call_controller.dart';

class JoinCallPreviewView extends NavViewStateful<JoinCallController> {
  const JoinCallPreviewView({super.key});

  @override
  JoinCallController createController({String? tag}) =>
      Get.put(JoinCallController());

  @override void onDispose() {
    controller.disposePreview();
    super.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: AppStyleConfig.joinCallPreviewPageStyle
              .backgroundDecoration,
          child: Column(
            children: [
              Stack(
                children: [
                  IconButton(onPressed: () {
                    NavUtils.back();
                  },
                      icon: const Icon(Icons.arrow_back, color: Colors.white)),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 40.0, left: 20, right: 20, bottom: 8),
                    child: Center(
                      child: Obx(() {
                        return FutureBuilder(future: CallUtils.getCallersName(
                            controller.users, false),
                            builder: (ctx, snap) {
                              return Text(
                                snap.hasData && snap.data != null &&
                                    snap.data!.isNotEmpty
                                    ? snap.data!
                                    : getTranslated("noOneHere"),
                                style: AppStyleConfig.joinCallPreviewPageStyle
                                    .callerNameTextStyle,
                                overflow: TextOverflow.ellipsis,);
                            });
                      }),
                    ),
                  ),
                ],
              ),
              Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      controller.users.length > 3 ? 4 : controller.users
                          .length, (index) =>
                  (index == 3) ? Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ProfileTextImage(
                      text: "+${(controller.users.length) - 3}",
                      radius: 45 / 2,
                      bgColor: Colors.white,
                      fontColor: const Color(0xff12233E),
                    ),
                  ) : FutureBuilder(future: getProfileDetails(
                      controller.users[index]!), builder: (ctx, snap) {
                    return snap.hasData && snap.data != null ? Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: buildProfileImage(snap.data!, size: 45),
                    ) : const Offstage();
                  })),
                );
              }),
              const Spacer(),
              Obx(() {
                return controller.subscribeSuccess.value ? const Offstage() :
                Text(controller.displayStatus,style: AppStyleConfig.joinCallPreviewPageStyle
                  .callerNameTextStyle,
                  overflow: TextOverflow.ellipsis,);
              }),
              const Spacer(),
              Container(
                height: 170,
                width: 150,
                margin: const EdgeInsets.all(40),
                child: MirrorFlyView(
                  userJid: SessionManagement.getUserJID().checkNull(),
                  viewBgColor: AppColors.callerBackground,
                ).setBorderRadius(const BorderRadius.all(Radius.circular(15))),
              ),
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      controller.muted.value
                          ? FloatingActionButton(
                        shape: AppStyleConfig.joinCallPreviewPageStyle
                            .actionButtonsStyle.shape,
                        heroTag: "mute",
                        elevation: 0,
                        backgroundColor: AppStyleConfig.joinCallPreviewPageStyle
                            .actionButtonsStyle.activeBgColor,
                        //Colors.white,
                        onPressed: () => controller.muteAudio(),
                        child: SvgPicture.asset(
                          muteActive,
                          package: package,colorFilter: ColorFilter.mode(
                              AppStyleConfig.joinCallPreviewPageStyle
                                  .actionButtonsStyle.activeIconColor,
                              BlendMode.srcIn),
                        ),
                      )
                          : FloatingActionButton(
                        shape: AppStyleConfig.joinCallPreviewPageStyle
                            .actionButtonsStyle.shape,
                        heroTag: "mute",
                        elevation: 0,
                        backgroundColor: AppStyleConfig.joinCallPreviewPageStyle
                            .actionButtonsStyle.inactiveBgColor,
                        //Colors.white.withOpacity(0.3),
                        onPressed: () => controller.muteAudio(),
                        child: SvgPicture.asset(
                          muteInactive,
                          package: package,colorFilter: ColorFilter.mode(
                              AppStyleConfig.joinCallPreviewPageStyle
                                  .actionButtonsStyle.inactiveIconColor,
                              BlendMode.srcIn),
                        ),
                      ),
                      /*if(controller.callType.value == CallType.video && !controller.videoMuted.value)...[
                        FloatingActionButton(
                          shape: AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.shape,
                          heroTag: "switchCamera",
                          elevation: 0,
                          backgroundColor: controller.cameraSwitch.value ? AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeBgColor : AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveBgColor,
                          // backgroundColor: controller.cameraSwitch.value ? Colors.white : Colors.white.withOpacity(0.3),
                          onPressed: () => controller.switchCamera(),
                          child: controller.cameraSwitch.value
                              ? SvgPicture.asset(cameraSwitchActive,package: package,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn),)
                              : SvgPicture.asset(cameraSwitchInactive,package: package,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),),
                        ),
                      ],*/
                      const SizedBox(width: 15,),
                      FloatingActionButton(
                        shape: AppStyleConfig.joinCallPreviewPageStyle
                            .actionButtonsStyle.shape,
                        heroTag: "video",
                        elevation: 0,
                        backgroundColor: controller.videoMuted.value
                            ? AppStyleConfig.joinCallPreviewPageStyle
                            .actionButtonsStyle.activeBgColor
                            : AppStyleConfig.joinCallPreviewPageStyle
                            .actionButtonsStyle.inactiveBgColor,
                        onPressed: () => controller.videoMute(),
                        child: controller.videoMuted.value ?
                        SvgPicture.asset(videoInactive,
                          package: package,colorFilter: ColorFilter.mode(
                              AppStyleConfig.joinCallPreviewPageStyle
                                  .actionButtonsStyle.activeIconColor,
                              BlendMode.srcIn),)
                            : SvgPicture.asset(
                          videoActive, package: package,colorFilter: ColorFilter.mode(
                            AppStyleConfig.joinCallPreviewPageStyle
                                .actionButtonsStyle.inactiveIconColor,
                            BlendMode.srcIn),),
                      ),
                      /*FloatingActionButton(
                        shape: AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.shape,
                        heroTag: "speaker",
                        elevation: 0,
                        backgroundColor:
                        controller.audioOutputType.value == AudioDeviceType.receiver
                            ? AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveBgColor//Colors.white.withOpacity(0.3)
                            : AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeBgColor,//Colors.white,
                        onPressed: () => controller.changeSpeaker(),
                        child: controller.audioOutputType.value == AudioDeviceType.receiver
                            ? SvgPicture.asset(speakerInactive,package: package,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.inactiveIconColor, BlendMode.srcIn),)
                            : controller.audioOutputType.value == AudioDeviceType.speaker
                            ? SvgPicture.asset(speakerActive,package: package,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                            : controller.audioOutputType.value == AudioDeviceType.bluetooth
                            ? SvgPicture.asset(speakerBluetooth,package: package,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                            : controller.audioOutputType.value == AudioDeviceType.headset
                            ? SvgPicture.asset(speakerHeadset,package: package,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn))
                            : SvgPicture.asset(speakerActive,package: package,colorFilter: ColorFilter.mode(AppStyleConfig.joinCallPreviewPageStyle.actionButtonsStyle.activeIconColor, BlendMode.srcIn)),
                      ),*/
                    ],
                  ),
                );
              }),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                  child: Obx(() {
                    return ElevatedButton(
                      style: AppStyleConfig.joinCallPreviewPageStyle
                          .joinCallButtonStyle,
                      onPressed: controller.subscribeSuccess.value ? () {
                        controller.joinCall();
                      } : null,
                      child: Text(getTranslated("join_now")),
                    );
                  })),
            ],
          ),
        ),
      ),
    );
  }
}
