import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/settings/views/notification/notification_alert_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationAlertController());
  }
}
