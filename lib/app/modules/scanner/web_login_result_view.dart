import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/app_localizations.dart' show getTranslated;
import 'package:mirrorfly_uikit_plugin/app/modules/scanner/web_login_controller.dart' show WebLoginController;
import '../../common/widgets.dart';
import '../../extensions/extensions.dart';

import '../../common/constants.dart';
import '../../data/utils.dart';

class WebLoginResultView extends NavViewStateful<WebLoginController> {
  const WebLoginResultView({Key? key}) : super(key: key);

  @override
  WebLoginController createController({String? tag}) =>
      Get.put(WebLoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("webSettings")),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
              onPressed: () => controller.addLogin(),
              icon: const Icon(Icons.add))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppUtils.assetIcon(
                assetName: icQrScannerWebLogin,
                fit: BoxFit.cover,
              ),
              FutureBuilder(
                  future: controller.getWebLoginDetails(),
                  builder: (c, data) {
                    return Obx(() {
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.webLogins.length,
                          itemBuilder: (context, index) {
                            var item = controller.webLogins[index];
                            return ListItem(
                              leading: AppUtils.assetIcon(
                                assetName: controller.getImageForBrowser(item),
                                width: 50,
                                height: 50,
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.webBrowserName.checkNull()),
                                  Text(
                                    getTranslated("lastLogin"),
                                    style: const TextStyle(
                                        color: textColor, fontSize: 14),
                                  ),
                                  Text(
                                    item.lastLoginTime.checkNull(),
                                    style: const TextStyle(
                                        color: textColor, fontSize: 14),
                                  ),
                                ],
                              ),
                              dividerPadding: EdgeInsets.zero,
                              onTap: () {},
                            );
                          });
                    });
                  }),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.power_settings_new_rounded),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(getTranslated("logoutFromAllComputers")),
                    ],
                  ),
                  onTap: () => controller.logoutWeb()),
               Text(
                "Visit ${Constants.webChatLogin}",
                style: const TextStyle(color: textColor, fontSize: 14),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
