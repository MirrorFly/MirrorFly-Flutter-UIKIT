import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/constants.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/chat_settings/language/language_controller.dart';


class LanguageListView extends GetView<LanguageController> {
  const LanguageListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
            () =>
            Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: iconColor),
                    onPressed: () {
                      controller.backFromSearch(context);
                    },
                  ),
                  title: controller.search.value
                      ? TextField(
                    focusNode: controller.focusNode,
                    onChanged: (text) => controller.languageSearchFilter(text),
                    controller: controller.searchQuery,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                        hintText: "Search...", border: InputBorder.none),
                  )
                      : const Text('Choose Language'),
                  actions: [
                    controller.search.value
                        ? const SizedBox()
                        : IconButton(
                      icon: SvgPicture.asset(
                        searchIcon,package: package,
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                      onPressed: () {
                        controller.focusNode.requestFocus();
                        controller.search.value = true;
                      },
                    ),
                  ],
                ),
                body: ListView.builder(
                    itemCount: controller.languageList.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      var item = controller.languageList[index];
                        return ListTile(
                          title: Text(item.languageName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                          trailing: Visibility(visible: item.languageName ==
                              controller.translationLanguage.value,
                              child: SvgPicture.asset(tickRoundBlue,package: package,)),
                          onTap: () {
                            controller.selectLanguage(item);
                          },
                        );
                    })
            ),
      ),
    );
  }
}
