import 'package:get/get.dart';

import 'add_participants_controller.dart';


class ParticipantsBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => CallController());
    Get.lazyPut<AddParticipantsController>(
          () => AddParticipantsController(),
    );
  }
}