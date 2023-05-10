import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/profile/controllers/status_controller.dart';

class StatusListBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<StatusListController>(
          () => StatusListController(),
    );
  }

}