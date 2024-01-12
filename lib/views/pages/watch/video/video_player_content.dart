import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/controllers/watch/video_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:window_manager/window_manager.dart';

class VideoPlayerConten extends StatefulWidget {
  const VideoPlayerConten({
    super.key,
    required this.tag,
  });
  final String tag;

  @override
  State<VideoPlayerConten> createState() => _VideoPlayerContenState();
}

class _VideoPlayerContenState extends State<VideoPlayerConten> {
  late final _c = Get.find<VideoPlayerController>(tag: widget.tag);

  final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  late final topButtonBar = Row(
    children: [
      Expanded(
        child: Obx(
          () => DefaultTextStyle(
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _c.title,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _c.playList[_c.index.value].name,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  )
                ],
              )),
        ),
      ),
      Tooltip(
        message: "video.tooltip.close".i18n,
        child: MaterialDesktopCustomButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
          onPressed: () async {
            if (!Platform.isAndroid) {
              await WindowManager.instance.setFullScreen(false);
            }
            await _c.onExit();
            RouterUtils.pop();
          },
        ),
      ),
    ],
  );

  Widget _buildDesktop(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        toggleFullscreenOnDoublePress: false,
        keyboardShortcuts: _c.keyboardShortcuts,
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
              return Tooltip(
                message: "video.tooltip.previous".i18n,
                child: MaterialDesktopCustomButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    _c.index.value--;
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Tooltip(
            message: "video.tooltip.play-or-pause".i18n,
            child: const MaterialDesktopPlayOrPauseButton(),
          ),
          Obx(() {
            if (_c.index.value != _c.playList.length - 1) {
              return Tooltip(
                message: "video.tooltip.next".i18n,
                child: MaterialDesktopCustomButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    _c.index.value++;
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Tooltip(
            message: "video.tooltip.volume".i18n,
            child: const MaterialDesktopVolumeButton(),
          ),
          const MaterialDesktopPositionIndicator(),
          const Spacer(),
          Theme(
            data: ThemeData.dark(useMaterial3: true),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: PopupMenuButton(
                    tooltip: "video.tooltip.speed".i18n,
                    child: Obx(
                      () => Text(
                        'x${_c.speed.value}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    itemBuilder: (context) {
                      return [
                        for (final speed in speeds)
                          PopupMenuItem(
                            child: Text('x$speed'),
                            onTap: () {
                              _c.speed.value = speed;
                            },
                          ),
                      ];
                    },
                  ),
                ),
                Obx(() {
                  if (_c.torrentMediaFileList.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return PopupMenuButton(
                    tooltip: "video.tooltip.torrent-file-list".i18n,
                    icon: const Icon(
                      Icons.file_open,
                      color: Colors.white,
                    ),
                    itemBuilder: (context) {
                      return [
                        for (int i = 0; i < _c.torrentMediaFileList.length; i++)
                          PopupMenuItem(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            child: Obx(
                              () => CheckboxListTile(
                                value: _c.currentTorrentFile.value ==
                                    _c.torrentMediaFileList[i],
                                onChanged: (_) {
                                  _c.playTorrentFile(
                                    _c.torrentMediaFileList[i],
                                  );
                                },
                                title: Text(_c.torrentMediaFileList[i]),
                              ),
                            ),
                          ),
                      ];
                    },
                  );
                }),
                PopupMenuButton(
                  tooltip: "video.tooltip.subtitle".i18n,
                  icon: const Icon(
                    Icons.subtitles,
                    color: Colors.white,
                  ),
                  itemBuilder: (context) {
                    return [
                      // 是否显示字幕
                      PopupMenuItem(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
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
                Obx(() {
                  if (_c.currentQality.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: PopupMenuButton(
                      tooltip: "video.tooltip.quality".i18n,
                      child: Obx(
                        () => Text(
                          _c.currentQality.value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      itemBuilder: (context) {
                        return [
                          for (final qualit in _c.qualityUrls.entries)
                            PopupMenuItem(
                              child: Text(qualit.key),
                              onTap: () {
                                _c.switchQuality(_c.qualityUrls[qualit.key]!);
                              },
                            ),
                        ];
                      },
                    ),
                  );
                })
              ],
            ),
          ),
          Tooltip(
            message: "video.tooltip.play-list".i18n,
            child: MaterialDesktopCustomButton(
              onPressed: () {
                _c.showPlayList.value = !_c.showPlayList.value;
              },
              icon: const Icon(Icons.list),
            ),
          ),
          Obx(
            () => Tooltip(
              message: "video.tooltip.full-screen".i18n,
              child: MaterialDesktopCustomButton(
                onPressed: () => _c.toggleFullscreen(),
                icon: (_c.isFullScreen.value
                    ? const Icon(Icons.fullscreen_exit)
                    : const Icon(Icons.fullscreen)),
              ),
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
        topButtonBar: [Expanded(child: topButtonBar)],
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
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: PopupMenuButton(
                    child: Obx(
                      () => Text(
                        'x${_c.speed.value}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    itemBuilder: (context) {
                      return [
                        for (final speed in speeds)
                          PopupMenuItem(
                            child: Text('x$speed'),
                            onTap: () {
                              _c.speed.value = speed;
                            },
                          ),
                      ];
                    },
                  ),
                ),
                Obx(() {
                  if (_c.torrentMediaFileList.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return PopupMenuButton(
                    icon: const Icon(
                      Icons.file_open,
                      color: Colors.white,
                    ),
                    itemBuilder: (context) {
                      return [
                        for (int i = 0; i < _c.torrentMediaFileList.length; i++)
                          PopupMenuItem(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            child: Obx(
                              () => CheckboxListTile(
                                value: _c.currentTorrentFile.value ==
                                    _c.torrentMediaFileList[i],
                                onChanged: (_) {
                                  _c.playTorrentFile(
                                    _c.torrentMediaFileList[i],
                                  );
                                },
                                title: Text(_c.torrentMediaFileList[i]),
                              ),
                            ),
                          ),
                      ];
                    },
                  );
                }),
                PopupMenuButton(
                  icon: const Icon(
                    Icons.subtitles,
                    color: Colors.white,
                  ),
                  itemBuilder: (context) {
                    return [
                      // 是否显示字幕
                      PopupMenuItem(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
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
                Obx(() {
                  if (_c.currentQality.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: PopupMenuButton(
                      child: Obx(
                        () => Text(
                          _c.currentQality.value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      itemBuilder: (context) {
                        return [
                          for (final qualit in _c.qualityUrls.entries)
                            PopupMenuItem(
                              child: Text(qualit.key),
                              onTap: () {
                                _c.switchQuality(_c.qualityUrls[qualit.key]!);
                              },
                            ),
                        ];
                      },
                    ),
                  );
                }),
              ],
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
