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
import 'package:extended_image/extended_image.dart';

class ComicReaderContent extends StatefulWidget {
  const ComicReaderContent(this.tag, {super.key});
  final String tag;

  @override
  State<ComicReaderContent> createState() => _ComicReaderContentState();
}

class _ComicReaderContentState extends State<ComicReaderContent> {
  late final _c = Get.find<ComicController>(tag: widget.tag);
  final zoomScale = 1.0.obs;
  bool isZoomed = false;

  TransformationController transformationController =
      TransformationController();
  final double minScaleValue = 1.0;

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

            // 加载中
            if (_c.watchData.value == null) {
              return const Center(child: ProgressRing());
            }

            final viewPadding = maxWidth > 800 ? ((maxWidth - 800) / 2) : 0.0;
            final images = _c.watchData.value!.urls;
            final readerType = _c.readType.value;
            final cuurentPage = _c.currentPage.value;
            if (readerType == MangaReadMode.webTonn) {
              //zooming is inspired by: https://github.com/flutter/flutter/issues/86531
              if (Platform.isAndroid) {
                return Stack(
                  children: [
                    InteractiveViewer(
                      minScale: minScaleValue,
                      transformationController: transformationController,
                      onInteractionEnd: (ScaleEndDetails endDetails) {
                        setState(() {
                          isZoomed = false;
                        });
                      },
                      onInteractionUpdate: (x) {
                        double correctScaleValue =
                            transformationController.value.getMaxScaleOnAxis();
                        if (x.scale == correctScaleValue) {
                          setState(() {
                            isZoomed = false;
                          });
                        }
                        setState(() {
                          isZoomed = true;
                        });
                        debugPrint("${x.scale}");
                      },
                      child: ScrollablePositionedList.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: viewPadding,
                        ),
                        initialScrollIndex: cuurentPage,
                        itemScrollController: _c.itemScrollController,
                        itemPositionsListener: _c.itemPositionsListener,
                        scrollOffsetController: _c.scrollOffsetController,
                        scrollOffsetListener: _c.scrolloffsetListener,
                        physics: isZoomed
                            ? const NeverScrollableScrollPhysics()
                            : const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          final url = images[index];
                          return Obx(
                            () => CacheNetWorkImagePic(
                              url,
                              fit: BoxFit.cover,
                              headers: _c.watchData.value?.headers,
                            ),
                          );
                        },
                        itemCount: images.length,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        color: Colors.black.withAlpha(200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 2),
                        child: Text(
                          "${cuurentPage + 1}/${images.length}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                );
              }
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
                  return CacheNetWorkImagePic(
                    url,
                    fit: BoxFit.fitWidth,
                    headers: _c.watchData.value?.headers,
                  );
                },
                itemCount: images.length,
              );
            }
            //common mode and left to right mode
            return Stack(
              children: [
                ExtendedImageGesturePageView.builder(
                  itemCount: images.length,
                  reverse: readerType == MangaReadMode.rightToLeft,
                  onPageChanged: (index) {
                    _c.currentPage.value = index;
                  },
                  scrollDirection: Axis.horizontal,
                  controller: _c.pageController.value,
                  itemBuilder: (BuildContext context, int index) {
                    final url = images[index];
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: viewPadding,
                      ),
                      child: ExtendedImage.network(
                        url,
                        mode: ExtendedImageMode.gesture,
                        key: ValueKey(url),
                        fit: BoxFit.contain,
                        headers: _c.watchData.value?.headers,
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Colors.black.withAlpha(200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    child: Text(
                      "${cuurentPage + 1}/${images.length}",
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
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
