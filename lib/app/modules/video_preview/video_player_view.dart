import 'package:flutter/material.dart';

import '../../../mirrorfly_uikit_plugin.dart';
import '../../widgets/video_player_widget.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({Key? key, required this.videoPath,this.enableAppBar=true}) : super(key: key);
  final String videoPath;
  final bool enableAppBar;
  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  // final controller = Get.put(VideoPlayController());

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirrorflyUikit.getTheme?.scaffoldColor,
        appBar: widget.enableAppBar ? AppBar(
          iconTheme: IconThemeData(
              color: MirrorflyUikit.getTheme?.colorOnAppbar),
          backgroundColor: MirrorflyUikit.getTheme?.appBarColor,
        ) : null,
        body: SafeArea(
          child: Column(
            children: [
              /*AspectRatio(
                aspectRatio: 0.6,
                child: BetterVideoPlayer(
                    configuration:
                    const BetterVideoPlayerConfiguration(
                      looping: false,
                      autoPlay: false,
                      allowedScreenSleep: false,
                      autoPlayWhenResume: false,
                    ),
                    controller:
                    BetterVideoPlayerController(),
                    dataSource: BetterVideoPlayerDataSource(
                      BetterVideoPlayerDataSourceType.file,
                      widget.videoPath//controller.videoPath.value,
                    ),
                  ),
              ),*/
              AspectRatio(
                aspectRatio: 0.6,
                child: VideoPlayerWidget(
                  videoPath: widget.videoPath,
                  videoTitle: "Video",
                ),
              ),
            ],
          ),
        ),
    );
  }
}
