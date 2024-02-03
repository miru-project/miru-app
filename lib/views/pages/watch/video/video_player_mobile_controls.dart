import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/controllers/watch/video_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/layout.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/views/pages/watch/video/video_player_sidebar.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/progress.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class VideoPlayerMobileControls extends StatefulWidget {
  const VideoPlayerMobileControls({super.key, required this.controller});
  final VideoPlayerController controller;

  @override
  State<VideoPlayerMobileControls> createState() =>
      _VideoPlayerMobileControlsState();
}

class _VideoPlayerMobileControlsState extends State<VideoPlayerMobileControls> {
  late final VideoPlayerController _c = widget.controller;
  final _subtitleViewKey = GlobalKey<SubtitleViewState>();
  bool _showControls = true;
  double _currentBrightness = 0;
  double _currentVolume = 0;
  // 是否是调整亮度
  bool _isBrightness = false;
  // 是否正在调节
  bool _isAdjusting = false;
  // 滑动时的进度
  Duration _position = Duration.zero;
  // 是否左右滑动调整进度
  bool _isSeeking = false;
  // 是否长按加速
  bool _isLongPress = false;
  // 定时器
  Timer? _timer;

  _updateTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _showControls = true;
    });
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      },
    );
  }

  _init() async {
    _updateTimer();
    VolumeController().showSystemUI = false;
    _currentBrightness = await ScreenBrightness().current;
    _currentVolume = await VolumeController().getVolume();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.white,
      ),
      child: Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: Stack(
          children: [
            // 字幕
            Positioned.fill(
              child: Obx(
                () {
                  final textStyle = TextStyle(
                    height: 1.4,
                    fontSize: _c.subtitleFontSize.value,
                    letterSpacing: 0.0,
                    wordSpacing: 0.0,
                    color: _c.subtitleFontColor.value,
                    fontWeight: _c.subtitleFontWeight.value,
                    backgroundColor:
                        _c.subtitleBackgroundColor.value.withOpacity(
                      _c.subtitleBackgroundOpacity.value,
                    ),
                  );
                  _subtitleViewKey.currentState?.textAlign =
                      _c.subtitleTextAlign.value;
                  _subtitleViewKey.currentState?.style = textStyle;
                  _subtitleViewKey.currentState?.padding = EdgeInsets.fromLTRB(
                    16.0,
                    0.0,
                    16.0,
                    _showControls ? 100.0 : 16.0,
                  );
                  return SubtitleView(
                    controller: _c.videoController,
                    configuration: SubtitleViewConfiguration(
                      style: textStyle,
                      textAlign: _c.subtitleTextAlign.value,
                    ),
                    key: _subtitleViewKey,
                  );
                },
              ),
            ),
            // 顶部提示
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black45,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSeeking)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}',
                              ),
                              const Text('/'),
                              Text(
                                '${_c.player.state.duration.inMinutes}:${(_c.player.state.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                              ),
                            ],
                          ),
                        ),
                      if (_isLongPress)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Playing at 3x speed'),
                        ),
                      if (_isAdjusting)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isBrightness) ...[
                                const Icon(Icons.brightness_5),
                                const SizedBox(width: 5),
                                Text(
                                  (_currentBrightness * 100).toStringAsFixed(0),
                                )
                              ],
                              if (!_isBrightness) ...[
                                const Icon(Icons.volume_up),
                                const SizedBox(width: 5),
                                Text(
                                  (_currentVolume * 100).toStringAsFixed(0),
                                )
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // 手势层
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_showControls) {
                    _showControls = false;
                    setState(() {});
                    return;
                  }
                  _updateTimer();
                },
                onDoubleTapDown: (details) {
                  // 如果左边点击快退，中间暂停，右边快进
                  final dx = details.localPosition.dx;
                  final width = LayoutUtils.width / 3;
                  if (dx < width) {
                    _c.player.seek(
                      _c.player.state.position - const Duration(seconds: 10),
                    );
                  } else if (dx > width * 2) {
                    _c.player.seek(
                      _c.player.state.position + const Duration(seconds: 10),
                    );
                  } else {
                    if (_c.player.state.playing) {
                      _c.player.pause();
                    } else {
                      _c.player.play();
                    }
                  }
                },
                onVerticalDragStart: (details) {
                  _isBrightness =
                      details.localPosition.dx < LayoutUtils.width / 2;
                },
                // 左右两边上下滑动
                onVerticalDragUpdate: (details) {
                  final add = details.delta.dy / 500;
                  // 如果是左边调节亮度
                  if (_isBrightness) {
                    _currentBrightness = (_currentBrightness - add).clamp(0, 1);
                    ScreenBrightness().setScreenBrightness(_currentBrightness);
                  }
                  // 如果是右边调节音量
                  else {
                    _currentVolume = (_currentVolume - add).clamp(0, 1);
                    VolumeController().setVolume(_currentVolume);
                  }
                  _isAdjusting = true;
                  setState(() {});
                },
                onHorizontalDragStart: (details) {
                  _position = _c.player.state.position;
                },
                onVerticalDragEnd: (details) {
                  _isAdjusting = false;
                  setState(() {});
                },
                // 左右滑动
                onHorizontalDragUpdate: (details) {
                  double scale = 200000 / LayoutUtils.width;
                  Duration pos = _position +
                      Duration(
                        milliseconds: (details.delta.dx * scale).round(),
                      );
                  _position = Duration(
                    milliseconds: pos.inMilliseconds.clamp(
                      0,
                      _c.player.state.duration.inMilliseconds,
                    ),
                  );
                  _isSeeking = true;
                  setState(() {});
                },
                onHorizontalDragEnd: (details) {
                  _c.player.seek(_position);
                  _isSeeking = false;
                  setState(() {});
                },
                onLongPressStart: (details) {
                  _isLongPress = true;
                  _c.player.setRate(3.0);
                  setState(() {});
                },
                onLongPressEnd: (details) {
                  _c.player.setRate(_c.currentSpeed.value);
                  _isLongPress = false;
                  setState(() {});
                },
                child: const SizedBox.expand(),
              ),
            ),
            // 中间显示
            Positioned.fill(
              child: Center(
                child: Obx(() {
                  if (_c.error.value.isNotEmpty) {
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
                            FilledButton(
                              child: const Text('Error message'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error message'),
                                    content: SelectableText(_c.error.value),
                                    actions: [
                                      FilledButton(
                                        child: Text('common.close'.i18n),
                                        onPressed: () {
                                          Get.back();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              child: Text('Retry'.i18n),
                              onPressed: () {
                                _c.error.value = '';
                                _c.play();
                              },
                            ),
                          ],
                        )
                      ],
                    );
                  }
                  if (!_c.isGettingWatchData.value) {
                    return StreamBuilder(
                      stream: _c.player.stream.buffering,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data! ||
                            _c.player.state.buffering) {
                          return const ProgressRing();
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  }
                  return Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_c.runtime.extension.icon != null)
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              margin: const EdgeInsets.only(right: 10),
                              child: CacheNetWorkImagePic(
                                _c.runtime.extension.icon!,
                                width: 30,
                                height: 30,
                              ),
                            ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _c.runtime.extension.name,
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
                    ),
                  );
                }),
              ),
            ),
            // 头部控制栏
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _Header(
                  controller: _c,
                ),
              ),
            // 底部控制栏
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _Footer(controller: _c),
              ),
            Positioned.fill(
              child: Obx(
                () {
                  if (!_c.showSidebar.value) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    child: Container(
                      color: Colors.black54,
                    ),
                    onTap: () {
                      _c.showSidebar.value = false;
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              RouterUtils.pop();
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() {
              final data = controller.playList[controller.index.value];
              final episode = data.name;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.title,
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
              );
            }),
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              controller.toggleSideBar(SidebarTab.settings);
            },
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SeekBar(controller: controller),
          const SizedBox(height: 10),
          Row(
            children: [
              Obx(
                () => IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: controller.index.value > 0
                      ? () {
                          controller.index.value--;
                        }
                      : null,
                ),
              ),
              StreamBuilder(
                stream: controller.player.stream.playing,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data! ||
                      controller.player.state.playing) {
                    return IconButton(
                      onPressed: controller.player.pause,
                      icon: const Icon(
                        Icons.pause,
                        size: 30,
                      ),
                    );
                  }
                  return IconButton(
                    onPressed: controller.player.play,
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 30,
                    ),
                  );
                },
              ),
              Obx(
                () => IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed:
                      controller.playList.length - 1 > controller.index.value
                          ? () {
                              controller.index.value++;
                            }
                          : null,
                ),
              ),
              const SizedBox(width: 10),
              // 播放进度
              StreamBuilder(
                stream: controller.player.stream.position,
                builder: (context, snapshot) {
                  late Duration position;
                  if (snapshot.hasData) {
                    position = snapshot.data as Duration;
                  } else {
                    position = controller.player.state.position;
                  }

                  return Text(
                    '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  );
                },
              ),
              const Text('/'),
              StreamBuilder(
                stream: controller.player.stream.duration,
                builder: (context, snapshot) {
                  late Duration duration;
                  if (snapshot.hasData) {
                    duration = snapshot.data as Duration;
                  } else {
                    duration = controller.player.state.duration;
                  }
                  return Text(
                    '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  );
                },
              ),
              const Spacer(),
              // 倍速
              Obx(
                () => PopupMenuButton<double>(
                  initialValue: controller.currentSpeed.value,
                  onSelected: (value) {
                    controller.currentSpeed.value = value;
                  },
                  itemBuilder: (context) {
                    return [
                      for (final speed in controller.speedList)
                        PopupMenuItem(
                          value: speed,
                          child: Text('${speed}x'),
                        ),
                    ];
                  },
                  child: Text(
                    '${controller.currentSpeed.value}x',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              // torrent files
              const SizedBox(width: 10),
              Obx(() {
                if (controller.torrentMediaFileList.isEmpty) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  onPressed: () {
                    controller.toggleSideBar(SidebarTab.torrentFiles);
                  },
                  icon: const Icon(Icons.video_file),
                );
              }),
              IconButton(
                onPressed: () {
                  controller.toggleSideBar(SidebarTab.tracks);
                },
                icon: const Icon(
                  Icons.subtitles,
                ),
              ),
              // 播放列表
              IconButton(
                icon: const Icon(Icons.playlist_play),
                onPressed: () {
                  controller.toggleSideBar(SidebarTab.episodes);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeekBar extends StatefulWidget {
  const _SeekBar({
    required this.controller,
  });
  final VideoPlayerController controller;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  bool _isSliderDraging = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _buffer = Duration.zero;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferSubscription;

  @override
  void initState() {
    super.initState();
    _duration = widget.controller.player.state.duration;
    _position = widget.controller.player.state.position;
    _buffer = widget.controller.player.state.buffer;

    _durationSubscription =
        widget.controller.player.stream.duration.listen((event) {
      setState(() {
        _duration = event;
      });
    });
    _positionSubscription =
        widget.controller.player.stream.position.listen((event) {
      if (!_isSliderDraging) {
        setState(() {
          _position = event;
        });
      }
    });
    _bufferSubscription =
        widget.controller.player.stream.buffer.listen((event) {
      setState(() {
        _buffer = event;
      });
    });
  }

  @override
  dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 13,
      child: SliderTheme(
          data: const SliderThemeData(
            trackHeight: 2,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 6,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 12,
            ),
          ),
          child: Slider(
            min: 0,
            max: _duration.inMilliseconds.toDouble(),
            value: clampDouble(
              _position.inMilliseconds.toDouble(),
              0,
              _duration.inMilliseconds.toDouble(),
            ),
            secondaryTrackValue: clampDouble(
              _buffer.inMilliseconds.toDouble(),
              0,
              _duration.inMilliseconds.toDouble(),
            ),
            onChanged: (value) {
              if (_isSliderDraging) {
                setState(() {
                  _position = Duration(milliseconds: value.toInt());
                });
              }
            },
            onChangeStart: (value) {
              _isSliderDraging = true;
            },
            onChangeEnd: (value) {
              if (_isSliderDraging) {
                widget.controller.player.seek(
                  Duration(milliseconds: value.toInt()),
                );
                _isSliderDraging = false;
              }
            },
          )),
    );
  }
}
