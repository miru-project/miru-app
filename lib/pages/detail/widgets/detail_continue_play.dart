import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/detail/controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class DetailContinuePlay extends StatefulWidget {
  const DetailContinuePlay({
    Key? key,
  }) : super(key: key);
  @override
  State<DetailContinuePlay> createState() => _DetailContinuePlayState();
}

class _DetailContinuePlayState extends State<DetailContinuePlay> {
  late DetailPageController c = Get.find<DetailPageController>();

  Widget _buildAndroid(BuildContext context) {
    return Obx(() {
      late String noEpisodesString;
      late String watchNowString;
      if (c.type.value == ExtensionType.bangumi) {
        noEpisodesString = 'video.no-episodes'.i18n;
        watchNowString = 'video.watch-now'.i18n;
      } else {
        noEpisodesString = 'reader.no-chapters'.i18n;
        watchNowString = 'reader.read-now'.i18n;
      }

      final noEpisodes = FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.play_arrow),
        label: Text(noEpisodesString),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          minimumSize: MaterialStateProperty.all(
            const Size(double.infinity, 50),
          ),
        ),
      );

      final history = c.history.value;
      final data = c.detail;
      if (c.isLoading.value) {
        return noEpisodes;
      }
      // 之前弄错了，所以需要判断标题是否为空
      if (c.history.value != null && c.history.value!.episodeTitle.isNotEmpty) {
        return FilledButton.icon(
          onPressed: () {
            c.goWatch(
              context,
              data!.episodes![history.episodeGroupId].urls,
              history.episodeId,
              history.episodeGroupId,
            );
          },
          icon: const Icon(Icons.play_arrow),
          label: Text(
            FlutterI18n.translate(
              context,
              'detail.continue-watching',
              translationParams: {
                'episode': history!.episodeTitle,
              },
            ),
          ),
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(
              const Size(double.infinity, 50),
            ),
          ),
        );
      }
      if (data!.episodes != null && data.episodes!.isNotEmpty) {
        return FilledButton.icon(
          onPressed: () {
            c.goWatch(
              context,
              data.episodes![0].urls,
              0,
              0,
            );
          },
          icon: const Icon(Icons.play_arrow),
          label: Text(watchNowString),
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(
              const Size(double.infinity, 50),
            ),
          ),
        );
      }
      return noEpisodes;
    });
  }

  Widget _buildDesktop(BuildContext context) {
    return Obx(() {
      final history = c.history.value;
      final data = c.detail!;
      if (history != null && c.history.value!.episodeTitle.isNotEmpty) {
        return fluent.FilledButton(
          onPressed: () {
            c.goWatch(
              context,
              data.episodes![history.episodeGroupId].urls,
              history.episodeId,
              history.episodeGroupId,
            );
          },
          child: Row(
            children: [
              const Icon(fluent.FluentIcons.play),
              const SizedBox(width: 5),
              Text(
                FlutterI18n.translate(
                  context,
                  'detail.continue-watching',
                  translationParams: {
                    'episode': history.episodeTitle,
                  },
                ),
              )
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
