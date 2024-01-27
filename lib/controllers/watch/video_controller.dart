// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/data/providers/bt_server_provider.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/log.dart';
import 'package:miru_app/utils/request.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/views/dialogs/bt_dialog.dart';
import 'package:miru_app/controllers/home_controller.dart';
import 'package:miru_app/controllers/main_controller.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/bt_server.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/layout.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:crypto/crypto.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';

class VideoPlayerController extends GetxController {
  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playIndex;
  final int episodeGroupId;
  final ExtensionService runtime;
  final String anilistID;

  VideoPlayerController({
    required this.title,
    required this.playList,
    required this.detailUrl,
    required this.playIndex,
    required this.episodeGroupId,
    required this.runtime,
    required this.anilistID,
  });

  final player = Player();
  late final videoController = VideoController(player);
  final showPlayList = false.obs;
  final isOpenSidebar = false.obs;
  final isFullScreen = false.obs;
  late final index = playIndex.obs;

  // 快捷键
  late final keyboardShortcuts = <KeyboardKey, VoidCallback>{
    LogicalKeyboardKey.escape: () {
      if (isFullScreen.value) {
        WindowManager.instance.setFullScreen(false);
      }
      RouterUtils.pop();
    },
    LogicalKeyboardKey.keyF: () => toggleFullscreen(),
    LogicalKeyboardKey.mediaPlay: () => player.play(),
    LogicalKeyboardKey.mediaPause: () => player.pause(),
    LogicalKeyboardKey.mediaPlayPause: () => player.playOrPause(),
    LogicalKeyboardKey.mediaTrackNext: () => player.next(),
    LogicalKeyboardKey.mediaTrackPrevious: () => player.previous(),
    LogicalKeyboardKey.space: () => player.playOrPause(),
    LogicalKeyboardKey.keyJ: () {
      final rate = player.state.position +
          Duration(
            milliseconds:
                (MiruStorage.getSetting(SettingKey.keyJ) * 1000).toInt(),
          );
      player.seek(rate);
    },
    LogicalKeyboardKey.keyI: () {
      final rate = player.state.position +
          Duration(
              milliseconds:
                  (MiruStorage.getSetting(SettingKey.keyI) * 1000).toInt());
      player.seek(rate);
    },
    LogicalKeyboardKey.arrowLeft: () {
      final rate = player.state.position +
          Duration(
              milliseconds:
                  (MiruStorage.getSetting(SettingKey.arrowLeft) * 1000)
                      .toInt());
      player.seek(rate);
    },
    LogicalKeyboardKey.arrowRight: () {
      final rate = player.state.position +
          Duration(
              milliseconds:
                  (MiruStorage.getSetting(SettingKey.arrowRight) * 1000)
                      .toInt());
      player.seek(rate);
    },
    LogicalKeyboardKey.arrowUp: () {
      final volume = player.state.volume + 5.0;
      player.setVolume(volume.clamp(0.0, 100.0));
    },
    LogicalKeyboardKey.arrowDown: () {
      final volume = player.state.volume - 5.0;
      player.setVolume(volume.clamp(0.0, 100.0));
    },
  };

  // 字幕
  final subtitles = <SubtitleTrack>[].obs;

  // 画质
  final currentQality = "".obs;
  final qualityMap = <String, String>{};

  // 是否已经自动跳转到上次播放进度
  bool _isAutoSeekPosition = false;

  // 信息列队
  final messageQueue = <Message>[];
  final Rx<Widget?> cuurentMessageWidget = Rx(null);

