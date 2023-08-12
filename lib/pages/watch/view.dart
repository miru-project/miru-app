import 'package:flutter/material.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/watch/widgets/reader/comic/comic_reader.dart';
import 'package:miru_app/pages/watch/widgets/reader/novel/novel_reader.dart';
import 'package:miru_app/pages/watch/widgets/video/video_player.dart';
import 'package:miru_app/utils/extension.dart';

class WatchPage extends StatelessWidget {
  const WatchPage({
    Key? key,
    required this.playList,
    required this.package,
    required this.title,
    required this.playerIndex,
    required this.episodeGroupId,
    required this.detailUrl,
    required this.cover,
  }) : super(key: key);
  final List<ExtensionEpisode> playList;
  final int playerIndex;
  final String title;
  final String package;
  final String detailUrl;
  final int episodeGroupId;
  final String cover;

  @override
  Widget build(BuildContext context) {
    final runtime = ExtensionUtils.runtimes[package]!;
    switch (runtime.extension.type) {
      case ExtensionType.bangumi:
        return VideoPlayer(
          title: title,
          playList: playList,
          runtime: runtime,
          playerIndex: playerIndex,
          // 用来存储历史记录了
          episodeGroupId: episodeGroupId,
          detailUrl: detailUrl,
        );
      case ExtensionType.manga:
        return ComicReader(
          title: title,
          playList: playList,
          detailUrl: detailUrl,
          playerIndex: playerIndex,
          episodeGroupId: episodeGroupId,
          runtime: runtime,
          cover: cover,
        );
      default:
        return NovelReader(
          playList: playList,
          runtime: runtime,
          episodeGroupId: episodeGroupId,
          playerIndex: playerIndex,
          title: title,
          detailUrl: detailUrl,
          cover: cover,
        );
    }
  }
}
