import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/group/controllers/group_creation_controller.dart';

class GroupCreationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupCreationController());
  }
}