  // 播放速度
  final currentSpeed = 1.0.obs;
  final speedList = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];

  // torrent 媒体文件
  final torrentMediaFileList = <String>[].obs;
  final currentTorrentFile = ''.obs;
  String _torrenHash = "";

  // 调用 watch 方法获取到的数据
  final Rx<ExtensionBangumiWatch?> watchData = Rx(null);

  @override
  void onInit() async {
    if (Platform.isAndroid) {
      // 切换到横屏
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    if (player.platform is NativePlayer) {
      await (player.platform as dynamic).setProperty('cache', 'yes');
      await (player.platform as dynamic)
          .setProperty('demuxer-readahead-secs', '20');
      await (player.platform as dynamic)
          .setProperty('demuxer-max-bytes', '30MiB');
    }
    play();

    // 切换剧集
    ever(index, (callback) {
      play();
    });

    // 切换倍速
    ever(currentSpeed, (callback) {
      player.setRate(callback);
    });

    // 显示剧集列表
    ever(showPlayList, (callback) {
      if (!showPlayList.value) {
        isOpenSidebar.value = false;
      }
    });

    // 自动切换下一集
    player.stream.completed.listen((event) {
      if (!event) {
        return;
      }
      if (index.value == playList.length - 1) {
        sendMessage(Message(Text('video.play-complete'.i18n)));
        return;
      }
      if (!player.state.buffering) {
        index.value++;
      }
    });

    //讀取現在的畫質
    player.stream.height.listen((event) async {
      if (player.state.width != null) {
        final width = player.state.width;
        currentQality.value = "${width}x$event";
      }
    });

    // 自动恢复上次播放进度
    player.stream.duration.listen((event) async {
      if (_isAutoSeekPosition || event.inSeconds == 0) {
        return;
      }

      // 获取上次播放进度
      final history = await DatabaseService.getHistoryByPackageAndUrl(
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
    player.stop();
    // 如果已经 delete 当前 controller
    if (!Get.isRegistered<VideoPlayerController>(tag: title)) {
      return;
    }

    try {
      watchData.value = null;
      subtitles.clear();
      final playUrl = playList[index.value].url;
      watchData.value = await runtime.watch(playUrl) as ExtensionBangumiWatch;

      if (watchData.value!.type == ExtensionWatchBangumiType.torrent) {
        if (Get.find<MainController>().btServerisRunning.value == false) {
          await BTServerUtils.startServer();
        }
        sendMessage(
          Message(
            Text('video.torrent-downloading'.i18n),
          ),
        );
        // 下载 torrent
        final torrentFile = path.join(
          MiruDirectory.getCacheDirectory,
          'temp.torrent',
        );
        await dio.download(watchData.value!.url, torrentFile);
        final file = File(torrentFile);
        _torrenHash = await BTServerApi.addTorrent(file.readAsBytesSync());

        final files = await BTServerApi.getFileList(_torrenHash);

        torrentMediaFileList.clear();

        for (final file in files) {
          if (_isSubtitle(file)) {
            subtitles.add(
              SubtitleTrack.uri(
                '${BTServerApi.baseApi}/torrent/$_torrenHash/$file',
                title: path.basename(file),
              ),
            );
          } else {
            torrentMediaFileList.add(file);
          }
        }

        playTorrentFile(torrentMediaFileList.first);
      } else {
        getQuality();
        await player.open(
          Media(watchData.value!.url, httpHeaders: watchData.value!.headers),
        );
        if (watchData.value!.audioTrack != null) {
          await player.setAudioTrack(
            AudioTrack.uri(watchData.value!.audioTrack!),
          );
        }
      }

      // 添加来自扩展的字幕
      subtitles.addAll(
        (watchData.value!.subtitles ?? []).map(
          (e) => SubtitleTrack.uri(
            e.url,
            language: e.language,
            title: e.title,
          ),
        ),
      );
      player.setSubtitleTrack(SubtitleTrack.no());
    } catch (e) {
      // 如果是 启动 bt server 失败
      if (e is StartServerException) {
        if (Platform.isAndroid) {
          await showDialog(
            context: currentContext,
            builder: (context) => const BTDialog(),
          );
        } else {
          await fluent.showDialog(
            context: currentContext,
            builder: (context) => const BTDialog(),
          );
        }

        // 延时 3 秒再重试
        await Future.delayed(const Duration(seconds: 3));
        play();
        return;
      }
      sendMessage(
        Message(
          Text(e.toString()),
          time: const Duration(seconds: 5),
        ),
      );
      rethrow;
    }
  }

  getQuality() async {
    final url = watchData.value!.url;
    final headers = watchData.value!.headers;
    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: headers,
        ),
      );
      final playList = await HlsPlaylistParser.create().parseString(
        Uri.parse(url),
        response.data,
      ) as HlsMasterPlaylist;
      List<String> urlList =
          playList.mediaPlaylistUrls.map((e) => e.toString()).toList();
      final resolution = playList.variants
          .map((it) => "${it.format.width}x${it.format.height}");
      logger.info("get sources");
      qualityMap.addAll(Map.fromIterables(resolution, urlList));
    } catch (error) {
      logger.severe(error);
    }
  }

  playTorrentFile(String file) {
    currentTorrentFile.value = file;
    (player.platform as NativePlayer).setProperty("network-timeout", "60");
    player.open(Media('${BTServerApi.baseApi}/torrent/$_torrenHash/$file'));
  }

  toggleFullscreen() async {
    await WindowManager.instance.setFullScreen(!isFullScreen.value);
    isFullScreen.value = !isFullScreen.value;
  }

  switchQuality(String qualityUrl) async {
    final currentSecond = player.state.position.inSeconds;
    final headers = watchData.value!.headers;
    await player.open(
      Media(qualityUrl, httpHeaders: headers),
    );
    //跳轉到切換之前的時間
    Timer.periodic(const Duration(seconds: 1), (timer) {
      player.seek(Duration(seconds: currentSecond));
      if (player.state.position.inSeconds == currentSecond) {
        timer.cancel();
      }
    });
  }

  onExit() async {
    if (_torrenHash.isNotEmpty) {
      BTServerApi.removeTorrent(_torrenHash);
    }

    if (player.state.duration.inSeconds == 0) {
      return;
    }

    final tempDir = MiruDirectory.getCacheDirectory;
    final coverDir = path.join(tempDir, 'history_cover');
    Directory(coverDir).createSync(recursive: true);
    final epName = playList[index.value].name;
    final filename = '${title}_$epName';
    final file = File(
        path.join(coverDir, md5.convert(utf8.encode(filename)).toString()));
    if (file.existsSync()) {
      file.deleteSync(recursive: true);
    }

    player.screenshot().then((value) {
      file.writeAsBytes(value!).then(
        (value) async {
          debugPrint("save.. ${value.path}");
          await DatabaseService.putHistory(
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

  _isSubtitle(String file) {
    return file.endsWith('.srt') ||
        file.endsWith('.vtt') ||
        file.endsWith(".ass");
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
    if (MiruStorage.getSetting(SettingKey.autoTracking) && anilistID != "") {
      AniListProvider.editList(
        status: AnilistMediaListStatus.current,
        progress: playIndex + 1,
        mediaId: anilistID,
      );
    }

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
