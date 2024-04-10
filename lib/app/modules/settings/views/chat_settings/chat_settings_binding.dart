import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/chat_settings/chat_settings_controller.dart';

class ChatSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatSettingsController());
  }
}
