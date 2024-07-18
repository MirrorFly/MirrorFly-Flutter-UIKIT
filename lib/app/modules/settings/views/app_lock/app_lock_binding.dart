import 'package:get/get.dart';
import '../../../../modules/settings/views/app_lock/app_lock_controller.dart';

class AppLockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppLockController());
  }
}