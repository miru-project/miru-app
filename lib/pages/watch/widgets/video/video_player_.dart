import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/pages/home/controller.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screenshot/screenshot.dart';
import '../playlist.dart' as p;
import 'package:path/path.dart' as path;

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    Key? key,
    required this.playList,
    required this.runtime,
    required this.episodeGroupId,
    required this.playerIndex,
    required this.title,
    required this.detailUrl,
  }) : super(key: key);

  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playerIndex;
  final int episodeGroupId;
  final ExtensionRuntime runtime;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late final _player = Player();
  late final _controller = VideoController(_player);
  late final ScreenshotController _screenshotController =
      ScreenshotController();
  late int _playerIndex = widget.playerIndex;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isFullScreen = false;
  bool _showControl = false;
  bool _showPlayList = false;
  bool _openSidebar = false;
  // 是否是进度条拖动
  bool _isSeeking = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String _error = '';

  @override
  void initState() {
    if (Platform.isAndroid) {
      // 切换到横屏
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _play();
    _player.stream.playing.listen((event) {
      setState(() {
        _isPlaying = event;
      });
    });
    _player.stream.duration.listen((event) {
      setState(() {
        _duration = event;
      });
    });
    _player.stream.position.listen((event) {
      if (!_isSeeking) {
        setState(() {
          _position = event;
        });
      }
    });
    _player.stream.error.listen((event) {
      if (event.toString().isNotEmpty) {
        setState(() {
          _error = event.toString();
        });
      }
    });
    _player.stream.completed.listen((event) {
      if (_playerIndex == widget.playList.length - 1) {
        if (Platform.isAndroid) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('video.play-complete'.i18n),
          ));
          return;
        }
        fluent.displayInfoBar(context, builder: ((context, close) {
          return fluent.InfoBar(title: Text('video.play-complete'.i18n));
        }));
        return;
      }
      if (!_isLoading) {
        _togglePlayIndex(index: _playerIndex + 1);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      // 切换回竖屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
    }
    _player.dispose();
    super.dispose();
  }

  _addHistory() async {
    if (_position.inSeconds < 1) {
      return;
    }
    final tempDir = await MiruDirectory.getCacheDirectory;
    final coverDir = path.join(tempDir, 'history_cover');
    Directory(coverDir).createSync(recursive: true);
    final epName = widget.playList[_playerIndex].name;
    final filename = '${widget.title}_$epName';
    final file = File(path.join(coverDir, filename));
    if (file.existsSync()) {
      file.deleteSync(recursive: true);
    }

    final coverPath = await _screenshotController.captureAndSave(
      coverDir,
      fileName: filename,
    );
    await DatabaseUtils.putHistory(
      History()
        ..url = widget.detailUrl
        ..cover = coverPath!
        ..episodeGroupId = widget.episodeGroupId
        ..package = widget.runtime.extension.package
        ..type = widget.runtime.extension.type
        ..episodeId = _playerIndex
        ..episodeTitle = epName
        ..title = widget.title,
    );
    await Get.find<HomePageController>().onRefresh();
  }

  _play() async {
    _isLoading = true;
    try {
      final playUrl = widget.playList[_playerIndex].url;
      final m3u8Url =
          (await widget.runtime.watch(playUrl) as ExtensionBangumiWatch).url;
      debugPrint(m3u8Url);
      _player.open(Media(m3u8Url));
      _player.stream.buffering.listen((event) {
        debugPrint(event.toString());
        _isLoading = event;
      });
    } catch (e) {
      debugPrint(e.toString());
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  _togglePlayIndex({int index = 0}) async {
    setState(() {
      _playerIndex = index;
    });
    _play();
  }

  // 头部控制面板
  _playerControlPanelHeader() {
    return PlatformWidget(
      androidWidget: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
                await _addHistory();
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${widget.title} - ${widget.playList[_playerIndex].name}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
      desktopWidget: Container(
        height: 50,
        margin: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: fluent.Acrylic(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${widget.title} - ${widget.playList[_playerIndex].name}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // 关闭按钮
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                onTap: () async {
                  await _addHistory();
                  await WindowManager.instance.setFullScreen(false);
                  router.pop();
                },
                child: const fluent.Acrylic(
                  child: Padding(
                    padding: EdgeInsets.all(11),
                    child: Icon(
                      fluent.FluentIcons.clear,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 底部控制面板
  _playerControlPanel() {
    final content = PlatformWidget(
      androidWidget: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
              ),
              onPressed: () {
                if (_playerIndex == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('video.already-first'.i18n),
                  ));
                  return;
                }
                _togglePlayIndex(index: _playerIndex - 1);
              },
            ),

            // 暂停播放按钮
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.white,
              ),
              onPressed: () {
                _player.playOrPause();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.skip_next,
                color: Colors.white,
              ),
              onPressed: () {
                if (_playerIndex == widget.playList.length - 1) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('video.already-last'.i18n),
                  ));
                  return;
                }
                _togglePlayIndex(index: _playerIndex + 1);
              },
            ),
            Expanded(
              child: Slider(
                label: _position.toString().split('.')[0],
                value: _position.inMicroseconds.toDouble(),
                max: _duration.inMicroseconds.toDouble(),
                onChangeEnd: (value) {
                  _player.seek(_position);
                  setState(() {
                    _isSeeking = false;
                  });
                },
                onChangeStart: (value) {
                  setState(() {
                    _isSeeking = true;
                  });
                },
                onChanged: (double value) {
                  setState(() {
                    _position = Duration(microseconds: value.toInt());
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            // 进度指示器
            Text(
              '${_position.toString().split('.')[0]} / ${_duration.toString().split('.')[0]}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_openSidebar) {
                    _showPlayList = false;
                  }
                  _openSidebar = !_openSidebar;
                });
              },
              icon: const Icon(
                Icons.list,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
      desktopWidget: Row(
        children: [
          fluent.IconButton(
            icon: const Icon(fluent.FluentIcons.previous),
            onPressed: () {
              if (_playerIndex == 0) {
                fluent.displayInfoBar(context, builder: ((context, close) {
                  return fluent.InfoBar(
                      title: Text('video.already-first'.i18n));
                }));
                return;
              }
              _togglePlayIndex(index: _playerIndex - 1);
            },
          ),
          fluent.IconButton(
            icon: Icon(_isPlaying
                ? fluent.FluentIcons.pause
                : fluent.FluentIcons.play),
            onPressed: () {
              _player.playOrPause();
            },
          ),
          fluent.IconButton(
            icon: const Icon(fluent.FluentIcons.next),
            onPressed: () {
              if (_playerIndex == widget.playList.length - 1) {
                fluent.displayInfoBar(context, builder: ((context, close) {
                  return fluent.InfoBar(title: Text('video.already-last'.i18n));
                }));
                return;
              }
              _togglePlayIndex(index: _playerIndex + 1);
            },
          ),
          const SizedBox(width: 8),
          Text(
            _position.toString().split('.')[0],
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: fluent.Slider(
              label: _position.toString().split('.')[0],
              value: _position.inMicroseconds.toDouble(),
              max: _duration.inMicroseconds.toDouble(),
              onChangeEnd: (value) {
                _player.seek(_position);
                setState(() {
                  _isSeeking = false;
                });
              },
              onChangeStart: (value) {
                setState(() {
                  _isSeeking = true;
                });
              },
              onChanged: (double value) {
                setState(() {
                  _position = Duration(microseconds: value.toInt());
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _duration.toString().split('.')[0],
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          fluent.IconButton(
              icon: Icon(_isFullScreen
                  ? fluent.FluentIcons.back_to_window
                  : fluent.FluentIcons.full_screen),
              onPressed: () async {
                await WindowManager.instance.setFullScreen(!_isFullScreen);
                setState(() {
                  _isFullScreen = !_isFullScreen;
                });
              }),
          fluent.IconButton(
              icon: const Icon(fluent.FluentIcons.bulleted_list),
              onPressed: () {
                setState(() {
                  if (_openSidebar) {
                    _showPlayList = false;
                  }
                  _openSidebar = !_openSidebar;
                });
              }),
          fluent.IconButton(
              icon: const Icon(fluent.FluentIcons.more), onPressed: () {})
        ],
      ),
    );

    return PlatformWidget(
      androidWidget: content,
      desktopWidget: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 40,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        clipBehavior: Clip.antiAlias,
        width: double.infinity,
        child: fluent.Acrylic(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: content,
          ),
        ),
      ),
    );
  }

// 中间控制面板
  _playerControlPanelCenter() {
    if (_error.isNotEmpty) {
      return SizedBox.expand(
        child: Center(
          child: Text(
            _error,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    if (_isLoading) {
      return const Center(
        child: ProgressRing(),
      );
    }
    return const SizedBox.expand();
  }

  @override
  Widget build(BuildContext context) {
    final content = WillPopScope(
      onWillPop: () async {
        await _addHistory();
        debugPrint("onWillPop");
        return true;
      },
      child: LayoutBuilder(builder: (context, container) {
        return Row(
          children: [
            AnimatedContainer(
              width:
                  _openSidebar ? container.maxWidth - 300 : container.maxWidth,
              duration: const Duration(milliseconds: 120),
              curve: Curves.ease,
              onEnd: () {
                setState(() {
                  if (_openSidebar) {
                    _showPlayList = true;
                  }
                });
              },
              child: Stack(
                children: [
                  Screenshot(
                    controller: _screenshotController,
                    child: Video(
                      controller: _controller,
                      controls: (state) => const SizedBox.shrink(),
                    ),
                  ),
                  Positioned.fill(
                    child: MouseRegion(
                      onHover: (event) {
                        if (!_showControl) {
                          setState(() {
                            _showControl = true;
                          });
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() {
                                _showControl = false;
                              });
                            }
                          });
                        }
                      },
                      child: Column(
                        children: [
                          if (_showControl || _isLoading || !_isPlaying)
                            _playerControlPanelHeader(),
                          Expanded(
                            child: _isFullScreen
                                ? _playerControlPanelCenter()
                                : DragToMoveArea(
                                    child: _playerControlPanelCenter(),
                                  ),
                          ),
                          if (_showControl || _isLoading || !_isPlaying)
                            _playerControlPanel()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 播放列表
            if (_showPlayList)
              Expanded(
                child: p.PlayList(
                  selectIndex: _playerIndex,
                  list: widget.playList.map((e) => e.name).toList(),
                  title: widget.title,
                  onChange: (value) {
                    _togglePlayIndex(index: value);
                  },
                ),
              )
          ],
        );
      }),
    );
    return PlatformWidget(
      androidWidget: Scaffold(
        body: content,
      ),
      desktopWidget: content,
    );
  }
}
