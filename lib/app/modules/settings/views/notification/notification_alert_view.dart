import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../settings_widgets.dart';
import 'notification_alert_controller.dart';

class NotificationAlertView extends GetView<NotificationAlertController> {
  const NotificationAlertView({super.key, this.enableAppBar = true});
  final bool enableAppBar;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: enableAppBar
          ? AppBar(
              title: const Text('Notifications Alert'),
              automaticallyImplyLeading: true,
            )
          : null,
      body: Obx(() {
        return Column(
          children: [
            notificationItem(
                title: "Notification Sound",
                subtitle: "Play sounds for incoming messages",
                on: controller.displayNotificationSoundPreference,
                onTap: () => controller.notificationSound()),
            /*notificationItem(
              title: "Notification Popup",
              subtitle: "Showing popup for incoming messages",
              on: controller.displayNotificationPopupPreference,
              onTap: () =>controller.notificationPopup()),*/
            notificationItem(
                title: "Vibration",
                subtitle:
                    "Vibrate when a new message arrives while application is running",
                on: controller.displayVibrationPreference,
                onTap: () => controller.vibration()),
            notificationItem(
                title: "Mute Notification",
                subtitle:
                    "This will mute all notifications alerts for incoming messages",
                on: controller.displayMuteNotificationPreference,
                onTap: () => controller.mute()),
          ],
        );
      }),
    );
  }
}
