import 'package:get/get.dart';
import '../../../../../modules/settings/views/chat_settings/language/language_controller.dart';


class LanguageListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(
      () => LanguageController(),
    );
  }
}
