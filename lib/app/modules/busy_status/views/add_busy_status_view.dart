import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../controllers/busy_status_controller.dart';

class AddBusyStatusView extends StatefulWidget {
  const AddBusyStatusView({super.key, required String status,this.enableAppBar=true});
  final bool enableAppBar;
  @override
  State<AddBusyStatusView> createState() => _AddBusyStatusViewState();
}

class _AddBusyStatusViewState extends State<AddBusyStatusView> {
  final controller = Get.find<BusyStatusController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: widget.enableAppBar ? AppBar(
        automaticallyImplyLeading: true,
        title: Text(AppConstants.addBusyStatus, style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
        iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      ):null,
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (controller.showEmoji.value) {
            controller.showEmoji(false);
          } else {
            Get.back();
          }
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                              fontSize: 20,
                              color: MirrorflyUikit.getTheme?.textPrimaryColor,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.visible),
                          onChanged: (value) {
                            controller.onChanged();
                          },
                          maxLength: 139,
                          maxLines: 1,
                          autofocus: true,
                          focusNode: controller.focusNode,
                          controller: controller.addStatusController,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: MirrorflyUikit.getTheme!.textSecondaryColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: MirrorflyUikit.getTheme!.primaryColor),
                              ),
                              counterText: Constants.emptyString),
                          onTap: () {
                            if (controller.showEmoji.value) {
                              controller.showEmoji(false);
                            }
                          },
                        ),
                      ),
                      Container(
                          height: 50,
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Obx(
                                  () =>
                                  Text(
                                    controller.count.toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: MirrorflyUikit.getTheme?.textSecondaryColor,
                                        fontWeight: FontWeight.normal),
                                  ),
                            ),
                          )),
                      Obx(() {
                        return IconButton(
                            onPressed: () {
                              controller.showHideEmoji(context);
                            },
                            icon: controller.showEmoji.value ? Icon(
                              Icons.keyboard, color: MirrorflyUikit.getTheme?.textPrimaryColor,) : SvgPicture
                                .asset(smileIcon, package: package, colorFilter: ColorFilter.mode(MirrorflyUikit.getTheme!.textPrimaryColor, BlendMode.srcIn),));
                      })
                    ],
                  ),
                ),
              ),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.showEmoji.value) {
                        controller.showEmoji(false);
                      }
                      // Get.back();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MaterialStateColor.resolveWith(
                                (states) => MirrorflyUikit.getTheme!.secondaryColor),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: Text(
                      AppConstants.cancel.toUpperCase(),
                      style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor, fontSize: 16.0),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 0.2,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.showEmoji.value) {
                        controller.showEmoji(false);
                      }
                      controller.validateAndFinish(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MaterialStateColor.resolveWith(
                                (states) => MirrorflyUikit.getTheme!.secondaryColor),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: Text(
                      AppConstants.ok.toUpperCase(),
                      style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor, fontSize: 16.0),
                    ),
                  ),
                ),
              ]),
              emojiLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return EmojiLayout(
            textController: TextEditingController(),//controller.addStatusController,
            onBackspacePressed: () {
              controller.onEmojiBackPressed();
            },
            onEmojiSelected: (cat, emoji) => controller.onEmojiSelected(emoji));
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
