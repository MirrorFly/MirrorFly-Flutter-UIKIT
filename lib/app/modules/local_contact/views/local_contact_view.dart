import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/model/local_contact_model.dart';

import '../../../../mirrorfly_uikit_plugin.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../controllers/local_contact_controller.dart';

class LocalContactView extends StatefulWidget {
  const LocalContactView({Key? key,this.enableAppBar=true}) : super(key: key);
  final bool enableAppBar;
  @override
  State<LocalContactView> createState() => _LocalContactViewState();
}

class _LocalContactViewState extends State<LocalContactView> {
  final controller = Get.put(LocalContactController());

  @override
  void dispose() {
    Get.delete<LocalContactController>();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: widget.enableAppBar ? AppBar(
          centerTitle: false,
          titleSpacing: 0.0,
          iconTheme: IconThemeData(color: MirrorflyUikit.getTheme?.colorOnAppbar),
          backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
          title: controller.search.value
              ? TextField(
                  controller: controller.searchTextController,
                  onChanged: (text) => controller.onSearchTextChanged(text),
                  autofocus: true,
                  cursorColor: MirrorflyUikit.getTheme?.colorOnAppbar,
                  keyboardAppearance: MirrorflyUikit.theme == "dark" ? Brightness.dark : Brightness.light,
                  style: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar),
                  decoration: InputDecoration(
                      hintText: "Search...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: MirrorflyUikit.getTheme?.colorOnAppbar.withOpacity(0.6))),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact to send',
                      style: TextStyle(fontSize: 15, color: MirrorflyUikit.getTheme?.colorOnAppbar),
                    ),
                    Text(
                      '${controller.contactsSelected.length} Selected',
                      style: TextStyle(fontSize: 12, color: MirrorflyUikit.getTheme?.colorOnAppbar),
                    ),
                  ],
                ),
          actions: [
            controller.search.value
                ? const SizedBox()
                : IconButton(
                    icon: SvgPicture.asset(
                      searchIcon,
                      package: package,
                      width: 18,
                      height: 18,
                      colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnAppbar, BlendMode.srcIn),
                      fit: BoxFit.contain,
                    ),
                    onPressed: () {
                      if (controller.search.value) {
                        controller.search.value = false;
                      } else {
                        controller.search.value = true;
                      }
                    },
                  ),
          ],
        ) : null,
        body: WillPopScope(
          onWillPop: () {
            if (controller.search.value) {
              controller.searchTextController.text = "";
              controller.onSearchCancelled();
              controller.search.value = false;
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: SafeArea(
            child: Obx(() => controller.contactList.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                    color: MirrorflyUikit.getTheme?.primaryColor,
                  ))
                : contactListView()),
          ),
        ),
        floatingActionButton: Visibility(
          visible: controller.contactsSelected.isNotEmpty,
          child: FloatingActionButton(
            backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
            onPressed: () {
              controller.shareContact(context);
            },
            child: SvgPicture.asset(
              rightArrowProceed,
              package: package,
              colorFilter : ColorFilter.mode(MirrorflyUikit.getTheme!.colorOnPrimary, BlendMode.srcIn),
              width: 18,
            ),
          ),
        ),
      );
    });
  }

  selectedListView(RxList<LocalContact> contactsSelected) {
    return contactsSelected.isNotEmpty
        ? SizedBox(
            height: 70,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: contactsSelected.length,
                itemBuilder: (context, index) {
                  var item = contactsSelected.elementAt(index);
                  return InkWell(
                    onTap: () {
                      controller.contactSelected(item);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              ProfileTextImage(
                                text: controller.name(item.contact),
                                radius: 22,
                              ),
                              Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: MirrorflyUikit.getTheme?.colorOnPrimary,
                                      child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
                                          child: Icon(
                                            Icons.close,
                                            size: 10,
                                            color: MirrorflyUikit.getTheme?.colorOnPrimary,
                                          )))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          )
        : const SizedBox.shrink();
  }

  contactListView() {
    return Obx(() {
      return Column(
        children: [
          selectedListView(controller.contactsSelected),
          controller.searchList.isEmpty && controller.searchTextController.text.isNotEmpty
              ? Expanded(
                  child: Center(
                      child: Text(
                  "No result found",
                  style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),
                )))
              : Expanded(
                  child: ListView.builder(
                      itemCount: controller.searchList.length,
                      itemBuilder: (context, index) {
                        var item = controller.searchList.elementAt(index);
                        return InkWell(
                          onTap: () {
                            controller.contactSelected(controller.searchList.elementAt(index));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    ProfileTextImage(
                                      text: controller.name(item.contact),
                                      radius: 18,
                                    ),
                                    Visibility(
                                      visible: item.isSelected,
                                      child: Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: CircleAvatar(
                                              radius: 8,
                                              backgroundColor: MirrorflyUikit.getTheme?.colorOnPrimary,
                                              child: CircleAvatar(
                                                  radius: 7,
                                                  backgroundColor: MirrorflyUikit.getTheme?.primaryColor,
                                                  child: Icon(
                                                    Icons.check,
                                                    size: 9,
                                                    color: MirrorflyUikit.getTheme?.colorOnPrimary,
                                                  )))),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                    child: Text(
                                  controller.name(item.contact),
                                  maxLines: 1,
                                  style: TextStyle(color: MirrorflyUikit.getTheme?.textPrimaryColor),
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
        ],
      );
    });
  }
}
