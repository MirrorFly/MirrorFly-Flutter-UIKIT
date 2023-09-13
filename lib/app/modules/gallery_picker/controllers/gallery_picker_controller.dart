import 'package:mirrorfly_plugin/model/user_list_model.dart';

import '../../../data/helper.dart';
import 'package:get/get.dart';

import '../src/data/models/picked_asset_model.dart';

class GalleryPickerController extends GetxController {

  var pickedFile = <PickedAssetModel>[].obs;
  var textMessage = ''.obs;
  var profile = Profile().obs;
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
