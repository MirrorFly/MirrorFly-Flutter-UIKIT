import 'package:get/get.dart';
import 'package:mirrorfly_uikit_plugin/app/modules/video_preview/controllers/video_play_controller.dart';


class VideoPlayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPlayController>(
          () => VideoPlayController(),
    );
  }
}
