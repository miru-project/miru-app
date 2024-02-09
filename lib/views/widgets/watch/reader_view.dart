import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/layout.dart';
import 'package:miru_app/views/widgets/watch/control_panel_footer.dart';
import 'package:miru_app/views/widgets/watch/control_panel_header.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';

class ReaderView<T extends ReaderController> extends StatelessWidget {
  const ReaderView(
    this.tag, {
    super.key,
    required this.content,
    required this.buildSettings,
  });
  final String tag;
  final Widget content;
  final Widget Function(BuildContext context) buildSettings;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<T>(tag: tag);
    final width = LayoutUtils.width;
    return Obx(
      () => Stack(
        children: [
          MouseRegion(
            onHover: (Platform.isAndroid)
                ? null
                : (event) {
                    if (event.position.dy < 60 ||
                        event.position.dy > LayoutUtils.height - 60) {
                      c.setControllPanel.value = true;
                      return;
                    }
                    c.setControllPanel.value = false;
                  },
            child: content,
          ),

          // 点击中间显示控制面板
          // 左边上一页右边下一页
          if (c.error.value.isEmpty) ...[
            Padding(
                padding: EdgeInsets.fromLTRB(
                    0, 120, width - c.prevPageHitBox.value * width, 120),
                child: GestureDetector(
                  onTapDown: (details) {
                    if (c.tapRegionIsReversed.value) {
                      return c.nextPage();
                    }
                    return c.previousPage();
                  },
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(
                    width - c.nextPageHitBox.value * width, 120, 0, 120),
                child: GestureDetector(
                  onTapDown: (details) {
                    if (c.tapRegionIsReversed.value) {
                      return c.previousPage();
                    }
                    return c.nextPage();
                  },
                ))
          ]
          // Positioned(
          //   top: 120,
          //   bottom: 120,
          //   left: 0,
          //   right: 0,
          //   child: GestureDetector(
          //     onTapDown: (TapDownDetails details) {
          //       final xPos = details.globalPosition.dx;
          //       final width = LayoutUtils.width;
          //       // final unitWidth = width / 3;
          //       if (xPos < c.prevPageHitBox.value * width) {
          //         return c.previousPage();
          //       }
          //       if (xPos > width - c.nextPageHitBox.value * width) {
          //         return c.nextPage();
          //       }
          //       c.isShowControlPanel.value = !c.isShowControlPanel.value;
          //     },
          //   ),
          // ),

          ,
          if (c.isShowControlPanel.value || c.enableAutoScroll.value) ...[
            // 顶部控制
            Positioned(
              child: ControlPanelHeader<T>(
                tag,
                buildSettings: buildSettings,
              ),
            ),
            // 底部控制
          ],
          ControlPanelFooter<T>(tag),
        ],
      ),
    );
  }
}
