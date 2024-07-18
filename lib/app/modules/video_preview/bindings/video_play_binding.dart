import 'package:get/get.dart';
import '../../../modules/video_preview/controllers/video_play_controller.dart';


class VideoPlayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPlayController>(
          () => VideoPlayController(),
    );
  }
}
