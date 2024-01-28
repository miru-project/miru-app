import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/controllers/watch/video_controller.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/watch/playlist.dart';
import 'package:window_manager/window_manager.dart';

class VideoPlayerControls extends StatefulWidget {
  const VideoPlayerControls({
    super.key,
    required this.tag,
  });
  final String tag;

  @override
  State<VideoPlayerControls> createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  late final c = Get.find<VideoPlayerController>(tag: widget.tag);
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;
  bool showControls = true;
  final _subtitleViewKey = GlobalKey<SubtitleViewState>();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (mounted) {
          setState(() {
            showControls = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) {
        _timer?.cancel();
        _timer = null;
        setState(() {
          showControls = true;
        });
        _timer = Timer.periodic(
          const Duration(seconds: 3),
          (_) {
            if (mounted) {
              setState(() {
                showControls = false;
              });
            }
          },
        );
      },
      child: FluentTheme(
        data: FluentThemeData(
          brightness: Brightness.dark,
        ),
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (value) {
            if (value is KeyDownEvent) {
              c.keyboardShortcuts[value.logicalKey]?.call();
            }
          },
          child: Stack(
            children: [
              const Positioned.fill(
                child: SizedBox.expand(),
              ),
              // subtitle
              Positioned.fill(
                child: // subtitle
                    Obx(
                  () {
                    final textStyle = TextStyle(
                      height: c.subtitleTextHeight.value,
                      fontSize: c.subtitleFontSize.value,
                      letterSpacing: 0.0,
                      wordSpacing: 0.0,
                      color: c.subtitleTextColor.value,
                      fontWeight: c.subtitleFontWeight.value,
                      backgroundColor: c.subtitleBackgroundColor.value,
                    );
                    _subtitleViewKey.currentState?.textAlign =
                        c.subtitleTextAlign.value;
                    _subtitleViewKey.currentState?.style = textStyle;
                    _subtitleViewKey.currentState?.padding =
                        EdgeInsets.fromLTRB(
                      16.0,
                      0.0,
                      16.0,
                      showControls ? 100.0 : 16.0,
                    );
                    return SubtitleView(
                      controller: c.videoController,
                      configuration: SubtitleViewConfiguration(
                        style: textStyle,
                        textAlign: c.subtitleTextAlign.value,
                      ),
                      key: _subtitleViewKey,
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Column(
                  children: [
                    // header
                    Opacity(
                      opacity: showControls ? 1 : 0,
                      child: _VideoPlayerControlsHeader(
                        title: c.title,
                        episode: c.playList[c.index.value].name,
                        onClose: () {
                          if (c.isFullScreen.value) {
                            WindowManager.instance.setFullScreen(false);
                          }
                          router.pop();
                        },
                      ),
                    ),
                    // center
                    Expanded(
                      child: Center(
                        child: Obx(() {
                          if (c.error.value.isNotEmpty) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Getting streamlink error",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Button(
                                      child: const Text('Error message'),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => ContentDialog(
                                            constraints: const BoxConstraints(
                                              maxWidth: 500,
                                            ),
                                            title: const Text('Error message'),
                                            content:
                                                SelectableText(c.error.value),
                                            actions: [
                                              Button(
                                                child:
                                                    Text('common.close'.i18n),
                                                onPressed: () {
                                                  router.pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    Button(
                                      child: Text('Retry'.i18n),
                                      onPressed: () {
                                        c.error.value = '';
                                        c.play();
                                      },
                                    ),
                                  ],
                                )
                              ],
                            );
                          }
                          if (!c.isGettingWatchData.value) {
                            return StreamBuilder(
                              stream: c.player.stream.buffering,
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data! ||
                                    c.player.state.buffering) {
                                  return const ProgressRing();
                                }
                                return const SizedBox.shrink();
                              },
                            );
                          }
                          return Card(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (c.runtime.extension.icon != null)
                                  Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: CacheNetWorkImagePic(
                                      c.runtime.extension.icon!,
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.runtime.extension.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Getting streamlink...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    // footer
                    Opacity(
                      opacity: showControls ? 1 : 0,
                      child: _VideoPlayerFooter(controller: c),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPlayerControlsHeader extends StatelessWidget {
  const _VideoPlayerControlsHeader({
    required this.title,
    required this.episode,
    required this.onClose,
  });
  final String title;
  final String episode;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: DragToMoveArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      episode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(
                FluentIcons.chevron_down,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerFooter extends StatelessWidget {
  const _VideoPlayerFooter({
    required this.controller,
  });
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                // 当前进度
                StreamBuilder(
                  stream: controller.player.stream.position,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final position = snapshot.data as Duration;
                      return Text(
                        '${position.inMinutes}:${position.inSeconds % 60}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _VideoPlayerProgress(controller: controller),
                ),
                const SizedBox(width: 20),
                // 总时长
                StreamBuilder(
                  stream: controller.player.stream.duration,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final duration = snapshot.data as Duration;
                      return Text(
                        '${duration.inMinutes}:${duration.inSeconds % 60}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: // 音量
                      Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _VideoPlayerVolume(
                        value: controller.player.state.volume,
                        onVolumeChanged: (value) {
                          controller.player.setVolume(value);
                        },
                      ),
                      // 画质
                      Obx(() {
                        if (controller.currentQality.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: _VideoPlayerQuality(controller: controller),
                        );
                      }),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 上一集
                      Obx(
                        () => IconButton(
                          onPressed: controller.index.value > 0
                              ? () {
                                  controller.index.value--;
                                }
                              : null,
                          icon: const Icon(
                            FluentIcons.previous,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      StreamBuilder(
                        stream: controller.player.stream.playing,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!) {
                            return IconButton(
                              onPressed: controller.player.pause,
                              icon: const Icon(
                                FluentIcons.pause,
                                size: 30,
                              ),
                            );
                          }
                          return IconButton(
                            onPressed: controller.player.play,
                            icon: const Icon(
                              FluentIcons.play,
                              size: 30,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      // 下一集
                      Obx(
                        () => IconButton(
                          onPressed: controller.playList.length - 1 >
                                  controller.index.value
                              ? () {
                                  controller.index.value++;
                                }
                              : null,
                          icon: const Icon(
                            FluentIcons.next,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // playback speed
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _VideoPlayerSpeed(controller: controller),
                      ),
                      // torrent files
                      Obx(() {
                        if (controller.torrentMediaFileList.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _VideoPlayerTorrentFiles(
                            controller: controller,
                          ),
                        );
                      }),
                      // track
                      _VideoPlayerTrack(controller: controller),
                      const SizedBox(width: 10),

                      // 剧集
                      _VideoPlayerEpisode(controller: controller),
                      const SizedBox(width: 10),
                      // 全屏
                      Obx(
                        () => IconButton(
                          onPressed: () {
                            controller.toggleFullscreen();
                          },
                          icon: Icon(
                            controller.isFullScreen.value
                                ? FluentIcons.back_to_window
                                : FluentIcons.full_screen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 设置
                      IconButton(
                        onPressed: () {
                          final showPlayList = controller.showPlayList.value;
                          controller.showPlayList.value = !showPlayList;
                        },
                        icon: const Icon(
                          FluentIcons.settings,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerVolume extends StatefulWidget {
  const _VideoPlayerVolume({
    required this.value,
    required this.onVolumeChanged,
  });
  final double value;
  final Function(double value) onVolumeChanged;

  @override
  State<_VideoPlayerVolume> createState() => _VideoPlayerVolumeState();
}

class _VideoPlayerVolumeState extends State<_VideoPlayerVolume> {
  final _controller = FlyoutController();
  final _volume = 0.0.obs;
  @override
  void initState() {
    super.initState();
    _volume.value = widget.value;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: _controller,
      child: IconButton(
        icon: Obx(
          () => Icon(
            _volume.value == 0
                ? FluentIcons.volume0
                : _volume.value < 50
                    ? FluentIcons.volume1
                    : _volume.value < 100
                        ? FluentIcons.volume2
                        : FluentIcons.volume3,
          ),
        ),
        onPressed: () {
          _controller.showFlyout(
            barrierDismissible: false,
            dismissOnPointerMoveAway: true,
            builder: (context) {
              return FluentTheme(
                data: FluentThemeData.dark(),
                child: FlyoutContent(
                  useAcrylic: true,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => Icon(
                            _volume.value == 0
                                ? FluentIcons.volume0
                                : _volume.value < 50
                                    ? FluentIcons.volume1
                                    : _volume.value < 100
                                        ? FluentIcons.volume2
                                        : FluentIcons.volume3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(
                          () => SizedBox(
                            height: 30,
                            child: Slider(
                              value: _volume.value,
                              max: 100,
                              onChanged: (value) {
                                _volume.value = value;
                                widget.onVolumeChanged(value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(
                          () => Text(
                            _volume.value.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoPlayerEpisode extends StatefulWidget {
  const _VideoPlayerEpisode({
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<_VideoPlayerEpisode> createState() => _VideoPlayerEpisodeState();
}

class _VideoPlayerEpisodeState extends State<_VideoPlayerEpisode> {
  final controller = FlyoutController();

  @override
  dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FluentTheme(
      data: FluentThemeData.dark(),
      child: FlyoutTarget(
        controller: controller,
        child: IconButton(
          icon: const Icon(FluentIcons.playlist_music),
          onPressed: () {
            controller.showFlyout(
              barrierDismissible: false,
              dismissOnPointerMoveAway: true,
              builder: (context) {
                return FluentTheme(
                  data: FluentThemeData.dark(),
                  child: FlyoutContent(
                    padding: const EdgeInsets.all(0),
                    useAcrylic: true,
                    child: Container(
                      width: 300,
                      constraints: const BoxConstraints(
                        maxHeight: 500,
                      ),
                      child: PlayList(
                        title: widget.controller.title,
                        list: widget.controller.playList
                            .map((e) => e.name)
                            .toList(),
                        selectIndex: widget.controller.index.value,
                        onChange: (value) {
                          widget.controller.index.value = value;
                          router.pop();
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _VideoPlayerQuality extends StatefulWidget {
  const _VideoPlayerQuality({
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<_VideoPlayerQuality> createState() => _VideoPlayerQualityState();
}

class _VideoPlayerQualityState extends State<_VideoPlayerQuality> {
  final controller = FlyoutController();

  @override
  dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: controller,
      child: Button(
        child: Text(widget.controller.currentQality.value),
        onPressed: () {
          if (widget.controller.qualityMap.isEmpty) {
            widget.controller.sendMessage(
              Message(const Text("No quality available")),
            );
            return;
          }
          controller.showFlyout(
            barrierDismissible: false,
            dismissOnPointerMoveAway: true,
            builder: (context) {
              return FluentTheme(
                data: FluentThemeData.dark(),
                child: FlyoutContent(
                  useAcrylic: true,
                  child: Container(
                    width: 200,
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                    ),
                    child: ListView(
                      children: [
                        for (final quality
                            in widget.controller.qualityMap.entries)
                          ListTile(
                            title: Text(quality.key),
                            onPressed: () {
                              widget.controller.switchQuality(
                                quality.value,
                              );
                              router.pop();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoPlayerTrack extends StatefulWidget {
  const _VideoPlayerTrack({
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<_VideoPlayerTrack> createState() => _VideoPlayerTrackState();
}

class _VideoPlayerTrackState extends State<_VideoPlayerTrack> {
  final controller = FlyoutController();

  _addSubtitle() async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt'],
      allowMultiple: false,
    );
    if (file == null) {
      return;
    }
    final data = File(file.files.first.path!).readAsStringSync();
    widget.controller.subtitles.add(
      SubtitleTrack.data(
        data,
        title: file.files.first.name,
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: controller,
      child: IconButton(
        icon: const Icon(FluentIcons.locale_language),
        onPressed: () {
          controller.showFlyout(
            barrierDismissible: false,
            dismissOnPointerMoveAway: true,
            builder: (context) {
              return FluentTheme(
                data: FluentThemeData.dark(),
                child: FlyoutContent(
                  useAcrylic: true,
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    width: 220,
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Subtitles",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        ListTile.selectable(
                          selected: SubtitleTrack.no() ==
                              widget.controller.player.state.track.subtitle,
                          title: const Text('Off'),
                          onPressed: () {
                            widget.controller.player.setSubtitleTrack(
                              SubtitleTrack.no(),
                            );
                            router.pop();
                          },
                        ),
                        ListTile.selectable(
                          title: const Text('Add subtitle file'),
                          onPressed: () {
                            _addSubtitle();
                          },
                        ),
                        // 来自扩展的字幕
                        for (final subtitle in widget.controller.subtitles)
                          ListTile.selectable(
                            selected: subtitle ==
                                widget.controller.player.state.track.subtitle,
                            title: Text(subtitle.title ?? ''),
                            subtitle: Text(subtitle.language ?? ''),
                            onPressed: () {
                              widget.controller.player.setSubtitleTrack(
                                subtitle,
                              );
                              router.pop();
                            },
                          ),
                        // 来自视频的字幕
                        for (final subtitle
                            in widget.controller.player.state.tracks.subtitle)
                          if (subtitle != SubtitleTrack.no() &&
                              (subtitle.language != null ||
                                  subtitle.title != null))
                            ListTile.selectable(
                              selected: subtitle ==
                                  widget.controller.player.state.track.subtitle,
                              title: Text(subtitle.title ?? ''),
                              subtitle: Text(subtitle.language ?? ''),
                              onPressed: () {
                                widget.controller.player.setSubtitleTrack(
                                  subtitle,
                                );
                                router.pop();
                              },
                            ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Audio Tracks",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // 来自视频的音轨
                        for (final audio
                            in widget.controller.player.state.tracks.audio)
                          if (audio.language != null || audio.title != null)
                            ListTile.selectable(
                              selected: audio ==
                                  widget.controller.player.state.track.audio,
                              title: Text(audio.title ?? ''),
                              subtitle: Text(audio.language ?? ''),
                              onPressed: () {
                                widget.controller.player.setAudioTrack(
                                  audio,
                                );
                                router.pop();
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoPlayerTorrentFiles extends StatefulWidget {
  const _VideoPlayerTorrentFiles({
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<_VideoPlayerTorrentFiles> createState() =>
      _VideoPlayerTorrentFilesState();
}

class _VideoPlayerTorrentFilesState extends State<_VideoPlayerTorrentFiles> {
  final controller = FlyoutController();

  @override
  dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: controller,
      child: IconButton(
        icon: const Icon(FluentIcons.folder_open),
        onPressed: () {
          controller.showFlyout(
            barrierDismissible: false,
            dismissOnPointerMoveAway: true,
            builder: (context) {
              return FluentTheme(
                data: FluentThemeData.dark(),
                child: FlyoutContent(
                  useAcrylic: true,
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    width: 300,
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        for (final file
                            in widget.controller.torrentMediaFileList)
                          ListTile.selectable(
                            title: Text(
                              file,
                              style: const TextStyle(fontSize: 13),
                            ),
                            selected:
                                widget.controller.currentTorrentFile.value ==
                                    file,
                            onPressed: () {
                              widget.controller.playTorrentFile(file);
                              router.pop();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoPlayerSpeed extends StatefulWidget {
  const _VideoPlayerSpeed({
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<_VideoPlayerSpeed> createState() => _VideoPlayerSpeedState();
}

class _VideoPlayerSpeedState extends State<_VideoPlayerSpeed> {
  final controller = FlyoutController();

  @override
  dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: controller,
      child: Button(
        child: Obx(() => Text('x${widget.controller.currentSpeed.value}')),
        onPressed: () {
          controller.showFlyout(
            barrierDismissible: false,
            dismissOnPointerMoveAway: true,
            builder: (context) {
              return FluentTheme(
                data: FluentThemeData.dark(),
                child: FlyoutContent(
                  useAcrylic: true,
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    width: 200,
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        for (final speed in widget.controller.speedList)
                          ListTile.selectable(
                            title: Text(
                              speed.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 13),
                            ),
                            selected:
                                widget.controller.currentSpeed.value == speed,
                            onPressed: () {
                              widget.controller.player.setRate(speed);
                              widget.controller.currentSpeed.value = speed;
                              router.pop();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoPlayerProgress extends StatefulWidget {
  const _VideoPlayerProgress({
    required this.controller,
  });
  final VideoPlayerController controller;

  @override
  State<_VideoPlayerProgress> createState() => _VideoPlayerProgressState();
}

class _VideoPlayerProgressState extends State<_VideoPlayerProgress> {
  Duration position = const Duration();
  Duration duration = const Duration();
  bool _isDrag = false;

  @override
  void initState() {
    super.initState();
    widget.controller.player.stream.position.listen((event) {
      if (!_isDrag) {
        position = event;
      }
    });
    widget.controller.player.stream.duration.listen((event) {
      duration = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: (position.inSeconds).toDouble(),
      max: (duration.inSeconds).toDouble(),
      label: '${position.inMinutes}:${position.inSeconds % 60}',
      onChanged: (value) {
        _isDrag = true;
        setState(() {
          position = Duration(seconds: value.toInt());
        });
      },
      onChangeEnd: (value) {
        _isDrag = false;
        widget.controller.player.seek(
          Duration(
            seconds: value.toInt(),
          ),
        );
      },
    );
  }
}
