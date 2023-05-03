import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/common/widgets.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/scanner/scanner_controller.dart';

import '../../common/constants.dart';

class WebLoginResultView extends GetView<ScannerController> {
  const WebLoginResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Settings'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(onPressed: ()=>controller.addLogin(), icon: const Icon(Icons.add))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(icQrScannerWebLogin,package: package, fit: BoxFit.cover,),
            FutureBuilder(
                future: controller.getWebLoginDetails(),
                builder: (c, data) {
                  return Obx(() {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.webLogins.length,
                        itemBuilder: (context, index) {
                          var item = controller.webLogins[index];
                          return ListItem(
                            leading: Image.asset(
                                controller.getImageForBrowser(item),package: package,width: 50,height: 50,),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.webBrowserName.checkNull()),
                                const Text("Last Login", style: TextStyle(
                                    color: textColor, fontSize: 14),),
                                Text(item.lastLoginTime.checkNull(),
                                  style: const TextStyle(
                                      color: textColor, fontSize: 14),),
                              ],
                            ),
                            dividerPadding: EdgeInsets.zero,
                            onTap: () {},);
                        });
                  });
                }),
            ListTile(contentPadding: EdgeInsets.zero, title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.power_settings_new_rounded),
                SizedBox(width: 8,),
                Text("LOGOUT FROM ALL COMPUTERS"),
              ],
            ), onTap: () =>controller.logoutWeb(context)),
            const Text("Visit ${Constants.webChatLogin}",
              style: TextStyle(color: textColor, fontSize: 14),),
          ],
        ),
      ),
    );
  }
}
