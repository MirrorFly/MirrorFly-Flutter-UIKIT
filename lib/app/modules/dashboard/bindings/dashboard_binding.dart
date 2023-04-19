import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/dashboard/controllers/dashboard_controller.dart';


class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
          () => DashboardController(),
    );
  }
}
