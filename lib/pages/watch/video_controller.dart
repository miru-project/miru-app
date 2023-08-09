import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/pages/home/controller.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/i18n.dart';
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
  late final VideoController videoController = VideoController(player);
  final showPlayList = false.obs;
  final isOpenSidebar = false.obs;
  final isFullScreen = false.obs;
  late final index = playIndex.obs;

  // 是否已经自动跳转到上次播放进度
  bool _isAutoSeekPosition = false;

  List<Message> messageQueue = <Message>[];

  final Rx<Widget?> cuurentMessageWidget = Rx(null);

  @override
  void onInit() {
    if (Platform.isAndroid) {
      // 切换到横屏
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    play();
    ever(index, (callback) {
      play();
    });
    ever(showPlayList, (callback) {
      if (!showPlayList.value) {
        isOpenSidebar.value = false;
      }
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
      final playUrl = playList[index.value].url;
      final m3u8Url =
          (await runtime.watch(playUrl) as ExtensionBangumiWatch).url;
      player.open(Media(m3u8Url));
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
      // 切换回竖屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
    }
    super.onClose();
  }
}

class Message {
  final Widget child;
  final Duration time;

  Message(this.child, {this.time = const Duration(seconds: 3)});
}
