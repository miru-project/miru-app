import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/controllers/watch/novel_controller.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:miru_app/utils/miru_storage.dart';

class ControlPanelFooter<T extends ReaderController> extends StatefulWidget {
  const ControlPanelFooter(this.tag, {super.key});
  final String tag;
  @override
  State<ControlPanelFooter> createState() => _ControlPanelFooterState<T>();
}

class _ControlPanelFooterState<T extends ReaderController>
    extends State<ControlPanelFooter> {
  late final _c = Get.find<T>(tag: widget.tag);
  late final int total = (T == NovelController)
      ? _c.watchData.value?.content.length ?? 0
      : _c.watchData.value?.urls.length ?? 0;
  late final totalObs = total.obs;
  late final progressObs = _c.progress.value.obs;
  late final Color containerColor = Platform.isAndroid
      ? Theme.of(context).colorScheme.background.withOpacity(0.9)
      : Colors.transparent;

  @override
  void initState() {
    super.initState();
    ever(_c.watchData, (callback) {
      progressObs.value = 0;
      totalObs.value = _c.itemlength[_c.index.value];
    });
    ever(_c.index, (callback) {
      progressObs.value = _c.progress.value;
      totalObs.value = _c.itemlength[_c.index.value];
    });
    ever(_c.currentLocalProgress, (callback) {
      progressObs.value = callback;
    });
  }

  final _desktopOffsetFlyoutController = fluent.FlyoutController();
  final _desktopIntervalFlyoutController = fluent.FlyoutController();
  Widget _buildAndroid(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    // return Container();
    return Align(
        alignment: const Alignment(0, 1),
        child: TweenAnimationBuilder(
          builder: (context, value, child) => FractionalTranslation(
              translation: value,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
                  child: Obx(() => Row(children: [
                        const SizedBox(
                          height: 10,
                        ),
                        if (_c.index.value > 0)
                          Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: containerColor,
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    _c.prevChap();
                                  },
                                  icon:
                                      const Icon(Icons.skip_previous_rounded))),
                        const Spacer(),
                        SizedBox(
                            height: 50,
                            width: width * 2 / 3,
                            child: Material(
                                color: containerColor,
                                borderRadius: BorderRadius.circular(30),
                                child: Obx(() {
                                  if (totalObs.value != 0 ||
                                      !_c.isShowControlPanel.value) {
                                    return Slider(
                                      label: (_c.currentLocalProgress.value + 1)
                                          .toString(),
                                      max: _c.itemlength[_c.index.value] < 1
                                          ? 1
                                          : (_c.itemlength[_c.index.value] - 1)
                                              .toDouble(),
                                      min: 0,
                                      divisions: (totalObs.value - 1) < 0
                                          ? 1
                                          : totalObs.value - 1,
                                      value: _c.currentLocalProgress.value
                                          .toDouble(),
                                      onChanged: (val) {
                                        _c.updateSlider.value = true;
                                        _c.progress.value =
                                            _c.localToGloabalProgress(
                                                val.toInt());
                                      },
                                    );
                                  }
                                  return const Slider(
                                      value: 0, onChanged: null);
                                }))),
                        const Spacer(),
                        if (_c.index.value != _c.playList.length - 1)
                          Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: containerColor,
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    _c.nextChap();
                                  },
                                  icon: const Icon(Icons.skip_next_rounded)))
                      ])))),
          duration: const Duration(milliseconds: 200),
          tween: Tween<Offset>(
              begin: (_c.isShowControlPanel.value)
                  ? const Offset(0, 1)
                  : Offset.zero,
              end: (_c.isShowControlPanel.value)
                  ? Offset.zero
                  : const Offset(0, 1.0)),
        ));
  }

  Widget _buildDesktop(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Align(
        alignment: const Alignment(0, 1),
        child: TweenAnimationBuilder(
          builder: (context, value, child) => FractionalTranslation(
              translation: value,
              child: Container(
                  color: fluent.FluentTheme.of(context)
                      .micaBackgroundColor
                      .withOpacity(0.75),
                  height: 80,
                  child: Obx(() => Column(children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Row(children: [
                          const SizedBox(width: 16),
                          Text((progressObs.value + 1).toString()),
                          const SizedBox(width: 8),
                          Obx(() {
                            if (totalObs.value != 0 ||
                                !_c.isShowControlPanel.value) {
                              return Expanded(
                                  child: fluent.Slider(
                                label: (progressObs.value + 1).toString(),
                                max: (totalObs.value - 1) < 0
                                    ? 1
                                    : (totalObs.value - 1).toDouble(),
                                min: 0,
                                divisions: (totalObs.value - 1) < 0
                                    ? 1
                                    : totalObs.value - 1,
                                value: progressObs.value.toDouble(),
                                onChanged: _c.isShowControlPanel.value
                                    ? (val) {
                                        _c.updateSlider.value = true;
                                        _c.progress.value = val.toInt();
                                      }
                                    : null,
                              ));
                            }
                            return const Expanded(
                                child:
                                    fluent.Slider(value: 0, onChanged: null));
                          }),
                          const SizedBox(width: 8),
                          Text(totalObs.value.toString()),
                          const SizedBox(width: 16),
                        ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const SizedBox(width: 48),
                              fluent.FlyoutTarget(
                                  controller: _desktopIntervalFlyoutController,
                                  child: _desktopMangaPlayerButton(
                                      20, fluent.FluentIcons.clock, () {
                                    _desktopIntervalFlyoutController.showFlyout(
                                        builder: (context) => Obx(() =>
                                            fluent.FlyoutContent(
                                                child: SizedBox(
                                                    width: 20,
                                                    height: height / 3,
                                                    child: fluent.Slider(
                                                        vertical: true,
                                                        value: _c
                                                            .autoScrollInterval
                                                            .value
                                                            .toDouble(),
                                                        max: 500.0,
                                                        divisions: 25,
                                                        label:
                                                            "${_c.autoScrollInterval} ms",
                                                        onChanged: (val) {
                                                          _c.autoScrollInterval
                                                                  .value =
                                                              val.toInt();
                                                          MiruStorage.setSetting(
                                                              SettingKey
                                                                  .autoScrollInterval,
                                                              val.toInt());
                                                        })))));
                                  })),
                              const Spacer(flex: 10),
                              _desktopMangaPlayerButton(
                                  20, fluent.FluentIcons.previous, () {
                                _c.prevChap();
                              }),
                              const Spacer(),
                              _desktopMangaPlayerButton(
                                  40,
                                  (_c.enableAutoScroll.value)
                                      ? fluent.FluentIcons.stop
                                      : fluent.FluentIcons.play, () {
                                _c.enableAutoScroll.value =
                                    !_c.enableAutoScroll.value;
                              }),
                              const Spacer(),
                              _desktopMangaPlayerButton(
                                  20, fluent.FluentIcons.next, () {
                                _c.nextChap();
                              }),
                              const Spacer(flex: 10),
                              fluent.FlyoutTarget(
                                  controller: _desktopOffsetFlyoutController,
                                  child: _desktopMangaPlayerButton(
                                      20, fluent.FluentIcons.padding, () {
                                    _desktopOffsetFlyoutController.showFlyout(
                                        builder: (context) => Obx(() =>
                                            fluent.FlyoutContent(
                                                child: SizedBox(
                                                    width: 20,
                                                    height: height / 3,
                                                    child: fluent.Slider(
                                                        vertical: true,
                                                        value: _c
                                                            .autoScrollOffset
                                                            .value,
                                                        max: 300.0,
                                                        divisions: 30,
                                                        label:
                                                            "${_c.autoScrollOffset} pixels",
                                                        onChanged: (val) {
                                                          _c.autoScrollOffset
                                                              .value = val;
                                                          MiruStorage.setSetting(
                                                              SettingKey
                                                                  .autoScrollOffset,
                                                              val);
                                                        })))));
                                  })),
                              const SizedBox(width: 48),
                            ])
                      ])))),
          duration: const Duration(milliseconds: 200),
          tween: Tween<Offset>(
              begin: (_c.isShowControlPanel.value || _c.enableAutoScroll.value)
                  ? const Offset(0, 1)
                  : Offset.zero,
              end: (_c.isShowControlPanel.value || _c.enableAutoScroll.value)
                  ? Offset.zero
                  : const Offset(0, 1.0)),
        ));
  }

  Widget _desktopMangaPlayerButton(
      double? size, IconData icon, VoidCallback? onPressed) {
    return fluent.IconButton(
      style: fluent.ButtonStyle(
          shape: fluent.ButtonState.resolveWith((states) =>
              const fluent.RoundedRectangleBorder(
                  borderRadius:
                      fluent.BorderRadius.all(fluent.Radius.circular(50))))),
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: size,
      ),
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
