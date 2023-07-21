import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/pages/watch/video_controller.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:window_manager/window_manager.dart';

class VideoPlayerConten extends StatefulWidget {
  const VideoPlayerConten({
    Key? key,
    required this.tag,
  }) : super(key: key);
  final String tag;

  @override
  State<VideoPlayerConten> createState() => _VideoPlayerContenState();
}

class _VideoPlayerContenState extends State<VideoPlayerConten> {
  late final _c = Get.find<VideoPlayerController>(tag: widget.tag);

  Widget _buildDesktop(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        toggleFullscreenOnDoublePress: false,
        topButtonBar: [
          Expanded(
            child: DragToMoveArea(
              child: Row(
                children: [
                  Obx(
                    () => Text(
                      "${_c.title} - ${_c.playList[_c.index.value].name}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  MaterialDesktopCustomButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await _c.addHistory();
                      RouterUtils.pop();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
        bottomButtonBar: [
          Obx(() {
            if (_c.index.value > 0) {
              return MaterialDesktopCustomButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {
                  _c.index.value--;
                },
              );
            }
            return const SizedBox.shrink();
          }),
          const MaterialDesktopPlayOrPauseButton(),
          Obx(() {
            if (_c.index.value != _c.playList.length - 1) {
              return MaterialDesktopCustomButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  _c.index.value++;
                },
              );
            }
            return const SizedBox.shrink();
          }),
          const MaterialDesktopVolumeButton(),
          const MaterialDesktopPositionIndicator(),
          const Spacer(),
          MaterialDesktopCustomButton(
            onPressed: () {
              _c.showPlayList.value = !_c.showPlayList.value;
            },
            icon: const Icon(Icons.list),
          ),
          Obx(
            () => MaterialDesktopCustomButton(
              onPressed: () => _c.toggleFullscreen(),
              icon: (_c.isFullScreen.value
                  ? const Icon(Icons.fullscreen_exit)
                  : const Icon(Icons.fullscreen)),
            ),
          )
        ],
      ),
      fullscreen: const MaterialDesktopVideoControlsThemeData(),
      child: Screenshot(
        controller: _c.screenshotController,
        child: Obx(
          () => Video(
            controller: _c.videoController,
            controls: _c.hideControlPanel.value ? null : AdaptiveVideoControls,
          ),
        ),
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return MaterialVideoControlsTheme(
      normal: MaterialVideoControlsThemeData(
        topButtonBar: [
          Obx(
            () => Text(
              "${_c.title} - ${_c.playList[_c.index.value].name}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const Spacer(),
          MaterialCustomButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onPressed: () async {
              await _c.addHistory();
              RouterUtils.pop();
            },
          ),
        ],
        bottomButtonBar: [
          Obx(() {
            if (_c.index.value > 0) {
              return MaterialCustomButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {
                  _c.index.value--;
                },
              );
            }
            return const SizedBox.shrink();
          }),
          const MaterialPlayOrPauseButton(),
          Obx(() {
            if (_c.index.value != _c.playList.length - 1) {
              return MaterialCustomButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  _c.index.value++;
                },
              );
            }
            return const SizedBox.shrink();
          }),
          const MaterialPositionIndicator(),
          const Spacer(),
          MaterialCustomButton(
            onPressed: () {
              _c.showPlayList.value = !_c.showPlayList.value;
            },
            icon: const Icon(Icons.list),
          ),
        ],
        seekBarMargin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
      ),
      fullscreen: const MaterialVideoControlsThemeData(),
      child: Screenshot(
        controller: _c.screenshotController,
        child: Obx(
          () => Video(
            controller: _c.videoController,
            controls: _c.hideControlPanel.value ? null : AdaptiveVideoControls,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
