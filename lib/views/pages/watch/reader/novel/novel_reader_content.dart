import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/watch/novel_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/progress.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:based_battery_indicator/based_battery_indicator.dart';
import 'package:bookfx/bookfx.dart';

class NovelReaderContent extends StatefulWidget {
  const NovelReaderContent(this.tag, {super.key});
  final String tag;

  @override
  State<NovelReaderContent> createState() => _NovelReaderContentState();
}

class _NovelReaderContentState extends State<NovelReaderContent> {
  late final _c = Get.find<NovelController>(tag: widget.tag);
  // final _controller = GlobalKey<PageFlipWidgetState>();
  final RxList<List<Widget>> singlePageText = <List<Widget>>[].obs;
  final List<Widget> line = <Widget>[];
  late int totalPage = singlePageText.length;
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

  Widget _buildContent() {
    return Stack(children: [
      GestureDetector(
          onTapDown: (detail) {
            _c.setControllPanel.value = !_c.setControllPanel.value;
          },
          child: LayoutBuilder(
            builder: (context, constraints) => Obx(
              () {
                // // 宽度 大于 800 就是整体宽度的一半
                final maxWidth = constraints.maxWidth;
                // final width = maxWidth > 800 ? maxWidth / 2 : maxWidth;
                final height = constraints.maxHeight;
                if (_c.error.value.isNotEmpty) {
                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_c.error.value),
                        const SizedBox(height: 20),
                        PlatformButton(
                          child: Text('common.retry'.i18n),
                          onPressed: () {
                            _c.getContent();
                          },
                        )
                      ],
                    ),
                  );
                }

                if (_c.watchData.value == null) {
                  return const Center(child: ProgressRing());
                }
                final listviewPadding =
                    maxWidth > 800 ? ((maxWidth - 800) / 2) : 16.0;

                final fontSize = _c.fontSize.value;
                final leading = _c.leading.value;
                if (_c.readType.value == NovelReadMode.scroll) {
                  return Center(
                    child: NotificationListener<ScrollEndNotification>(
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
                        child: ScrollablePositionedList.builder(
                          itemPositionsListener: _c.itemPositionsListener,
                          initialScrollIndex: _c.currentGlobalProgress.value,
                          itemScrollController: _c.itemScrollController,
                          scrollOffsetController: _c.scrollOffsetController,
                          padding: EdgeInsets.symmetric(
                            horizontal: listviewPadding,
                            vertical: 16,
                          ),
                          itemBuilder: (context, index) {
                            final localProgress =
                                _c.globalToLocalProgress(index);
                            if (localProgress[0] == 0) {
                              return Column(children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  _c.title + _c.playList[localProgress[1]].name,
                                  style: const TextStyle(fontSize: 26),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                if (_c.subtitles[localProgress[1]]
                                    .isNotEmpty) ...[
                                  Text(
                                    _c.subtitles[localProgress[1]],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  )
                                ],
                                _textContent(index, fontSize, leading)
                              ]);
                            }
                            return _textContent(index, fontSize, leading);
                          },
                          itemCount:
                              _c.items.expand((element) => element).length,
                        )),
                  );
                }

                List<PlaceholderDimensions> dimensions = [
                  const PlaceholderDimensions(
                    size: Size(40, 0), //widget span size
                    alignment: PlaceholderAlignment.bottom,
                  )
                ];
                double heightSum = 0;
                line.clear();
                singlePageText.clear();
                for (int index = 0;
                    index < _c.items.expand((element) => element).length;
                    index++) {
                  final textPainter = TextPainter(
                    text: _text(index, fontSize),
                    textDirection: TextDirection.ltr,
                  )
                    ..setPlaceholderDimensions(dimensions)
                    ..layout(maxWidth: maxWidth / 2);
                  line.add(_textContent(index, fontSize, leading));
                  //處理超出高度的情況
                  if (heightSum + textPainter.size.height + leading > height) {
                    if (index > _c.currentGlobalProgress.value) {
                      // _c.bookPage.value = index;
                    }
                    singlePageText.add(List<Widget>.from(line));
                    line.clear();
                    heightSum = 0;
                    continue;
                  }
                  heightSum += (textPainter.size.height + leading);
                  // debugPrint("${textPainter.size.height} $height $heightSum");
                }
                if (line.isNotEmpty) {
                  singlePageText.add(List<Widget>.from(line));
                }
                totalPage = singlePageText.length;
                debugPrint(singlePageText.length.toString());
                //old page flip
                // return Obx(() => PageFlipWidget(
                //       key: _controller,
                //       backgroundColor:
                //           Theme.of(context).scaffoldBackgroundColor,
                //       children: singlePageText,
                //     ));
                //pageview
                // return Obx(() => PageView.builder(
                //       itemBuilder: (context, index) {
                //         return Padding(
                //           padding: EdgeInsets.symmetric(
                //               horizontal: listviewPadding, vertical: 16),
                //           child: Column(
                //             children: singlePageText[index],
                //           ),
                //         );
                //       },
                //       itemCount: singlePageText.length,
                //     ));
                return BookFx(
                    pageCount: singlePageText.length,
                    currentBgColor: Colors.black,
                    size: Size(maxWidth, height),
                    lastCallBack: (val) {
                      _c.setReadingPage(val);
                    },
                    nextCallBack: (val) {
                      _c.setReadingPage(val);
                    },
                    currentPage: (index) {
                      if (index > singlePageText.length) {
                        _c.bookController.goTo(singlePageText.length - 1);
                        return Container();
                      }
                      return Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: listviewPadding, vertical: 16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: singlePageText[index]),
                          ));
                    },
                    nextPage: (index) {
                      //處理頁數到底的情況
                      if (index > singlePageText.length) {
                        _c.bookController.goTo(singlePageText.length - 1);
                        return Container();
                      }

                      return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: listviewPadding, vertical: 16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: singlePageText[index]));
                    },
                    controller: _c.bookController);
              },
            ),
          ))
    ]);
  }

  Widget _indicatorBuilder() {
    return Obx(() => Row(mainAxisSize: MainAxisSize.min, children: [
          if (_c.statusBarElement["reader-settings.page-indicator".i18n]!
                  .value &&
              _c.readType.value == NovelReadMode.scroll) ...[
            Text(
              "${_c.currentLocalProgress.value + 1} ${"novel-settings.line".i18n}",
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(width: 8)
          ],
          if (_c.statusBarElement["reader-settings.page-indicator".i18n]!
                  .value &&
              _c.readType.value != NovelReadMode.scroll) ...[
            ListenableBuilder(
                listenable: _c.bookController,
                builder: (context, child) {
                  return Text(
                      "${_c.bookController.currentIndex + 1}/$totalPage",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15));
                }),
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

  TextSpan _text(int index, double fontSize) {
    final content = _c.items.expand((element) => element).toList();
    return TextSpan(
      children: [
        const WidgetSpan(child: SizedBox(width: 40.0)),
        TextSpan(
          text: content[index],
          style: TextStyle(
            color: index == _c.currentLine.value
                ? _c.highLightTextColor.value
                : _c.textColor.value,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            backgroundColor:
                index == _c.currentLine.value ? _c.highLightColor.value : null,
            height: 2,
            textBaseline: TextBaseline.ideographic,
            fontFamily: 'Microsoft Yahei',
          ),
        ),
      ],
    );
  }

  Widget _textContent(int index, double fontSize, double leading) {
    final content = _c.items.expand((element) => element).toList();

    return SelectableText.rich(
      // key: globalKeys[index],
      onTap: () {
        _c.setControllPanel.value = !_c.setControllPanel.value;
      },
      TextSpan(
        children: [
          const WidgetSpan(child: SizedBox(width: 40.0)),
          TextSpan(
            text: content[index],
            style: TextStyle(
              color: index == _c.currentLine.value
                  ? _c.highLightTextColor.value
                  : _c.textColor.value,
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              backgroundColor: index == _c.currentLine.value
                  ? _c.highLightColor.value
                  : null,
              height: leading,
              textBaseline: TextBaseline.ideographic,
              fontFamily: 'Microsoft Yahei',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildDisplay(_buildContent())),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      color: fluent.FluentTheme.of(context).micaBackgroundColor,
      child: _buildDisplay(_buildContent()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
