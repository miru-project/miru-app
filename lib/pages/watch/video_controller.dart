import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/pages/home/controller.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/layout.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;

class VideoPlayerController extends GetxController {
  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playIndex;
  final int episodeGroupId;
  final ExtensionRuntime runtime;

  VideoPlayerController({
    required this.title,
    required this.playList,
    required this.detailUrl,
    required this.playIndex,
    required this.episodeGroupId,
    required this.runtime,
  });

  final player = Player();
  late final videoController = VideoController(player);
  final showPlayList = false.obs;
  final isOpenSidebar = false.obs;
  final isFullScreen = false.obs;
  late final index = playIndex.obs;
  final subtitles = <ExtensionBangumiWatchSubtitle>[].obs;
  final selectedSubtitle = 0.obs;

  // 是否已经自动跳转到上次播放进度
  bool _isAutoSeekPosition = false;

  final messageQueue = <Message>[];

  final Rx<Widget?> cuurentMessageWidget = Rx(null);

  final speed = 1.0.obs;

  @override
  void onInit() {
    if (Platform.isAndroid) {
      // 切换到横屏
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    play();

    // 切换剧集
    ever(index, (callback) {
      play();
    });

    // 切换倍速
    ever(speed, (callback) {
      player.setRate(callback);
    });

    // 显示剧集列表
    ever(showPlayList, (callback) {
      if (!showPlayList.value) {
        isOpenSidebar.value = false;
      }
    });

    // 切换字幕
    ever(selectedSubtitle, (callback) {
      if (callback == -1) {
        player.setSubtitleTrack(SubtitleTrack.no());
        return;
      }
      if (callback == -2) {
        // 选择文件 srt 或者 vtt
        FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['srt', 'vtt'],
        ).then((value) {
          if (value == null) {
            selectedSubtitle.value = -1;
            return;
          }

          // 读取文件
          final data = File(value.files.first.path!).readAsStringSync();
          player.setSubtitleTrack(SubtitleTrack.data(data));
          sendMessage(
            Message(
              Text(
                FlutterI18n.translate(
                  cuurentContext,
                  "video.subtitle-change",
                  translationParams: {"title": value.files.first.name},
                ),
              ),
            ),
          );
        });
        return;
      }
      player.setSubtitleTrack(
        SubtitleTrack.uri(subtitles[callback].url),
      );
      sendMessage(
        Message(
          Text(
            FlutterI18n.translate(
              cuurentContext,
              "video.subtitle-change",
              translationParams: {"title": subtitles[callback].title},
            ),
          ),
        ),
      );
    });

    // 自动切换下一集
    player.stream.completed.listen((event) {
      if (index.value == playList.length - 1 && event) {
        sendMessage(Message(Text('video.play-complete'.i18n)));
        return;
      }
      if (!player.state.buffering) {
        index.value++;
      }
    });

    // 自动恢复上次播放进度
    player.stream.duration.listen((event) async {
      if (_isAutoSeekPosition || event.inSeconds == 0) {
        return;
      }
      // 获取上次播放进度
      final history = await DatabaseUtils.getHistoryByPackageAndUrl(
        runtime.extension.package,
        detailUrl,
      );

      if (history != null &&
          history.progress.isNotEmpty &&
          history.episodeId == index.value &&
          history.episodeGroupId == episodeGroupId) {
        _isAutoSeekPosition = true;
        player.seek(Duration(seconds: int.parse(history.progress)));
        sendMessage(Message(Text('video.resume-last-playback'.i18n)));
      }
    });

    // 错误监听
    player.stream.error.listen((event) {
      sendMessage(Message(Text(event)));
    });

    super.onInit();
  }

  play() async {
    try {
      subtitles.clear();
      selectedSubtitle.value = -1;
      final playUrl = playList[index.value].url;
      final watchData = await runtime.watch(playUrl) as ExtensionBangumiWatch;
      player.open(Media(watchData.url, httpHeaders: watchData.headers));
      subtitles.addAll(watchData.subtitles ?? []);
    } catch (e) {
      debugPrint(e.toString());
      sendMessage(
        Message(
          Text(e.toString()),
          time: const Duration(seconds: 5),
        ),
      );
    }
  }

  toggleFullscreen() async {
    await WindowManager.instance.setFullScreen(!isFullScreen.value);
    isFullScreen.value = !isFullScreen.value;
  }

  addHistory() async {
    if (player.state.duration.inSeconds == 0) {
      return;
    }

    final tempDir = await MiruDirectory.getCacheDirectory;
    final coverDir = path.join(tempDir, 'history_cover');
    Directory(coverDir).createSync(recursive: true);
    final epName = playList[index.value].name;
    final filename = '${title}_$epName';
    final file = File(path.join(coverDir, filename));
    if (file.existsSync()) {
      file.deleteSync(recursive: true);
    }

    player.screenshot().then((value) {
      file.writeAsBytes(value!).then(
        (value) async {
          debugPrint("save..");
          await DatabaseUtils.putHistory(
            History()
              ..url = detailUrl
              ..cover = value.path
              ..episodeGroupId = episodeGroupId
              ..package = runtime.extension.package
              ..type = runtime.extension.type
              ..episodeId = index.value
              ..episodeTitle = epName
              ..title = title
              ..progress = player.state.position.inSeconds.toString()
              ..totalProgress = player.state.duration.inSeconds.toString(),
          );
          await Get.find<HomePageController>().onRefresh();
        },
      );
    });
  }

  sendMessage(Message message) {
    messageQueue.add(message);

    if (messageQueue.length == 1) {
      _processNextMessage();
    }
  }

  _processNextMessage() async {
    if (messageQueue.isEmpty) {
      cuurentMessageWidget.value = null;
      return;
    }

    final message = messageQueue.first;
    cuurentMessageWidget.value = message.child;
    // 等待消息显示完毕
    await Future.delayed(message.time);
    messageQueue.removeAt(0);
    _processNextMessage();
  }

  @override
  void onClose() {
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      // 如果是平板则不改变
      if (LayoutUtils.isTablet) {
        return;
      }
      // 切换回竖屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.onClose();
  }
}

class Message {
  final Widget child;
  final Duration time;
  Message(this.child, {this.time = const Duration(seconds: 3)});
}
