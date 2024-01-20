import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/comic_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/settings/settings_switch_tile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ComicReaderSettings extends StatefulWidget {
  const ComicReaderSettings(this.tag, {super.key});
  final String tag;

  @override
  State<ComicReaderSettings> createState() => _ComicReaderSettingsState();
}

class _ComicReaderSettingsState extends State<ComicReaderSettings> {
  late final ComicController _c = Get.find<ComicController>(tag: widget.tag);

  Widget _buildAndroid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 阅读模式

              Text('comic-settings.read-mode'.i18n),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton(
                  segments: [
                    ButtonSegment<MangaReadMode>(
                      value: MangaReadMode.standard,
                      label: Text('comic-settings.standard'.i18n),
                    ),
                    ButtonSegment<MangaReadMode>(
                      value: MangaReadMode.rightToLeft,
                      label: Text('comic-settings.right-to-left'.i18n),
                    ),
                    ButtonSegment<MangaReadMode>(
                      value: MangaReadMode.webTonn,
                      label: Text('comic-settings.web-tonn'.i18n),
                    ),
                  ],
                  selected: <MangaReadMode>{_c.readType.value},
                  onSelectionChanged: (value) {
                    if (value.isNotEmpty) {
                      _c.readType.value = value.first;
                    }
                  },
                  showSelectedIcon: false,
                ),
              ),

              const SizedBox(height: 16),
              Text('comic-settings.indicator-alignment'.i18n),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton(
                  segments: [
                    ButtonSegment<Alignment>(
                      value: Alignment.bottomLeft,
                      label: Text('comic-settings.bottomLeft'.i18n),
                    ),
                    ButtonSegment<Alignment>(
                      value: Alignment.bottomRight,
                      label: Text('comic-settings.rightLeft'.i18n),
                    ),
                    ButtonSegment<Alignment>(
                      value: Alignment.topLeft,
                      label: Text('comic-settings.topLeft'.i18n),
                    ),
                    ButtonSegment<Alignment>(
                      value: Alignment.topRight,
                      label: Text('comic-settings.topRight'.i18n),
                    )
                  ],
                  selected: <Alignment>{_c.alignMode.value},
                  onSelectionChanged: (value) {
                    if (value.isNotEmpty) {
                      _c.alignMode.value = value.first;
                    }
                  },
                  showSelectedIcon: false,
                ),
              ),
              const SizedBox(height: 16),
              Text('comic-settings.status-bar'.i18n),
              const SizedBox(height: 5),
              Wrap(
                spacing: 5,
                children: _c.statusBarElement.keys
                    .map((e) => FilterChip(
                        label: Text(e),
                        selected: _c.statusBarElement[e]!.value,
                        onSelected: (val) {
                          _c.statusBarElement[e]!.value = val;
                        }))
                    .toList(),
              ),
              SettingsSwitchTile(
                  icon: const Icon(Icons.coffee),
                  title: "reader-settings.enable-wakelock".i18n,
                  buildValue: () =>
                      MiruStorage.getSetting(SettingKey.enableWakelock),
                  onChanged: (val) {
                    WakelockPlus.toggle(enable: val);
                    MiruStorage.setSetting(SettingKey.enableWakelock, val);
                  }),
              const SizedBox(height: 16),
            ],
          )),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Obx(() {
      return fluent.Card(
        backgroundColor: fluent.FluentTheme.of(context).micaBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('comic-settings.read-mode'.i18n),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.ToggleButton(
                  checked: _c.readType.value == MangaReadMode.standard,
                  onChanged: (value) {
                    if (value) {
                      setState(() {
                        _c.readType.value = MangaReadMode.standard;
                      });
                    }
                  },
                  child: Text('comic-settings.standard'.i18n),
                ),
                const SizedBox(width: 8),
                fluent.ToggleButton(
                  checked: _c.readType.value == MangaReadMode.rightToLeft,
                  onChanged: (value) {
                    if (value) {
                      setState(() {
                        _c.readType.value = MangaReadMode.rightToLeft;
                      });
                    }
                  },
                  child: Text('comic-settings.right-to-left'.i18n),
                ),
                const SizedBox(width: 8),
                fluent.ToggleButton(
                  checked: _c.readType.value == MangaReadMode.webTonn,
                  onChanged: (value) {
                    if (value) {
                      setState(() {
                        _c.readType.value = MangaReadMode.webTonn;
                      });
                    }
                  },
                  child: Text('comic-settings.web-tonn'.i18n),
                )
              ],
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
