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
  // late final List<Widget> _chapterItems = List.generate(
  //     _c.playList.length,
  //     ((val) => Container(
  //         color: Colors.green,
  //         width: MediaQuery.of(context).size.width,
  //         height: MediaQuery.of(context).size.height,
  //         child: Center(child: Text(val.toString())))));
  // late final List<Widget> _chapterItems = List.generate(
  //     _c.playList.length, ((val) => webtoonContent(context, val)));
  final menuController = fluent.FlyoutController();
  final contextAttachKey = GlobalKey();
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

  @override
  void initState() {
    super.initState();
    // ever(_c.index,
    //     (callback) => _chapterItems[callback] = webtoonContent(context));
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
              "${_c.currentLocalProgress.value + 1}/${_c.itemlength[_c.index.value]}",
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

  Widget webtoonContent(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final viewPadding = maxWidth > 800 ? ((maxWidth - 800) / 2) : 0.0;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Obx(() => SizedBox(
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
                initialScrollIndex: _c.currentGlobalProgress.value,
                itemScrollController: _c.itemScrollController,
                itemPositionsListener: _c.itemPositionsListener,
                scrollOffsetController: _c.scrollOffsetController,
                scrollOffsetListener: _c.scrollOffsetListener,
                itemBuilder: (context, index) {
                  final img = _c.items.expand((element) => element).toList();
                  final url = img[index];
                  SizedBox(
                    width: width,
                    height: height,
                    child: const Center(
                      child: Center(
                        child: ProgressRing(),
                      ),
                    ),
                  );
                  return imageBuilder(url);
                },
                itemCount: _c.items.expand((element) => element).length,
              ),
            ),
          ),
        ));
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
              final readerType = _c.readType.value;

              if (readerType == MangaReadMode.webTonn) {
                return NotificationListener<ScrollEndNotification>(
                  child: webtoonContent(context),
                  onNotification: (notification) {
                    final metrics = notification.metrics;
                    if (metrics.atEdge) {
                      bool isTop = metrics.pixels <= 0;
                      if (isTop) {
                        debugPrint('At the top');
                        _c.loadPrevChapter();
                      } else {
                        debugPrint('At the bottom');
                        _c.loadNextChapter();
                      }
                    }

                    return true;
                  },
                );
              }

              //common mode and left to right mode
              return Obx(() => NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    final metrics = notification.metrics;
                    if (metrics.atEdge) {
                      bool isTop = metrics.pixels <= 0;
                      if (isTop) {
                        debugPrint('At the start');
                        _c.loadPrevChapter();
                      } else {
                        debugPrint('At the end');
                        _c.loadNextChapter();
                      }
                    }
                    // debugPrint(metrics.pixels.toString());
                    return true;
                  },
                  child: ExtendedImageGesturePageView.builder(
                    itemCount: _c.items.expand((element) => element).length,
                    reverse: readerType == MangaReadMode.rightToLeft,
                    onPageChanged: (index) {
                      _c.currentGlobalProgress.value = index;
                    },
                    scrollDirection: Axis.horizontal,
                    controller: _c.pageController.value,
                    itemBuilder: (BuildContext context, int index) {
                      // final urls = _c.items[_c.index.value];
                      // final url = images[index];
                      // if (index == 0) {
                      //   return Container(
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: viewPadding,
                      //     ),
                      //     color: Colors.red,
                      //   );
                      // }
                      // if (index == _c.itemlength[_c.index.value] - 1) {
                      //   return Container(
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: viewPadding,
                      //     ),
                      //     color: Colors.red,
                      //   );
                      // }
                      final img =
                          _c.items.expand((element) => element).toList();
                      final url = img[index];
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: viewPadding,
                        ),
                        child: imageBuilder(url),
                      );
                    },
                  )));
            });
          }),
        ),
      ),
    );
  }

  Widget imageBuilder(String url) {
    return GestureDetector(
        onTapDown: (deatils) {
          _c.setControllPanel.value = !_c.setControllPanel.value;
        },
        onSecondaryTapUp: (d) {
          final targetContext = contextAttachKey.currentContext;
          if (targetContext == null) return;
          final box = targetContext.findRenderObject() as RenderBox;
          final position = box.localToGlobal(
            d.localPosition,
            ancestor: Navigator.of(context).context.findRenderObject(),
          );
          menuController.showFlyout(
            position: position,
            builder: (context) {
              return fluent.MenuFlyout(items: [
                fluent.MenuFlyoutItem(
                  leading: const Icon(fluent.FluentIcons.save),
                  text: Text('common.save'.i18n),
                  onPressed: () {
                    fluent.Flyout.of(context).close();
                    saveImage(
                        url, _c.watchData.value?.headers, mounted, context);
                  },
                ),
              ]);
            },
          );
        },
        onDoubleTapDown: (Platform.isAndroid)
            ? (details) {
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
                            saveImage(url, _c.watchData.value?.headers, mounted,
                                context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            : null,
        child: CacheNetWorkImagePic(
          url,
          fit: BoxFit.fitWidth,
          placeholder: _buildPlaceholder(context),
          headers: _c.watchData.value?.headers,
          initGestureConfigHandler: (state) {
            return GestureConfig(
              inPageView: true,
            );
          },
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
