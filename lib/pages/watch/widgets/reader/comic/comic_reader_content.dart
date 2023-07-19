import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:miru_app/pages/watch/widgets/reader/controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/button.dart';
import 'package:miru_app/widgets/cache_network_image.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';

class ComicReaderContent extends StatefulWidget {
  const ComicReaderContent(this.tag, {Key? key}) : super(key: key);
  final String tag;

  @override
  State<ComicReaderContent> createState() => _ComicReaderContentState();
}

class _ComicReaderContentState extends State<ComicReaderContent> {
  late final c = Get.find<ReaderController<ExtensionMangaWatch>>(
    tag: widget.tag,
  );

  _buildContent() {
    late Color backgroundColor;
    if (Platform.isAndroid) {
      backgroundColor = Theme.of(context).colorScheme.background;
    } else {
      backgroundColor = fluent.FluentTheme.of(context).micaBackgroundColor;
    }
    return Container(
      color: backgroundColor,
      width: double.infinity,
      child: LayoutBuilder(builder: ((context, constraints) {
        final maxWidth = constraints.maxWidth;
        return Obx(() {
          if (c.error.value.isNotEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(c.error.value),
                PlatformButton(
                  child: Text('common.retry'.i18n),
                  onPressed: () {
                    c.getContent();
                  },
                )
              ],
            );
          }

          if (c.watchData.value == null) {
            return const Center(child: ProgressRing());
          }
          final listviewPadding = maxWidth > 800 ? ((maxWidth - 800) / 2) : 0.0;

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: listviewPadding,
            ),
            itemBuilder: (context, index) {
              final url = c.watchData.value!.urls[index];
              return CacheNetWorkImage(
                url,
                fit: BoxFit.fitWidth,
              );
            },
            itemCount: c.watchData.value!.urls.length,
          );
        });
      })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: (context) {
        return Scaffold(body: SafeArea(child: _buildContent()));
      },
      desktopBuilder: (context) => _buildContent(),
    );
  }
}
