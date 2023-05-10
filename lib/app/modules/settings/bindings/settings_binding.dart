import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
          () => SettingsController(),
    );
  }

}