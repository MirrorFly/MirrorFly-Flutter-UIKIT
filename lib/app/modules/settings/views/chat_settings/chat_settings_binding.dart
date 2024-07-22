import 'package:get/get.dart';
import '../../../../modules/settings/views/chat_settings/chat_settings_controller.dart';

class ChatSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatSettingsController());
  }
}
