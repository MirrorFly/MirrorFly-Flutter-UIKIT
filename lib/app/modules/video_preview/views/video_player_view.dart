import 'package:flutter/material.dart';

import '../../../widgets/video_player_widget.dart';

class VideoPlayerView extends StatelessWidget {
  const VideoPlayerView({super.key, required this.videoPath});

  final String videoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: VideoPlayerWidget(
          videoPath: videoPath,
          videoTitle: "Video",
        ),
      ),
    );
  }
}
