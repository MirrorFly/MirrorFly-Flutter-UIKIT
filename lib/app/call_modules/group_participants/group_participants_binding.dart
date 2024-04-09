import 'package:get/get.dart';

import 'group_participants_controller.dart';

class GroupParticipantsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupParticipantsController());
  }
}
