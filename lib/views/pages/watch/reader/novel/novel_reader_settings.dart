import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/watch/novel_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class NovelReaderSettings extends StatefulWidget {
  const NovelReaderSettings(this.tag, {super.key});
  final String tag;

  @override
  State<NovelReaderSettings> createState() => _NovelReaderSettingsState();
}

class _NovelReaderSettingsState extends State<NovelReaderSettings> {
  late final NovelController _c = Get.find<NovelController>(tag: widget.tag);

  Widget _buildMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("novel-settings.font-size".i18n),
          const SizedBox(height: 16),
          Obx(
            () => Slider(
              value: _c.fontSize.value,
              onChanged: (value) {
                _c.fontSize.value = value;
              },
              min: 12,
              max: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.Card(
      backgroundColor: fluent.FluentTheme.of(context).micaBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("novel-settings.font-size".i18n),
          const SizedBox(height: 16),
          Obx(
            () => SizedBox(
              width: 200,
              child: fluent.Slider(
                value: _c.fontSize.value,
                onChanged: (value) {
                  _c.fontSize.value = value;
                },
                min: 12,
                max: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
