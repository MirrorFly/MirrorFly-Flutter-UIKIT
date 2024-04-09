import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/group/controllers/group_info_controller.dart';

class GroupInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupInfoController());
  }
}
