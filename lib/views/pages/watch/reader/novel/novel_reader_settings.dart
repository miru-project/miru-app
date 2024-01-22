import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/watch/novel_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/views/widgets/settings/settings_switch_tile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class NovelReaderSettings extends StatefulWidget {
  const NovelReaderSettings(this.tag, {super.key});
  final String tag;

  @override
  State<NovelReaderSettings> createState() => _NovelReaderSettingsState();
}

class _NovelReaderSettingsState extends State<NovelReaderSettings> {
  late final NovelController _c = Get.find<NovelController>(tag: widget.tag);

  Widget _buildAndroid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("novel-settings.font-size".i18n),
              const SizedBox(height: 16),
              Slider(
                value: _c.fontSize.value,
                label: _c.fontSize.value.toString(),
                onChanged: (value) {
                  _c.fontSize.value = value;
                },
                divisions: 12,
                min: 12,
                max: 24,
              ),
              const SizedBox(height: 16),
              SettingsSwitchTile(
                  icon: const Icon(Icons.coffee),
                  title: "reader-settings.enable-wakelock".i18n,
                  buildValue: () =>
                      MiruStorage.getSetting(SettingKey.enableWakelock),
                  onChanged: (val) {
                    WakelockPlus.toggle(enable: val);
                    MiruStorage.setSetting(SettingKey.enableWakelock, val);
                  })
            ],
          )),
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
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
