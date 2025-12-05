// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:dio/dio.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:miru_app/views/pages/watch/video/video_player_sidebar.dart';
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

  // 播放器
  final player = Player();
  late final videoController = VideoController(player);

  final showSidebar = false.obs;
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
  final currentQuality = "".obs;
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
  ExtensionBangumiWatch? watchData;
  final error = "".obs;
  final isGettingWatchData = true.obs;

  // 字幕配置
  final subtitleFontSize = 46.0.obs;
  final subtitleFontWeight = FontWeight.normal.obs;
  final subtitleTextAlign = TextAlign.center.obs;
  final subtitleFontColor = Colors.white.obs;
  final subtitleBackgroundColor = Colors.black.obs;
  final subtitleBackgroundOpacity = 0.5.obs;

  // 侧边栏初始化 tab
  final initSidebarTab = SidebarTab.episodes.obs;

  // 播放方式
  final playMode = PlaylistMode.none.obs;

  // 进度
  final position = Duration.zero.obs;

  // 总时长
  final duration = Duration.zero.obs;

  // 播放状态
  final isPlaying = false.obs;

  // dlna 设备
  final dlnaDevice = Rx<DLNADevice?>(null);

  // 定时器
  Timer? _dlnaTimer;

  @override
  void onInit() async {
    if (Platform.isAndroid) {
      // 切换到横屏
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      );
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await AutoOrientation.landscapeAutoMode(forceSensor: true);
    }
    _initSettings();
    _initPlayer();
    play();
    super.onInit();
  }

  _initSettings() {
    subtitleFontSize.value =
        MiruStorage.getSetting(SettingKey.subtitleFontSize);
    subtitleFontColor.value = Color(
      MiruStorage.getSetting(
        SettingKey.subtitleFontColor,
      ),
    );
    final fontWeightText =
        MiruStorage.getSetting(SettingKey.subtitleFontWeight);
    subtitleFontWeight.value =
        fontWeightText == 'bold' ? FontWeight.bold : FontWeight.normal;
    subtitleBackgroundColor.value = Color(MiruStorage.getSetting(
      SettingKey.subtitleBackgroundColor,
    ));
    subtitleBackgroundOpacity.value = MiruStorage.getSetting(
      SettingKey.subtitleBackgroundOpacity,
    );
    subtitleTextAlign.value = TextAlign.values[MiruStorage.getSetting(
      SettingKey.subtitleTextAlign,
    )];

    ever(subtitleFontSize, (callback) {
      MiruStorage.setSetting(SettingKey.subtitleFontSize, callback);
    });
    ever(subtitleFontColor, (callback) {
      MiruStorage.setSetting(
        SettingKey.subtitleFontColor,
        callback.value,
      );
    });
    ever(subtitleFontWeight, (callback) {
      MiruStorage.setSetting(
        SettingKey.subtitleFontWeight,
        callback == FontWeight.bold ? 'bold' : 'normal',
      );
    });
    ever(subtitleBackgroundColor, (callback) {
      MiruStorage.setSetting(
        SettingKey.subtitleBackgroundColor,
        callback.value,
      );
    });
    ever(subtitleBackgroundOpacity, (callback) {
      MiruStorage.setSetting(
        SettingKey.subtitleBackgroundOpacity,
        callback,
      );
    });
    ever(subtitleTextAlign, (callback) {
      MiruStorage.setSetting(
        SettingKey.subtitleTextAlign,
        callback.index,
      );
    });
  }

  _initPlayer() {
    // 切换剧集
    ever(index, (callback) {
      play();
    });

    // 切换倍速
    ever(currentSpeed, (callback) {
      player.setRate(callback);
    });

    // 显示剧集列表
    ever(showSidebar, (callback) {
      if (!showSidebar.value) {
        isOpenSidebar.value = false;
      }
    });

    // 自动切换下一集
    player.stream.completed.listen((event) {
      if (!event || playMode.value == PlaylistMode.single) {
        return;
      }
      if (playMode.value == PlaylistMode.loop) {
        player.seek(Duration.zero);
        player.play();
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

    // 讀取現在的畫質
    player.stream.height.listen((event) async {
      if (player.state.width != null) {
        final width = player.state.width;
        currentQuality.value = "${width}x$event";
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

    // 监听 track
    player.stream.tracks.listen((event) {
      if (event.subtitle.isEmpty) {
        return;
      }

      final latestLanguageSelected = MiruStorage.getSetting(
        SettingKey.subtitleLastLanguageSelected,
      );
      final latestTitleSelected = MiruStorage.getSetting(
        SettingKey.subtitleLastTitleSelected,
      );
      if (latestLanguageSelected == null && latestTitleSelected == null) {
        return;
      }

      final subtitle = [...event.subtitle, ...subtitles].firstWhereOrNull(
        (element) {
          if (element.id == "no" || element.id == "auto") {
            return false;
          }
          return element.language == latestLanguageSelected ||
              element.title == latestTitleSelected;
        },
      );

      if (subtitle != null) {
        player.setSubtitleTrack(subtitle);
      }
    });

    // 总时长监听
    player.stream.duration.listen((event) {
      if (dlnaDevice.value != null) {
        return;
      }
      duration.value = event;
    });

    // 监听播放状态
    player.stream.playing.listen((event) {
      if (dlnaDevice.value != null) {
        return;
      }
      isPlaying.value = event;
    });

    // 监听进度
    player.stream.position.listen((event) {
      if (dlnaDevice.value != null) {
        return;
      }
      position.value = event;
    });

    // 错误监听
    player.stream.error.listen((event) {
      sendMessage(Message(Text(event)));
    });
  }

  // 播放
  play() async {
    // 如果已经 delete 当前 controller
    if (!Get.isRegistered<VideoPlayerController>(tag: title)) {
      return;
    }
    player.stop();
    isGettingWatchData.value = true;
    try {
      await getWatchData();
    } catch (e) {
      logger.severe(e);
      error.value = e.toString();
      return;
    }

    try {
      if (watchData!.type == ExtensionWatchBangumiType.torrent) {
        try {
          await getTorrentMediaFile();
        } catch (e) {
          logger.severe(e);
          error.value = e.toString();
          return;
        }

        playTorrentFile(torrentMediaFileList.first);
      } else {
        if (dlnaDevice.value != null) {
          await dlnaDevice.value!.setUrl(watchData!.url);
          await dlnaDevice.value!.play();
        } else {
          getQuality();
          await player.open(
            Media(watchData!.url, httpHeaders: watchData!.headers),
          );
          if (watchData!.audioTrack != null) {
            await player.setAudioTrack(
              AudioTrack.uri(watchData!.audioTrack!),
            );
          }
        }
      }
      isGettingWatchData.value = false;
      // 添加来自扩展的字幕
      subtitles.addAll(
        (watchData!.subtitles ?? []).map(
          (e) => SubtitleTrack.uri(
            e.url,
            language: e.language,
            title: e.title,
          ),
        ),
      );
      player.setSubtitleTrack(SubtitleTrack.no());
    } on StartServerException catch (_) {
      // 如果是 启动 bt server 失败
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
    } catch (e) {
      sendMessage(
        Message(
          Text(e.toString()),
          time: const Duration(seconds: 5),
        ),
      );
      rethrow;
    }
  }

  // 获取 watch 数据
  getWatchData() async {
    watchData = null;
    subtitles.clear();
    final playUrl = playList[index.value].url;
    watchData =
        await runtime.watch(playUrl, currentContext) as ExtensionBangumiWatch;
  }

  // 获取 torrent 媒体文件
  getTorrentMediaFile() async {
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
    await dio.download(watchData!.url, torrentFile);

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
  }

  // 获取画质
  getQuality() async {
    final url = watchData!.url;
    final headers = watchData!.headers;
    logger.info(url);
    final response = await dio.get(
      url,
      options: Options(
        headers: headers,
        responseType: ResponseType.stream,
      ),
    );

    // 请求判断 content-type 是否为 m3u8
    final contentType = response.headers.value('content-type')?.toLowerCase();
    if (contentType == null ||
        !contentType.contains('mpegurl') &&
            !contentType.contains('m3u8') &&
            !contentType.contains('mp2t')) {
      logger.info('not m3u8');
      return;
    }

    // 接收数据到变量
    final completer = Completer<String>();

    final stream = response.data.stream;
    final buffer = StringBuffer();

    stream.listen(
      (data) {
        buffer.write(utf8.decode(data));
      },
      onDone: () {
        final m3u8Content = buffer.toString();
        completer.complete(m3u8Content);
      },
      onError: (error) {
        completer.completeError(error);
      },
    );

    final m3u8Content = await completer.future;
    if (m3u8Content.isEmpty) {
      return;
    }
    late HlsPlaylist playlist;
    try {
      playlist = await HlsPlaylistParser.create().parseString(
        response.realUri,
        m3u8Content,
      );
    } on ParserException catch (e) {
      logger.severe(e);
      return;
    }

    if (playlist is HlsMasterPlaylist) {
      final urlList = playlist.mediaPlaylistUrls
          .map(
            (e) => e.toString(),
          )
          .toList();
      final resolution = playlist.variants.map(
        (it) => "${it.format.width}x${it.format.height}",
      );
      qualityMap.addAll(
        Map.fromIterables(
          resolution,
          urlList,
        ),
      );
    }
  }

  // 播放 torrent 媒体文件
  playTorrentFile(String file) {
    currentTorrentFile.value = file;
    (player.platform as NativePlayer).setProperty("network-timeout", "60");
    player.open(Media('${BTServerApi.baseApi}/torrent/$_torrenHash/$file'));
  }

  // 切换全屏
  toggleFullscreen() async {
    await WindowManager.instance.setFullScreen(!isFullScreen.value);
    isFullScreen.value = !isFullScreen.value;
  }

  // 切换画质
  switchQuality(String qualityUrl) async {
    final currentSecond = player.state.position.inSeconds;
    final headers = watchData!.headers;
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

  // 设置字幕
  setSubtitleTrack(SubtitleTrack subtitle) {
    player.setSubtitleTrack(subtitle);
    MiruStorage.setSetting(
      SettingKey.subtitleLastLanguageSelected,
      subtitle.language,
    );
    MiruStorage.setSetting(
      SettingKey.subtitleLastTitleSelected,
      subtitle.title,
    );
  }

  // 保存历史记录
  _saveHistory() async {
    if (duration.value.inSeconds == 0) {
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

    final data = await player.screenshot();
    if (data == null) {
      return;
    }
    await file.writeAsBytes(data);

    logger.info('save history');

    await DatabaseService.putHistory(
      History()
        ..url = detailUrl
        ..cover = file.path
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
  }

  // 判断文件是否是字幕
  _isSubtitle(String file) {
    return file.endsWith('.srt') ||
        file.endsWith('.vtt') ||
        file.endsWith(".ass");
  }

  // 发送消息
  sendMessage(Message message) {
    messageQueue.add(message);

    if (messageQueue.length == 1) {
      _processNextMessage();
    }
  }

  // 处理消息提示
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

  // 切换侧边栏
  toggleSideBar(SidebarTab tab) {
    if (showSidebar.value) {
      showSidebar.value = false;
      return;
    }
    initSidebarTab.value = tab;
    showSidebar.value = true;
  }

  // 添加本地字幕文件
  addSubtitleFile() async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt'],
      allowMultiple: false,
    );
    if (file == null) {
      return;
    }
    final data = File(file.files.first.path!).readAsStringSync();
    subtitles.add(
      SubtitleTrack.data(
        data,
        title: file.files.first.name,
      ),
    );
  }

  // 连接 DLNA 设备
  connectDLNADevice(DLNADevice device) async {
    if (watchData == null) {
      sendMessage(Message(Text('等待视频加载'.i18n)));
      return;
    }
    final url = watchData!.url;
    dlnaDevice.value = device;
    await device.setUrl(url);
    await device.play();
    await player.stop();
    _dlnaTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getDLNAStatus();
    });
  }

  // 断开 DLNA 设备
  disconnectDLNADevice() async {
    if (dlnaDevice.value == null) {
      return;
    }
    final device = dlnaDevice.value!;
    dlnaDevice.value = null;
    device.stop();
    _dlnaTimer?.cancel();
  }

  // 获取 DLNA 播放状态
  _getDLNAStatus() async {
    final device = dlnaDevice.value;
    if (device == null) {
      return;
    }
    final transportInfo = await device.getTransportInfo();
    if (transportInfo.contains("PLAYING")) {
      isPlaying.value = true;
    } else {
      isPlaying.value = false;
    }
    final dlnaPosition = await device.position();
    final positionParser = PositionParser(dlnaPosition);
    final absTimeArr = positionParser.AbsTime.split(":");
    final absTime = Duration(
      hours: int.parse(absTimeArr[0]),
      minutes: int.parse(absTimeArr[1]),
      seconds: int.parse(absTimeArr[2]),
    );
    position.value = absTime;
    positionParser.TrackDurationInt;
    duration.value = Duration(seconds: positionParser.TrackDurationInt);
  }

  // 播放器相关操作
  playOrPause() async {
    if (dlnaDevice.value == null) {
      player.playOrPause();
      return;
    }
    if (isPlaying.value) {
      await dlnaDevice.value!.pause();
    } else {
      await dlnaDevice.value!.play();
    }
  }

  seek(Duration duration) async {
    if (dlnaDevice.value == null) {
      player.seek(duration);
      return;
    }
    final curr = await dlnaDevice.value!.position();
    final diff = duration - position.value;
    await dlnaDevice.value!.seekByCurrent(curr, diff.inSeconds);
  }

  @override
  void onClose() async {
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
      // 切换回竖屏
      if (!LayoutUtils.isTablet) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    }
    _dlnaTimer?.cancel();
    player.pause();
    try {
      await _saveHistory();
    } catch (_) {}
    player.dispose();
    logger.info('dispose video controller');
    super.onClose();
  }
}

class Message {
  final Widget child;
  final Duration time;
  Message(this.child, {this.time = const Duration(seconds: 3)});
}
