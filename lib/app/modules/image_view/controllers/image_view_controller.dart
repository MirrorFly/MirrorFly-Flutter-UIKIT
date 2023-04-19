import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

class ImageViewController extends GetxController {
  var imageName = ''.obs;
  var imagePath = ''.obs;
  var imageUrl = ''.obs;
  @override
  void onInit() {
    super.onInit();
    imageName(Get.arguments['imageName']);
    imagePath(Get.arguments['imagePath']);
    if(Get.arguments['imageUrl'].toString().startsWith("http")) {
      imageUrl(Get.arguments['imageUrl']);
    }else {
      imageUrl(SessionManagement.getMediaEndPoint().checkNull() +
          Get.arguments['imageUrl'].toString());
    }
  }


}
