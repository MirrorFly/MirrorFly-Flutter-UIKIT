import 'package:get/get.dart';
import '../../../modules/contact_sync/controllers/contact_sync_controller.dart';

class ContactSyncBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContactSyncController());
  }
}