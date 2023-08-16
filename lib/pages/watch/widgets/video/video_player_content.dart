import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/pages/watch/video_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/widgets/platform_widget.dart';
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
    final topButtonBar = Row(
      children: [
        Expanded(
          child: Obx(
            () => Text(
              "${_c.title} - ${_c.playList[_c.index.value].name}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
        MaterialDesktopCustomButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
          onPressed: () async {
            await WindowManager.instance.setFullScreen(false);
            await _c.addHistory();
            RouterUtils.pop();
          },
        ),
      ],
    );
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        toggleFullscreenOnDoublePress: false,
        topButtonBar: [
          Obx(
            () => Expanded(
              child: _c.isFullScreen.value
                  ? topButtonBar
                  : DragToMoveArea(
                      child: topButtonBar,
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
          Theme(
            data: Theme.of(context),
            child: PopupMenuButton(
              icon: const Icon(
                Icons.subtitles,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return [
                  // 是否显示字幕
                  PopupMenuItem(
                    child: Obx(
                      () => CheckboxListTile(
                        value: _c.selectedSubtitle.value == -1,
                        onChanged: (value) {
                          _c.selectedSubtitle.value = -1;
                        },
                        title: Text('video.subtitle-none'.i18n),
                      ),
                    ),
                  ),
                  // 选择文件
                  PopupMenuItem(
                    child: Obx(
                      () => CheckboxListTile(
                        value: _c.selectedSubtitle.value == -2,
                        onChanged: (value) {
                          _c.selectedSubtitle.value = -2;
                        },
                        title: Text("video.subtitle-file".i18n),
                      ),
                    ),
                  ),
                  for (int i = 0; i < _c.subtitles.length; i++)
                    PopupMenuItem(
                      child: Obx(
                        () => CheckboxListTile(
                          value: _c.selectedSubtitle.value == i,
                          onChanged: (value) {
                            _c.selectedSubtitle.value = i;
                          },
                          title: Text(_c.subtitles[i].title),
                        ),
                      ),
                    ),
                ];
              },
            ),
          ),
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
      child: Video(
        controller: _c.videoController,
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return MaterialVideoControlsTheme(
      normal: MaterialVideoControlsThemeData(
        volumeGesture: true,
        brightnessGesture: true,
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
          Theme(
            data: Theme.of(context),
            child: PopupMenuButton(
              icon: const Icon(
                Icons.subtitles,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return [
                  // 是否显示字幕
                  PopupMenuItem(
                    value: -1,
                    child: Obx(
                      () => CheckboxListTile(
                        value: _c.selectedSubtitle.value == -1,
                        onChanged: (value) {
                          _c.selectedSubtitle.value = -1;
                        },
                        title: Text('video.subtitle-none'.i18n),
                      ),
                    ),
                  ), // 选择文件
                  PopupMenuItem(
                    child: CheckboxListTile(
                      value: _c.selectedSubtitle.value == -2,
                      onChanged: (value) {
                        _c.selectedSubtitle.value = -2;
                      },
                      title: Text("video.subtitle-file".i18n),
                    ),
                  ),
                  for (int i = 0; i < _c.subtitles.length; i++)
                    PopupMenuItem(
                      value: i,
                      child: Obx(
                        () => CheckboxListTile(
                          value: _c.selectedSubtitle.value == i,
                          onChanged: (value) {
                            _c.selectedSubtitle.value = i;
                          },
                          title: Text(_c.subtitles[i].title),
                        ),
                      ),
                    ),
                ];
              },
            ),
          ),
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
      child: Video(
        controller: _c.videoController,
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
