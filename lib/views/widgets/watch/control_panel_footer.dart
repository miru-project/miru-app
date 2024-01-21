import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/controllers/watch/novel_controller.dart';

class ControlPanelFooter<T extends ReaderController> extends StatelessWidget {
  const ControlPanelFooter(this.tag, {super.key});
  final String tag;
  @override
  Widget build(BuildContext context) {
    final c = Get.find<T>(tag: tag);
    final int total = (T == NovelController)
        ? c.watchData.value?.content.length ?? 0
        : c.watchData.value?.urls.length ?? 0;
    final totalObs = total.obs;
    final progressObs = c.progress.value.obs;
    ever(c.watchData, (callback) {
      progressObs.value = 0;
      totalObs.value = (T == NovelController)
          ? c.watchData.value?.content.length ?? 0
          : c.watchData.value?.urls.length ?? 0;
    });
    ever(c.progress, (callback) {
      progressObs.value = callback;
    });
    ever(c.isShowControlPanel, (callback) {
      debugPrint("scrolled ${c.progress.value}");
      progressObs.value = c.progress.value;
    });
    final double width = MediaQuery.of(context).size.width;
    final Color containerColor = Platform.isAndroid
        ? Theme.of(context).colorScheme.background.withOpacity(0.9)
        : Colors.transparent;

    return GestureDetector(
        child: SizedBox(
      height: 110,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Obx(() => Row(children: [
                const SizedBox(
                  height: 10,
                ),
                if (c.index.value > 0)
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: containerColor,
                      ),
                      child: IconButton(
                          onPressed: () {
                            c.index.value--;
                          },
                          icon: const Icon(Icons.skip_previous_rounded))),
                const Spacer(),
                SizedBox(
                    height: 50,
                    width: width * 2 / 3,
                    child: Material(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(30),
                        child: Obx(() {
                          if (totalObs.value != 0 ||
                              !c.isShowControlPanel.value) {
                            return Slider(
                              label: (progressObs.value + 1).toString(),
                              max: (totalObs.value - 1).toDouble(),
                              min: 0,
                              divisions: totalObs.value - 1,
                              value: progressObs.value.toDouble(),
                              onChanged: c.isShowControlPanel.value
                                  ? (val) {
                                      c.updateSlider.value = true;
                                      c.progress.value = val.toInt();
                                    }
                                  : null,
                            );
                          }
                          return const Slider(value: 0, onChanged: null);
                        }))),
                const Spacer(),
                if (c.index.value != c.playList.length - 1)
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: containerColor,
                      ),
                      child: IconButton(
                          onPressed: () {
                            c.index.value++;
                          },
                          icon: const Icon(Icons.skip_next_rounded)))
              ]))).animate().slideY(begin: 1, end: 0),
    ));
  }
}
