import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/watch/video_controller.dart';
import 'package:miru_app/pages/watch/widgets/playlist.dart';
import 'package:miru_app/pages/watch/widgets/video/video_player_content.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/widgets/platform_widget.dart';

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
  late VideoPlayerController _c;

  @override
  void initState() {
    _c = Get.put(
      VideoPlayerController(
        title: widget.title,
        playList: widget.playList,
        detailUrl: widget.detailUrl,
        playIndex: widget.playerIndex,
        episodeGroupId: widget.episodeGroupId,
        runtime: widget.runtime,
      ),
      tag: widget.title,
    );
    super.initState();
  }

  @override
  void dispose() {
    _c.player.dispose();
    Get.delete<VideoPlayerController>(tag: widget.title);
    super.dispose();
  }

  _buildContent() {
    return Obx(() {
      final maxWidth = MediaQuery.of(context).size.width;
      return WillPopScope(
        onWillPop: () async {
          await _c.onExit();
          return true;
        },
        child: Row(
          children: [
            AnimatedContainer(
              onEnd: () {
                _c.isOpenSidebar.value = _c.showPlayList.value;
              },
              width: _c.showPlayList.value
                  ? MediaQuery.of(context).size.width - 300
                  : maxWidth,
              duration: const Duration(milliseconds: 120),
              child: Stack(
                children: [
                  VideoPlayerConten(tag: widget.title),
                  // 消息弹出
                  if (_c.cuurentMessageWidget.value != null)
                    Positioned(
                      left: 0,
                      bottom: 100,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        constraints: BoxConstraints(
                          maxHeight: 200,
                          maxWidth: maxWidth,
                        ),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          child: _c.cuurentMessageWidget.value!,
                        ),
                      ).animate().fade(),
                    ),
                ],
              ),
            ),
            if (_c.isOpenSidebar.value)
              Expanded(
                child: PlayList(
                  selectIndex: _c.index.value,
                  list: widget.playList.map((e) => e.name).toList(),
                  title: widget.title,
                  onChange: (value) {
                    _c.index.value = value;
                    _c.showPlayList.value = false;
                  },
                ),
              )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: (context) => Scaffold(body: _buildContent()),
      desktopBuilder: ((context) => _buildContent()),
    );
  }
}
