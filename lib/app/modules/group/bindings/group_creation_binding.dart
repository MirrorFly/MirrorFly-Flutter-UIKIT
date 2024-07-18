import 'package:get/get.dart';
import '../../../modules/group/controllers/group_creation_controller.dart';

class GroupCreationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupCreationController());
  }
}