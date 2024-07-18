import 'package:get/get.dart';
import '../../../modules/chat/controllers/location_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationController>(
          () => LocationController(),
    );
  }
}
