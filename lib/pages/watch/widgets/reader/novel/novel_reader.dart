import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/pages/watch/widgets/reader/controller.dart';
import 'package:miru_app/pages/watch/widgets/reader/novel/novel_reader_content.dart';
import 'package:miru_app/pages/watch/widgets/reader/view.dart';
import 'package:miru_app/utils/extension_runtime.dart';

class NovelReader extends StatefulWidget {
  const NovelReader({
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
  State<NovelReader> createState() => _NovelReaderState();
}

class _NovelReaderState extends State<NovelReader> {
  @override
  void initState() {
    Get.put<ReaderController<ExtensionFikushonWatch>>(
      ReaderController(
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
    Get.delete<ReaderController<ExtensionFikushonWatch>>(tag: widget.title);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReadView<ExtensionFikushonWatch>(
      widget.title,
      content: NovelReaderContent(widget.title),
      buildSettings: (context) => const Card(),
    );
    // return Obx(
    //   () => Stack(
    //     children: [
    //       MouseRegion(
    //         onHover: (event) {
    //           if (event.position.dy < 60) {
    //             _c.showControlPanel();
    //           }
    //         },
    //         child: NovelReaderContent(widget.title),
    //       ),

    //       // 点击中间显示控制面板
    //       Positioned(
    //         top: 120,
    //         bottom: 120,
    //         left: 0,
    //         right: 0,
    //         child: GestureDetector(
    //           onTap: () {
    //             // 中间点击的话 将不会定时关闭
    //             _c.isShowControlPanel.value = !_c.isShowControlPanel.value;
    //           },
    //         ),
    //       ),

    //       if (_c.isShowControlPanel.value) ...[
    //         // 顶部控制
    //         Positioned(
    //           child: ControlPanelHeader<ExtensionFikushonWatch>(
    //             widget.title,
    //             buildSettings: (context) {
    //               return Card();
    //             },
    //           ),
    //         ),
    //         // 底部控制
    //         Positioned(
    //           child: ControlPanelFooter(
    //             widget.title,
    //           ),
    //         ),
    //       ]
    //     ],
    //   ),
    // );
  }
}
