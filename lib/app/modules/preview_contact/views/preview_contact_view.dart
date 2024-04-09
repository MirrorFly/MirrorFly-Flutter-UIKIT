import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_constants.dart';
import 'package:mirrorfly_uikit_plugin/app/model/local_contact_model.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/widgets.dart';
import '../controllers/preview_contact_controller.dart';

class PreviewContactView extends StatefulWidget {
  const PreviewContactView({super.key, this.contactList, this.previewContactList, required this.from, this.contactName,this.enableAppBar=true});

  final List<LocalContact>? contactList;
  final List<String>? previewContactList;
  final String from;
  final String? contactName;
  final bool enableAppBar;

  @override
  State<PreviewContactView> createState() => _PreviewContactViewState();
}

class _PreviewContactViewState extends State<PreviewContactView> {
  final controller = Get.put(PreviewContactController());

  @override
  void initState() {
    controller.init(widget.contactList, widget.previewContactList, widget.from, widget.contactName);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<PreviewContactController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: widget.enableAppBar ? AppBar(
          iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
          backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
          title: controller.from == "contact_pick"
              ? Text(AppConstants.sendContacts, style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),)
              : Text(AppConstants.contactDetails, style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),),
        ):null,
        body: SafeArea(
          child: Stack(
            children: [
              Obx(() {
                return SizedBox(
                  height: double.infinity,
                  child: ListView.builder(
                      itemCount: controller.contactList.length,
                      // shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        // var parentIndex = index;
                        var contactItem = controller.contactList[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                              child: Row(
                                children: [
                                  ProfileTextImage(
                                    text: contactItem.userName,
                                    radius: 20,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text(
                                      contactItem.userName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const AppDivider(padding: EdgeInsets.symmetric(vertical: 10),),
                            ListView.builder(
                                itemCount: contactItem.contactNo.length,
                                physics: const ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder:
                                    (BuildContext context, int childIndex) {
                                  var phoneItem =
                                      contactItem.contactNo[childIndex];
                                  return ListTile(
                                    onTap: () {
                                      controller.changeStatus(phoneItem);
                                    },
                                    title: Text(
                                      phoneItem.mobNo,
                                      style: TextStyle(fontSize: 13, color: MirrorflyUikit.getTheme?.textPrimaryColor),
                                    ),
                                    subtitle: Text(
                                      phoneItem.mobNoType,
                                      style: TextStyle(fontSize: 12, color: MirrorflyUikit.getTheme?.textSecondaryColor),
                                    ),
                                    leading: Icon(
                                      Icons.phone,
                                      color: MirrorflyUikit.getTheme?.primaryColor,
                                      size: 20,
                                    ),
                                    trailing: Visibility(
                                      visible:
                                          contactItem.contactNo.length > 1 &&
                                              controller.from != "chat",
                                      child: Theme(
                                        data: ThemeData(
                                          unselectedWidgetColor: Colors.grey,
                                        ),
                                        child: Checkbox(
                                          activeColor: MirrorflyUikit.getTheme!.primaryColor,//Colors.white,
                                          checkColor: MirrorflyUikit.getTheme?.colorOnPrimary,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          value: phoneItem.isSelected,
                                          onChanged: (bool? value) {
                                            controller.changeStatus(phoneItem);
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                            const AppDivider(padding: EdgeInsets.symmetric(vertical: 5),),
                          ],
                        );
                      }),
                );
              }),
              controller.from == "contact_pick"
                  ? Positioned(
                      bottom: 25,
                      right: 20,
                      child: InkWell(
                        onTap: () {
                          controller.shareContact(context);
                        },
                        child: CircleAvatar(
                            backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
                            radius: 25,
                            child: Icon(
                              Icons.send,
                              color: MirrorflyUikit.getTheme?.colorOnPrimary,
                            )),
                      ))
                  : const SizedBox.shrink()
            ],
          ),
        ));
  }
}
