import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/detail/controller.dart';
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
      final history = c.history.value;
      final data = c.data.value!;
      if (c.history.value != null) {
        return FilledButton.icon(
          onPressed: () {
            c.goWatch(
              context,
              data.episodes![history.episodeGroupId].urls,
              history.episodeId,
              history.episodeGroupId,
            );
          },
          icon: const Icon(Icons.play_arrow),
          label: Text("继续观看 ${history!.episodeTitle}"),
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(
              const Size(double.infinity, 50),
            ),
          ),
        );
      }
      if (data.episodes != null && data.episodes!.isNotEmpty) {
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
          label: const Text("立即观看"),
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(
              const Size(double.infinity, 50),
            ),
          ),
        );
      }
      return FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.play_arrow),
        label: const Text("无剧集"),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          minimumSize: MaterialStateProperty.all(
            const Size(double.infinity, 50),
          ),
        ),
      );
    });
  }

  Widget _buildDesktop(BuildContext context) {
    return Obx(() {
      final history = c.history.value;
      final data = c.data.value!;
      if (history != null) {
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
              Text("继续观看 ${history.episodeTitle}")
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
