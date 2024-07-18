import 'package:get/get.dart';

import '../controllers/call_info_controller.dart';

class CallInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallInfoController>(
          () => CallInfoController(),
    );
  }
}