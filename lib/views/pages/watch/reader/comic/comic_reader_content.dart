import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/comic_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/progress.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ComicReaderContent extends StatefulWidget {
  const ComicReaderContent(this.tag, {Key? key}) : super(key: key);
  final String tag;

  @override
  State<ComicReaderContent> createState() => _ComicReaderContentState();
}

class _ComicReaderContentState extends State<ComicReaderContent> {
  late final _c = Get.find<ComicController>(tag: widget.tag);
  _buildContent() {
    late Color backgroundColor;
    if (Platform.isAndroid) {
      backgroundColor = Theme.of(context).colorScheme.background;
    } else {
      backgroundColor = fluent.FluentTheme.of(context).micaBackgroundColor;
    }
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        // 上下
        if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
          if (_c.readType.value == MangaReadMode.webTonn) {
            return _c.previousPage();
          }
        }
        if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          if (_c.readType.value == MangaReadMode.webTonn) {
            return _c.nextPage();
          }
        }

        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          if (_c.readType.value == MangaReadMode.rightToLeft) {
            return _c.nextPage();
          }
          _c.previousPage();
        }

        if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          if (_c.readType.value == MangaReadMode.rightToLeft) {
            return _c.previousPage();
          }
          _c.nextPage();
        }
      },
      child: Container(
        color: backgroundColor,
        width: double.infinity,
        child: LayoutBuilder(builder: ((context, constraints) {
          final maxWidth = constraints.maxWidth;
          return Obx(() {
            if (_c.error.value.isNotEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_c.error.value),
                  PlatformButton(
                    child: Text('common.retry'.i18n),
                    onPressed: () {
                      _c.getContent();
                    },
                  )
                ],
              );
            }

            if (_c.watchData.value == null) {
              return const Center(child: ProgressRing());
            }
            final viewPadding = maxWidth > 800 ? ((maxWidth - 800) / 2) : 0.0;

            final images = _c.watchData.value!.urls;
            final readerType = _c.readType.value;
            final cuurentPage = _c.currentPage.value;

            if (readerType == MangaReadMode.webTonn) {
              return ScrollablePositionedList.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: viewPadding,
                ),
                initialScrollIndex: cuurentPage,
                itemScrollController: _c.itemScrollController,
                itemPositionsListener: _c.itemPositionsListener,
                scrollOffsetController: _c.scrollOffsetController,
                itemBuilder: (context, index) {
                  final url = images[index];
                  return CacheNetWorkImage(
                    url,
                    fit: BoxFit.fitWidth,
                    headers: _c.watchData.value?.headers,
                  );
                },
                itemCount: images.length,
              );
            }

            return PageView.builder(
              reverse: readerType == MangaReadMode.rightToLeft,
              controller: _c.pageController.value,
              onPageChanged: (index) {
                _c.currentPage.value = index;
              },
              itemBuilder: (context, index) {
                final url = images[index];
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: viewPadding,
                  ),
                  child: CacheNetWorkImage(
                    url,
                    key: ValueKey(url),
                    fit: BoxFit.contain,
                    headers: _c.watchData.value?.headers,
                  ),
                );
              },
              itemCount: images.length,
            );
          });
        })),
      ),
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
