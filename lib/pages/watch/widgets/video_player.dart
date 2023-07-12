import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/main.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/pages/home/controller.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screenshot/screenshot.dart';
import 'playlist.dart' as p;
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
  late final player = Player();
  late final controller = VideoController(player);
  late final ScreenshotController screenshotController = ScreenshotController();
  late int playerIndex = widget.playerIndex;
  bool isPlaying = false;
  bool isLoading = true;
  bool isFullScreen = false;
  bool showControl = false;
  bool showPlayList = false;
  bool openSidebar = false;
  // 是否是进度条拖动
  bool isSeeking = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String error = '';

  @override
  void initState() {
    if (Platform.isAndroid) {
      // 切换到横屏
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _play();
    player.stream.playing.listen((event) {
      setState(() {
        isPlaying = event;
      });
    });
    player.stream.duration.listen((event) {
      setState(() {
        duration = event;
      });
    });
    player.stream.position.listen((event) {
      if (!isSeeking) {
        setState(() {
          position = event;
        });
      }
    });
    player.stream.error.listen((event) {
      if (event.toString().isNotEmpty) {
        setState(() {
          error = event.toString();
        });
      }
    });
    player.stream.completed.listen((event) {
      if (playerIndex == widget.playList.length - 1) {
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
      if (!isLoading) {
        _togglePlayIndex(index: playerIndex + 1);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      // 切换回竖屏
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
    }
    player.dispose();
    super.dispose();
  }

  _addHistory() async {
    if (position.inSeconds < 1) {
      return;
    }
    final tempDir = await MiruDirectory.getCacheDirectory;
    final coverDir = path.join(tempDir, 'history_cover');
    Directory(coverDir).createSync(recursive: true);
    final epName = widget.playList[playerIndex].name;
    final filename = '${widget.title}_$epName';
    final file = File(path.join(coverDir, filename));
    if (file.existsSync()) {
      file.deleteSync(recursive: true);
    }

    final coverPath = await screenshotController.captureAndSave(
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
        ..episodeId = playerIndex
        ..episodeTitle = epName
        ..title = widget.title,
    );
    await Get.find<HomePageController>().onRefresh();
  }

  _play() async {
    isLoading = true;
    try {
      final m3u8Url =
          (await widget.runtime.watch(widget.playList[playerIndex].url)).url;
      debugPrint(m3u8Url);
      player.open(Media(m3u8Url));
      player.stream.buffering.listen((event) {
        debugPrint(event.toString());
        isLoading = event;
      });
    } catch (e) {
      debugPrint(e.toString());
      error = e.toString();
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  _togglePlayIndex({int index = 0}) async {
    setState(() {
      playerIndex = index;
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
              "${widget.title} - ${widget.playList[playerIndex].name}",
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
                    "${widget.title} - ${widget.playList[playerIndex].name}",
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
                if (playerIndex == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('video.already-first'.i18n),
                  ));
                  return;
                }
                _togglePlayIndex(index: playerIndex - 1);
              },
            ),

            // 暂停播放按钮
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.white,
              ),
              onPressed: () {
                player.playOrPause();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.skip_next,
                color: Colors.white,
              ),
              onPressed: () {
                if (playerIndex == widget.playList.length - 1) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('video.already-last'.i18n),
                  ));
                  return;
                }
                _togglePlayIndex(index: playerIndex + 1);
              },
            ),
            Expanded(
              child: Slider(
                label: position.toString().split('.')[0],
                value: position.inMicroseconds.toDouble(),
                max: duration.inMicroseconds.toDouble(),
                onChangeEnd: (value) {
                  player.seek(position);
                  setState(() {
                    isSeeking = false;
                  });
                },
                onChangeStart: (value) {
                  setState(() {
                    isSeeking = true;
                  });
                },
                onChanged: (double value) {
                  setState(() {
                    position = Duration(microseconds: value.toInt());
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            // 进度指示器
            Text(
              '${position.toString().split('.')[0]} / ${duration.toString().split('.')[0]}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  if (openSidebar) {
                    showPlayList = false;
                  }
                  openSidebar = !openSidebar;
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
              if (playerIndex == 0) {
                fluent.displayInfoBar(context, builder: ((context, close) {
                  return fluent.InfoBar(
                      title: Text('video.already-first'.i18n));
                }));
                return;
              }
              _togglePlayIndex(index: playerIndex - 1);
            },
          ),
          fluent.IconButton(
            icon: Icon(
                isPlaying ? fluent.FluentIcons.pause : fluent.FluentIcons.play),
            onPressed: () {
              player.playOrPause();
            },
          ),
          fluent.IconButton(
            icon: const Icon(fluent.FluentIcons.next),
            onPressed: () {
              if (playerIndex == widget.playList.length - 1) {
                fluent.displayInfoBar(context, builder: ((context, close) {
                  return fluent.InfoBar(title: Text('video.already-last'.i18n));
                }));
                return;
              }
              _togglePlayIndex(index: playerIndex + 1);
            },
          ),
          const SizedBox(width: 8),
          Text(
            position.toString().split('.')[0],
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: fluent.Slider(
              label: position.toString().split('.')[0],
              value: position.inMicroseconds.toDouble(),
              max: duration.inMicroseconds.toDouble(),
              onChangeEnd: (value) {
                player.seek(position);
                setState(() {
                  isSeeking = false;
                });
              },
              onChangeStart: (value) {
                setState(() {
                  isSeeking = true;
                });
              },
              onChanged: (double value) {
                setState(() {
                  position = Duration(microseconds: value.toInt());
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            duration.toString().split('.')[0],
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          fluent.IconButton(
              icon: Icon(isFullScreen
                  ? fluent.FluentIcons.back_to_window
                  : fluent.FluentIcons.full_screen),
              onPressed: () async {
                await WindowManager.instance.setFullScreen(!isFullScreen);
                setState(() {
                  isFullScreen = !isFullScreen;
                });
              }),
          fluent.IconButton(
              icon: const Icon(fluent.FluentIcons.bulleted_list),
              onPressed: () {
                setState(() {
                  if (openSidebar) {
                    showPlayList = false;
                  }
                  openSidebar = !openSidebar;
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
    if (error.isNotEmpty) {
      return SizedBox.expand(
        child: Center(
          child: Text(
            error,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    if (isLoading) {
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
                  openSidebar ? container.maxWidth - 300 : container.maxWidth,
              duration: const Duration(milliseconds: 120),
              curve: Curves.ease,
              onEnd: () {
                setState(() {
                  if (openSidebar) {
                    showPlayList = true;
                  }
                });
              },
              child: Stack(
                children: [
                  Screenshot(
                    controller: screenshotController,
                    child: Video(
                      key: ValueKey(playerIndex),
                      controller: controller,
                      controls: (state) => const SizedBox.shrink(),
                    ),
                  ),
                  Positioned.fill(
                    child: MouseRegion(
                      onHover: (event) {
                        if (!showControl) {
                          setState(() {
                            showControl = true;
                          });
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() {
                                showControl = false;
                              });
                            }
                          });
                        }
                      },
                      child: Column(
                        children: [
                          if (showControl || isLoading || !isPlaying)
                            _playerControlPanelHeader(),
                          Expanded(
                            child: isFullScreen
                                ? _playerControlPanelCenter()
                                : DragToMoveArea(
                                    child: _playerControlPanelCenter(),
                                  ),
                          ),
                          if (showControl || isLoading || !isPlaying)
                            _playerControlPanel()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 播放列表
            if (showPlayList)
              Expanded(
                child: p.PlayList(
                  selectIndex: playerIndex,
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
