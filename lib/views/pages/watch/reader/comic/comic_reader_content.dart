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
import 'package:based_battery_indicator/based_battery_indicator.dart';

class ComicReaderContent extends StatefulWidget {
  const ComicReaderContent(this.tag, {super.key});
  final String tag;

  @override
  State<ComicReaderContent> createState() => _ComicReaderContentState();
}

class _ComicReaderContentState extends State<ComicReaderContent> {
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

  Widget _buildDisplay(Widget child) {
    if (_c.statusBarElement.values.every((element) => element.value == false)) {
      return child;
    }
    return Stack(
      children: [
        child,
        Obx(() => Align(
              alignment: _c.alignMode.value,
              child: Container(
                color: Colors.black.withAlpha(200),
                padding: const EdgeInsets.fromLTRB(20, 2, 12, 2),
                child: _indicatorBuilder(),
              ),
            )),
      ],
    );
  }

  Widget _indicatorBuilder() {
    return Obx(() => Row(mainAxisSize: MainAxisSize.min, children: [
          if (_c.statusBarElement["reader-settings.page-indicator".i18n]!
              .value) ...[
            Text(
              "${_c.currentPage.value + 1}/${_c.watchData.value?.urls.length ?? 0}",
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(width: 8)
          ],
          if (_c.statusBarElement["reader-settings.battery-icon".i18n]!
              .value) ...[
            BasedBatteryIndicator(
              status: BasedBatteryStatus(
                value: _c.batteryLevel.value,
                type: BasedBatteryStatusType.normal,
              ),
              trackHeight: 10.0,
              trackAspectRatio: 2.0,
              curve: Curves.ease,
              duration: const Duration(seconds: 10),
            ),
            const SizedBox(width: 8)
          ],
          if (_c.statusBarElement["reader-settings.battery".i18n]!.value) ...[
            Text(
              "${_c.batteryLevel.value}%",
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(width: 8)
          ],
          if (_c.statusBarElement["reader-settings.time".i18n]!.value) ...[
            Text(
              _c.currentTime.value,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(width: 8)
          ],
        ]));
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
                        scrollOffsetListener: _c.scrollOffsetListener,
                        itemBuilder: (context, index) {
                          final url = images[index];
                          return imageBuilder(url);
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
                    child: imageBuilder(url),
                  );
                },
              );
            });
          }),
        ),
      ),
    );
  }

  Widget imageBuilder(String url) {
    return GestureDetector(
        onTapDown: (deatils) {
          _c.isShowControlPanel.value = !_c.isShowControlPanel.value;
        },
        onDoubleTapDown: (details) {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            useSafeArea: true,
            builder: (_) => SizedBox(
              height: 100,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.save),
                    title: Text('common.save'.i18n),
                    onTap: () {
                      Navigator.of(context).pop();
                      saveImage(
                          url, _c.watchData.value?.headers, mounted, context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: CacheNetWorkImagePic(
          url,
          fit: BoxFit.fitWidth,
          placeholder: _buildPlaceholder(context),
          headers: _c.watchData.value?.headers,
        ));
  }

  @override
  Widget build(BuildContext context) {
    _c.height.value = MediaQuery.of(context).size.height;
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
