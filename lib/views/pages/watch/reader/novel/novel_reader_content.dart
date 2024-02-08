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

class NovelReaderContent extends StatefulWidget {
  const NovelReaderContent(this.tag, {super.key});
  final String tag;

  @override
  State<NovelReaderContent> createState() => _NovelReaderContentState();
}

class _NovelReaderContentState extends State<NovelReaderContent> {
  late final _c = Get.find<NovelController>(tag: widget.tag);
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
                // final height = constraints.maxHeight;
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

                final watchData = _c.watchData.value!;

                final listviewPadding =
                    maxWidth > 800 ? ((maxWidth - 800) / 2) : 16.0;

                final fontSize = _c.fontSize.value;

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
                          if (_c.globalToLocalProgress(index) == 0) {
                            return Column(children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  _c.title + _c.playList[_c.index.value].name,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                              if (watchData.subtitle != null) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    watchData.subtitle!,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                )
                              ],
                              _textContent(index, fontSize)
                            ]);
                          }
                          return _textContent(index, fontSize);
                        },
                        itemCount: _c.items.expand((element) => element).length,
                      )),
                );
              },
            ),
          ))
    ]);
  }

  Widget _indicatorBuilder() {
    return Obx(() => Row(mainAxisSize: MainAxisSize.min, children: [
          if (_c.statusBarElement["reader-settings.page-indicator".i18n]!
              .value) ...[
            Text(
              "${_c.currentLocalProgress.value + 1} ${"novel-settings.line".i18n}",
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

  Widget _textContent(int index, double fontSize) {
    final content = _c.items.expand((element) => element).toList();
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SelectableText.rich(
          onTap: () {
            _c.setControllPanel.value = !_c.setControllPanel.value;
          },
          TextSpan(
            children: [
              const WidgetSpan(child: SizedBox(width: 40.0)),
              TextSpan(
                text: content[index],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  height: 2,
                  textBaseline: TextBaseline.ideographic,
                  fontFamily: 'Microsoft Yahei',
                ),
              ),
            ],
          ),
        ));
    // Obx(() => Column(
    //       children: [
    //         _c.enableSelectText.value
    //             ? SelectableText.rich(
    //                 onTap: () {
    //                   _c.setControllPanel.value =
    //                       !_c.setControllPanel.value;
    //                 },
    //                 TextSpan(
    //                   children: [
    //                     const WidgetSpan(child: SizedBox(width: 40.0)),
    //                     TextSpan(
    //                       text: content[index],
    //                       style: TextStyle(
    //                         fontSize: fontSize,
    //                         fontWeight: FontWeight.w400,
    //                         height: 2,
    //                         textBaseline: TextBaseline.ideographic,
    //                         fontFamily: 'Microsoft Yahei',
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               )
    //             : GestureDetector(
    //                 onTap: () {
    //                   _c.setControllPanel.value =
    //                       !_c.setControllPanel.value;
    //                   _c.enableSelectText.value = true;
    //                 },
    //                 child: Text(
    //                   content[index],
    //                   style: TextStyle(
    //                     fontSize: fontSize,
    //                     fontWeight: FontWeight.w400,
    //                     height: 2,
    //                     textBaseline: TextBaseline.ideographic,
    //                     fontFamily: 'Microsoft Yahei',
    //                   ),
    //                 ))
    //       ],
    //     )));
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
