import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/comic_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/log.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';

import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/progress.dart';
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
  final menuController = fluent.FlyoutController();
  final contextAttachKey = GlobalKey();
  static const Key _centerKey = ValueKey<String>('bottom-sliver-list');
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
        Obx(
          () => Align(
            alignment: _c.alignMode.value,
            child: Container(
              color: Colors.black.withAlpha(200),
              padding: const EdgeInsets.fromLTRB(20, 2, 12, 2),
              child: _indicatorBuilder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _indicatorBuilder() {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
        ],
      ),
    );
  }

  Widget webtoonContent(BuildContext context) {
    // final maxWidth = MediaQuery.of(context).size.width;
    // final viewPadding = maxWidth > 800 ? ((maxWidth - 800) / 2) : 0.0;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    _c.height.value = height;
    return Obx(
      () {
        //切成三份，中間固定在同個index(positionedindex) 之後，做出分割
        final listPrev = _c.items
            .sublist(0, _c.positionedindex.value)
            .reversed
            .expand((element) => element.reversed)
            .toList();
        final listNext = _c.items
            .sublist(_c.positionedindex.value + 1)
            .expand((element) => element)
            .toList();
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
              minScale: .5,
              scaleEnabled: _c.isZoom.value,
              child: CustomScrollView(
                controller: _c.scrollController,
                physics: _c.isZoom.value
                    ? const NeverScrollableScrollPhysics()
                    : null,
                center: _centerKey,
                slivers:
                    // [
                    //   SliverList(
                    //     delegate: SliverChildBuilderDelegate(
                    //       (context, index) {
                    //         final url = listPrev[index];
                    //         return imageBuilder(url);
                    //       },
                    //       childCount: listPrev.length,
                    //     ),
                    //   ),
                    //   //設為中心點
                    //   SliverList.builder(
                    //     key: _centerKey,
                    //     itemBuilder: (context, index) {
                    //       final img = _c.items[_c.positionedindex.value];
                    //       final url = img[index];
                    //       return imageBuilder(url);
                    //     },
                    //     itemCount: _c.itemlength[_c.positionedindex.value],
                    //   ),
                    //   SliverList(
                    //     delegate: SliverChildBuilderDelegate(
                    //       (context, index) {
                    //         final url = listNext[index];
                    //         return imageBuilder(url);
                    //       },
                    //       childCount: listNext.length,
                    //     ),
                    //   )
                    // ]
                    [
                  SliverFixedExtentList(
                    itemExtent: height,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final url = listPrev[index];
                        return imageBuilder(url);
                      },
                      childCount: listPrev.length,
                    ),
                  ),
                  //設為中心點
                  SliverFixedExtentList.builder(
                    itemExtent: height,
                    key: _centerKey,
                    itemBuilder: (context, index) {
                      final img = _c.items[_c.positionedindex.value];
                      final url = img[index];
                      return imageBuilder(url);
                    },
                    itemCount: _c.itemlength[_c.positionedindex.value],
                  ),
                  SliverFixedExtentList(
                    itemExtent: height,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final url = listNext[index];
                        return imageBuilder(url);
                      },
                      childCount: listNext.length,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildContent() {
    late Color backgroundColor;
    if (Platform.isAndroid) {
      backgroundColor = Theme.of(context).colorScheme.background;
    } else {
      backgroundColor = fluent.FluentTheme.of(context).micaBackgroundColor;
    }
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _c.onKey,
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
              return Obx(
                () => NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    final metrics = notification.metrics;
                    if (metrics.atEdge) {
                      bool isTop = metrics.pixels <= 0;
                      if (isTop) {
                        logger.info('At the start');
                        _c.loadPrevChapter();
                      } else {
                        logger.info('At the end');
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
                  ),
                ),
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
                      url,
                      _c.watchData.value?.headers,
                      context,
                    );
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
                            saveImage(
                                url, _c.watchData.value?.headers, context);
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
          // postFrameCallback: (context) {
          //   RenderBox renderBox =
          //       context.currentContext!.findRenderObject() as RenderBox;
          //   logger.info('renderBox.size: ${renderBox.size}');
          // },
          fit: BoxFit.cover,
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
    // _c.height.value = MediaQuery.of(context).size.height;
    return PlatformBuildWidget(
      androidBuilder: (context) {
        return Scaffold(
            body: _buildDisplay(
          _buildContent(),
        ));
      },
      desktopBuilder: (context) => _buildDisplay(
        _buildContent(),
      ),
    );
  }
}
