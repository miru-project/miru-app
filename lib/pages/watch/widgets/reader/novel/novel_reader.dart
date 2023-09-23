import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/pages/watch/widgets/reader/novel/controller.dart';
import 'package:miru_app/pages/watch/widgets/reader/novel/novel_reader_content.dart';
import 'package:miru_app/pages/watch/widgets/reader/novel/novel_reader_settings.dart';
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
    this.cover,
  }) : super(key: key);

  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playerIndex;
  final int episodeGroupId;
  final ExtensionRuntime runtime;
  final String? cover;

  @override
  State<NovelReader> createState() => _NovelReaderState();
}

class _NovelReaderState extends State<NovelReader> {
  @override
  void initState() {
    Get.put(
      NovelController(
        title: widget.title,
        playList: widget.playList,
        detailUrl: widget.detailUrl,
        playIndex: widget.playerIndex,
        episodeGroupId: widget.episodeGroupId,
        runtime: widget.runtime,
        cover: widget.cover,
      ),
      tag: widget.title,
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<NovelController>(tag: widget.title);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReadView<NovelController>(
      widget.title,
      content: NovelReaderContent(widget.title),
      buildSettings: (context) => NovelReaderSettings(widget.title),
    );
  }
}
