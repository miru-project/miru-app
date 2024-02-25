import 'dart:io';
import 'package:easy_refresh/easy_refresh.dart';
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
  final menuController = fluent.FlyoutController();
  final contextAttachKey = GlobalKey();
  List<Widget> _scrollitems = [];

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
              "${_c.currentGlobalProgress.value + 1}/${_c.itemlength[_c.index.value]}",
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

  Widget pageViewContent(BuildContext context, int conentIndex, int initIndex) {
    final maxWidth = MediaQuery.of(context).size.width;
    final viewPadding = maxWidth > 800 ? ((maxWidth - 800) / 2) : 0.0;
    return ExtendedImageGesturePageView.builder(
      itemCount: _c.itemlength[_c.index.value],
      reverse: _c.readType.value == MangaReadMode.rightToLeft,
      onPageChanged: (index) {
        _c.currentGlobalProgress.value = index;
      },
      scrollDirection: Axis.horizontal,
      controller: _c.extendedPageController.value,
      itemBuilder: (BuildContext context, int index) {
        final img = _c.items[_c.index.value];
        final url = img[index];
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: viewPadding,
          ),
          child: imageBuilder(url),
        );
      },
    );
  }

  Widget webtoonContent(BuildContext context, int contentIndex, int initIndex) {
    final maxWidth = MediaQuery.of(context).size.width;
    final viewPadding = maxWidth > 800 ? ((maxWidth - 800) / 2) : 0.0;
    _c.width.value = MediaQuery.of(context).size.width;
    _c.height.value = MediaQuery.of(context).size.height;
    return Obx(
      () => SizedBox(
        width: _c.width.value,
        height: _c.height.value,
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
            child: Obx(() => ScrollablePositionedList.builder(
                  physics:
                      //  const NeverScrollableScrollPhysics(),
                      _c.isZoom.value
                          ? const NeverScrollableScrollPhysics()
                          : null,
                  padding: EdgeInsets.symmetric(
                    horizontal: viewPadding,
                  ),
                  initialScrollIndex: initIndex,
                  itemScrollController: _c.itemScrollController,
                  itemPositionsListener: _c.itemPositionsListener,
                  scrollOffsetController: _c.scrollOffsetController,
                  scrollOffsetListener: _c.scrollOffsetListener,
                  itemBuilder: (context, index) {
                    final img = _c.items[contentIndex];
                    final url = img[index];
                    return imageBuilder(url);
                  },
                  itemCount: _c.itemlength[contentIndex],
                )),
          ),
        ),
      ),
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
            // final maxWidth = constraints.maxWidth;
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

              // final viewPadding = maxWidth > 800 ? ((maxWidth - 800) / 2) : 0.0;
              final readerType = _c.readType.value;

              return StreamBuilder<RxList<List<String>>>(
                stream: _c.contentStreamController.stream,
                builder: (context, snapshot) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    if (_c.readType.value == MangaReadMode.webTonn) {
                      if (!_c.scrollController.hasClients) return;
                      _c.scrollController.animateTo(_c.height * _c.index.value,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                      _c.itemScrollController
                          .jumpTo(index: _c.currentGlobalProgress.value);
                      return;
                    }
                    if (_c.pagecontroller.hasClients) {
                      _c.pagecontroller.animateToPage(_c.index.value,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    }
                    if (_c.extendedPageController.value.hasClients) {
                      _c.extendedPageController.value
                          .jumpToPage(_c.currentGlobalProgress.value);
                    }
                    _c.pageCall = 0;
                  });
                  // 加载中
                  if (_c.watchData.value == null ||
                      _c.itemlength[_c.index.value] == 0) {
                    return const Center(child: ProgressRing());
                  }
                  _c.height.value = MediaQuery.of(context).size.height;

                  int overrideIndex = _c.index.value;
                  int initScrollIndex = _c.currentGlobalProgress.value;
                  switch (_c.pageCall) {
                    //上一頁
                    case -1:
                      overrideIndex = _c.index.value + 1;
                      initScrollIndex = _c.itemlength[_c.index.value] - 1;
                      break;
                    //下一頁
                    case 1:
                      overrideIndex = _c.index.value - 1;
                      initScrollIndex = 0;
                      break;
                  } //_scrollitems 只有一個scrollablePositionedList or ExtendPageView 其餘都是Container
                  _scrollitems[overrideIndex] = Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.green,
                      child: Center(
                        child: Text(
                          overrideIndex.toString(),
                        ),
                      ));

                  //webtoon mode
                  if (readerType == MangaReadMode.webTonn) {
                    _scrollitems[_c.index.value] = webtoonContent(
                        context, _c.index.value, initScrollIndex);
                    return EasyRefresh(
                        onRefresh: () async {
                          logger.info("top");
                          await _c.loadPrevChapter();
                        },
                        onLoad: () async {
                          await _c.loadNextChapter();
                          logger.info("bottom");
                        },
                        child: ListView.builder(
                          controller: _c.scrollController,
                          itemCount: _scrollitems.length,
                          itemBuilder: (context, index) => _scrollitems[index],
                        ));
                  }
                  //common mode and left to right mode
                  _scrollitems[_c.index.value] = pageViewContent(
                      context, _c.index.value, _c.currentGlobalProgress.value);

                  return EasyRefresh(
                      onRefresh: () async {
                        await _c.loadPrevChapter();
                      },
                      onLoad: () async {
                        await _c.loadNextChapter();
                      },
                      child: PageView.builder(
                        controller: _c.pagecontroller,
                        itemBuilder: (context, index) => _scrollitems[index],
                      ));
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
          fit: BoxFit.fitWidth,
          loadStateChanged: (state) {
            if (state.extendedImageLoadState == LoadState.loading) {
              if (state.loadingProgress == null) {
                return SizedBox(
                    width: _c.width.value,
                    height: _c.height.value,
                    child: const Center(
                      child: ProgressRing(),
                    ));
              }
              return SizedBox(
                  width: _c.width.value,
                  height: _c.width.value,
                  child: Center(
                    child: state.loadingProgress!.expectedTotalBytes == null
                        ? const ProgressRing()
                        : ProgressRing(
                            value:
                                state.loadingProgress!.cumulativeBytesLoaded /
                                    state.loadingProgress!.expectedTotalBytes!,
                          ),
                  ));
            }
            if (state.extendedImageLoadState == LoadState.completed) {
              return state.completedWidget;
            }
            return const Center(child: Icon(fluent.FluentIcons.error));
          },
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _c.height.value = MediaQuery.of(context).size.height;
    _scrollitems = List<Widget>.generate(_c.itemlength.length, (index) {
      if (index == _c.index.value) {
        return webtoonContent(
            context, _c.index.value, _c.currentGlobalProgress.value);
      }
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.green,
        child: Center(
          child: Text("$index"),
        ),
      );
    });
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
/*
Streambuilder
  |
  |---(webtooon)ListView.builder->ScrollablePositionedList.builder->InteractiveViewer->ExtendedImageGesturePageView.builder
  |
  |---(common,reversed)PageView.builder->ExtendedImageGesturePageView.builder
*/