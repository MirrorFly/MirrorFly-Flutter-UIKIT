import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/chat_settings/language/language_controller.dart';


class LanguageListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(
      () => LanguageController(),
    );
  }
}
