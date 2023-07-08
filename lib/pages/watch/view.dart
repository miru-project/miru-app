import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/main.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/watch/widgets/video_player.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';

class WatchPage extends StatelessWidget {
  const WatchPage({
    Key? key,
    required this.playList,
    required this.package,
    required this.title,
    required this.playerIndex,
    required this.episodeGroupId,
    required this.detailUrl,
  }) : super(key: key);
  final List<ExtensionEpisode> playList;
  final int playerIndex;
  final String title;
  final String package;
  final String detailUrl;
  final int episodeGroupId;

  @override
  Widget build(BuildContext context) {
    final runtime = ExtensionUtils.extensions[package];
    if (runtime == null) {
      showDialog(
        context: context,
        builder: (context) {
          if (Platform.isAndroid) {
            return AlertDialog(
              title: Text('common.error'.i18n),
              content: Text(FlutterI18n.translate(
                context,
                'common.extension-missing',
                translationParams: {
                  'package': package,
                },
              )),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('common.confirm'.i18n),
                ),
              ],
            );
          }
          return fluent.ContentDialog(
            title: Text('common.error'.i18n),
            content: Text(FlutterI18n.translate(
              context,
              'common.extension-missing',
              translationParams: {
                'package': package,
              },
            )),
            actions: [
              fluent.Button(
                onPressed: () => router.pop(),
                child: Text('common.confirm'.i18n),
              ),
            ],
          );
        },
      );
      return const SizedBox.shrink();
    }
    return VideoPlayer(
      title: title,
      playList: playList,
      runtime: runtime,
      playerIndex: playerIndex,
      episodeGroupId: episodeGroupId,
      detailUrl: detailUrl,
    );
  }
}
