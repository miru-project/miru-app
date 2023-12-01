import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/button.dart';

class ControlPanelFooter<T extends ReaderController> extends StatelessWidget {
  const ControlPanelFooter(this.tag, {Key? key}) : super(key: key);
  final String tag;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<T>(tag: tag);
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Platform.isAndroid
            ? Theme.of(context).colorScheme.background.withOpacity(0.5)
            : Colors.transparent,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Obx(
        () => Row(
          children: [
            if (c.index.value > 0)
              PlatformFilledButton(
                child: Text('common.previous'.i18n),
                onPressed: () {
                  c.index.value--;
                },
              ),
            const Spacer(),
            if (c.index.value != c.playList.length - 1)
              PlatformFilledButton(
                child: Text('common.next'.i18n),
                onPressed: () {
                  c.index.value++;
                },
              ),
          ],
        ),
      ),
    ).animate().fade();
  }
}
