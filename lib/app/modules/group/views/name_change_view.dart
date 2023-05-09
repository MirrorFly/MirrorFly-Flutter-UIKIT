
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/group/controllers/group_info_controller.dart';

import '../../../common/constants.dart';

class NameChangeView extends StatefulWidget {
  const NameChangeView({Key? key}) : super(key: key);

  @override
  State<NameChangeView> createState() => _NameChangeViewState();
}

class _NameChangeViewState extends State<NameChangeView> {
  final controller = Get.find<GroupInfoController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Enter New Name'),
      ),
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
                                  const TextStyle(fontSize: 20, fontWeight: FontWeight.normal,overflow: TextOverflow.visible),
                              onChanged: (_) => controller.onChanged(),
                              maxLength: 121,
                              maxLines: 1,
                              controller: controller.nameController,
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
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                          ),
                                ),
                              )),
                          IconButton(
                              onPressed: () {
                                if (!controller.showEmoji.value) {
                                  FocusScope.of(context).unfocus();
                                  controller.focusNode.canRequestFocus = false;
                                }
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  controller.showEmoji(!controller.showEmoji.value);
                                });
                              },
                              icon: SvgPicture.asset(smileIcon,package: package,))
                        ],
                      ),
                      const Divider(height: 1, color: dividerColor, thickness: 1,),
                    ],
                  ),
                ),

              ),

              const Divider(thickness: 1, color: Colors.grey, height: 1,),
              IntrinsicHeight(
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
              ),
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
