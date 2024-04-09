import 'package:mirrorfly_plugin/model/user_list_model.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/gallery_picker/src/presentation/pages/gallery_media_picker_controller.dart';

import '../../../data/helper.dart';
import 'package:get/get.dart';

import '../src/data/models/picked_asset_model.dart';

class GalleryPickerController extends GetxController {
  var provider = GalleryMediaPickerController();
  var pickedFile = <PickedAssetModel>[].obs;
  var textMessage = ''.obs;
  var profile = ProfileDetails().obs;
  var maxPickImages = 10;



  void init(String senderJid, String caption) {
    textMessage(caption);
    getProfileDetails(senderJid).then((value) {
      profile(value);
    });

  }

   addFile(List<PickedAssetModel> paths) {
     pickedFile.clear();
     pickedFile.addAll(paths);
   }

   // addFile(List<PickedAssetModel> paths) {
   //  debugPrint("list size--> ${paths.length}");
   //  debugPrint("file name--> ${paths[0].file?.path}");
   //  for(var filePath in paths){
   //    if(pickedFile.contains(filePath)){
   //      debugPrint("picked file remove");
   //      pickedFile.remove(filePath);
   //    }else{
   //      debugPrint("picked file add");
   //      pickedFile.add(filePath);
   //    }
   //  }
   // }

}
