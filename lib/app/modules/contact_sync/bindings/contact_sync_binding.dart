import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/contact_sync/controllers/contact_sync_controller.dart';

class ContactSyncBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContactSyncController());
  }
}