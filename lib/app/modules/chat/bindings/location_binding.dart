import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/controllers/location_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationController>(
          () => LocationController(),
    );
  }
}
