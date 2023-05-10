import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/chat/controllers/forwardchat_controller.dart';

class ForwardChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForwardChatController());
  }
}