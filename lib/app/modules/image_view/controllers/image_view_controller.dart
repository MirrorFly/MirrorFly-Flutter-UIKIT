import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/data/session_management.dart';
import 'package:mirrorfly_uikit_plugin/app/data/helper.dart';

class ImageViewController extends GetxController {
  var imageName = ''.obs;
  var imagePath = ''.obs;
  var imageUrl = ''.obs;


  void init({required String imageName, String? imagePath, String? imageUrl}) {
    this.imageName(imageName);
    this.imagePath(imagePath);
    if(imageUrl.toString().startsWith("http")) {
      this.imageUrl(imageUrl);
    }else {
      this.imageUrl(SessionManagement.getMediaEndPoint().checkNull() +
          imageUrl.toString());
    }
  }


}
