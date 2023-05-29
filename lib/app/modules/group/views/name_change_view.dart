
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/group/controllers/group_info_controller.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';

class NameChangeView extends StatefulWidget {
  const NameChangeView({Key? key,this.enableAppBar=true}) : super(key: key);
  final bool enableAppBar;
  @override
  State<NameChangeView> createState() => _NameChangeViewState();
}

class _NameChangeViewState extends State<NameChangeView> {
  final controller = Get.find<GroupInfoController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
      appBar: widget.enableAppBar ? AppBar(
        automaticallyImplyLeading: true,
        title: Text('Enter New Name', style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              style:
                                  TextStyle(fontSize: 20, fontWeight: FontWeight.normal,overflow: TextOverflow.visible,color: MirrorflyUikit.getTheme?.textPrimaryColor,),
                              onChanged: (_) => controller.onChanged(),
                              maxLength: 121,
                              maxLines: 1,
                              focusNode: controller.focusNode,
                              controller: controller.nameController,
                              cursorColor: MirrorflyUikit.getTheme?.primaryColor,
                              decoration: const InputDecoration(border: InputBorder.none,counterText:"" ),
                            ),
                          ),
                          Container(
                            height: 50,
                            padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Obx(
                                  ()=> Text(
                            controller.count.toString(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal,color: MirrorflyUikit.getTheme?.textSecondaryColor,),
                          ),
                                ),
                              )),
                          /*IconButton(
                              onPressed: () {
                                if (!controller.showEmoji.value) {
                                  FocusScope.of(context).unfocus();
                                  controller.focusNode.canRequestFocus = false;
                                }
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  controller.showEmoji(!controller.showEmoji.value);
                                });
                              },
                              icon: SvgPicture.asset(smileIcon,package: package,)),*/
                          Obx(() {
                            return IconButton(
                                onPressed: () {
                                  controller.showHideEmoji(context);
                                },
                                icon: controller.showEmoji.value ? Icon(
                                  Icons.keyboard, color: MirrorflyUikit.getTheme?.textPrimaryColor,) : SvgPicture
                                    .asset(smileIcon, package: package, color: MirrorflyUikit.getTheme?.textPrimaryColor,));
                          })
                        ],
                      ),
                      const Divider(height: 1, color: dividerColor, thickness: 1,),
                    ],
                  ),
                ),

              ),
              // const Divider(thickness: 1, color: Colors.grey, height: 1,),
              /*IntrinsicHeight(
                child: Row(children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if(controller.nameController.text.trim().isNotEmpty) {
                          // Get.back(result: controller.nameController.text
                          //     .trim().toString());
                          Navigator.pop(context, controller.nameController.text
                              .trim().toString());
                        }else{
                          toToast("Name cannot be empty");
                        }
                      },
                      child: const Text(
                        "OK",
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
                    ),
                  ),
                ]),
              ),*/
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MaterialStateColor.resolveWith(
                                (states) => MirrorflyUikit.getTheme!.secondaryColor),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: Text(
                      "CANCEL",
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
                      if(controller.nameController.text.trim().isNotEmpty) {
                        // Get.back(result: controller.nameController.text
                        //     .trim().toString());
                        Navigator.pop(context, controller.nameController.text
                            .trim().toString());
                      }else{
                        toToast("Name cannot be empty");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MaterialStateColor.resolveWith(
                                (states) => MirrorflyUikit.getTheme!.secondaryColor),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: Text(
                      "OK",
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
          textController: controller.nameController,
            onEmojiSelected : (cat, emoji)=>controller.onChanged()
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
