import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/profile/controllers/status_controller.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';

class AddStatusView extends StatefulWidget {
  const AddStatusView({Key? key, required this.status,this.enableAppBar=true}) : super(key: key);
  final bool enableAppBar;
  final String status;
  @override
  State<AddStatusView> createState() => _AddStatusViewState();
}

class _AddStatusViewState extends State<AddStatusView> {
  // var controller = Get.find(StatusListController());
  final StatusListController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.selectedStatus.value = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: widget.enableAppBar ? AppBar(
        automaticallyImplyLeading: true,
        title: Text(AppConstants.addNewStatus, style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
        iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
        backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
      ) : null,
      body: WillPopScope(
        onWillPop: () {
          if (controller.showEmoji.value) {
            controller.showEmoji(false);
          } else {
            // Get.back();
            Navigator.pop(context);
          }
          return Future.value(false);
        },
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
                        onChanged: (_) => controller.onChanged(),
                        autofocus: true,
                        focusNode: controller.focusNode,
                        maxLength: 139,
                        maxLines: 1,
                        cursorColor: MirrorflyUikit.getTheme?.primaryColor,
                        keyboardAppearance: MirrorflyUikit.theme == "dark" ? Brightness.dark : Brightness.light,
                        controller: controller.addStatusController,
                        decoration: const InputDecoration(
                            border: InputBorder.none, counterText: Constants.emptyString),
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
                            if (controller.showEmoji.value) {
                              controller.showEmoji(false);
                              controller.focusNode.requestFocus();
                              return;
                            }
                            if (!controller.showEmoji.value) {
                              controller.focusNode.unfocus();
                            }
                            Future.delayed(
                                const Duration(milliseconds: 500), () {
                              controller.showEmoji(!controller.showEmoji.value);
                            });
                          },
                          icon: controller.showEmoji.value ? Icon(Icons.keyboard, color: MirrorflyUikit.getTheme?.textSecondaryColor, ) : SvgPicture.asset(smileIcon,package: package, colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.textSecondaryColor, BlendMode.srcIn),));
                    })
                  ],
                ),
              ),
            ),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>  Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: MirrorflyUikit.getTheme?.secondaryColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero)),
                  child: Text(
                    AppConstants.cancel.toUpperCase(),
                    style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor, fontSize: 16.0),
                  ),
                ),
              ),
              const AppDivider(),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.validateAndFinish(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:  MirrorflyUikit.getTheme?.secondaryColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero)),
                  child: Text(
                    AppConstants.ok.toUpperCase(),
                    style: TextStyle(color:  MirrorflyUikit.getTheme?.textPrimaryColor, fontSize: 16.0),
                  ),
                ),
              ),
            ]),
            emojiLayout(),
          ],
        ),
      ),
    );
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return EmojiLayout(
            textController: controller.addStatusController,
            onBackspacePressed: () => controller.onChanged(),
            onEmojiSelected: (cat, emoji) => controller.onChanged());
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
