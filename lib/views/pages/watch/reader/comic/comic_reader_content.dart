import 'dart:io';

import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
  }

  late final _c = Get.find<ComicController>(tag: widget.tag);

  // 按下数量
  final List<int> _pointer = [];

  _buildPlaceholder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: Center(
          child: ProgressRing(),
        ),
      ),
    );
  }

  _buildDisplay(Widget child) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          child: Container(
            color: Colors.black.withAlpha(200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Obx(
              () => Text(
                "${_c.currentPage.value + 1}/${_c.watchData.value?.urls.length ?? 0}",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

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
      onKey: _c.onKey,
      child: Container(
        color: backgroundColor,
        width: double.infinity,
        child: LayoutBuilder(
          builder: ((context, constraints) {
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
                final width = MediaQuery.of(context).size.width;
                final height = MediaQuery.of(context).size.height;
                return SizedBox(
                  width: width,
                  height: height,
                  child: Listener(
                    onPointerDown: (event) {
                      _pointer.add(event.pointer);
                      if (_pointer.length == 2) {
                        _c.isZoom.value = true;
                      }
                    },
                    onPointerUp: (event) {
                      _pointer.remove(event.pointer);
                      if (_pointer.length == 1) {
                        _c.isZoom.value = false;
                      }
                    },
                    child: InteractiveViewer(
                      scaleEnabled: _c.isZoom.value,
                      child: ScrollablePositionedList.builder(
                        physics: _c.isZoom.value
                            ? const NeverScrollableScrollPhysics()
                            : null,
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
                            placeholder: _buildPlaceholder(context),
                            headers: _c.watchData.value?.headers,
                            needReconstruct:
                                _c.watchData.value?.needReconstruct ?? false,
                            runtime: _c.runtime,
                            imageIndex: index,
                          );
                        },
                        itemCount: images.length,
                      ),
                    ),
                  ),
                );
              }

              //common mode and left to right mode
              return ExtendedImageGesturePageView.builder(
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
                    child: CacheNetWorkImagePic(
                      url,
                      mode: ExtendedImageMode.gesture,
                      key: ValueKey(url),
                      fit: BoxFit.contain,
                      placeholder: _buildPlaceholder(context),
                      headers: _c.watchData.value?.headers,
                      needReconstruct:
                          _c.watchData.value?.needReconstruct ?? false,
                      imageIndex: index,
                      runtime: _c.runtime,
                    ),
                  );
                },
              );
            });
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: (context) {
        return Scaffold(
            body: SafeArea(
          child: _buildDisplay(
            _buildContent(),
          ),
        ));
      },
      desktopBuilder: (context) => _buildDisplay(
        _buildContent(),
      ),
    );
  }
}
