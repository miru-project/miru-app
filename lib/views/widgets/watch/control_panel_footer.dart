import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/controllers/watch/novel_controller.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

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
            child: Obx(
              () => Row(
                children: [
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
                        icon: const Icon(Icons.skip_previous_rounded),
                      ),
                    ),
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
                                value: _c.currentLocalProgress.value.toDouble(),
                                onChanged: (val) {
                                  _c.setControllPanel.value = true;
                                  _c.updateSlider.value = true;
                                  _c.progress.value =
                                      _c.localToGloabalProgress(val.toInt());
                                },
                              );
                            }
                            return const Slider(value: 0, onChanged: null);
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
                        icon: const Icon(Icons.skip_next_rounded),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 200),
        tween: Tween<Offset>(
          begin:
              (_c.isShowControlPanel.value) ? const Offset(0, 1) : Offset.zero,
          end: (_c.isShowControlPanel.value)
              ? Offset.zero
              : const Offset(0, 1.0),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
