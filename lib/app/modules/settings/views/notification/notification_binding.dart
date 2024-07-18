import 'package:get/get.dart';
import '../../../../modules/settings/views/notification/notification_alert_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationAlertController());
  }
}