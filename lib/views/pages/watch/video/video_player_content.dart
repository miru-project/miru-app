import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/controllers/watch/video_controller.dart';
import 'package:miru_app/views/pages/watch/video/video_player_desktop_controls.dart';
import 'package:miru_app/views/pages/watch/video/video_player_mobile_controls.dart';

class VideoPlayerConten extends StatelessWidget {
  const VideoPlayerConten({
    super.key,
    required this.tag,
  });
  final String tag;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VideoPlayerController>(tag: tag);
    return Video(
      controller: c.videoController,
      subtitleViewConfiguration: const SubtitleViewConfiguration(
        visible: false,
      ),
      controls: (state) {
        if (Platform.isAndroid || Platform.isIOS) {
          return VideoPlayerMobileControls(
            controller: c,
          );
        }
        return VideoPlayerDesktopControls(
          controller: c,
        );
      },
    );
  }
}
