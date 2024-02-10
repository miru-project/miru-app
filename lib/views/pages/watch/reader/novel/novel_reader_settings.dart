import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/watch/novel_controller.dart';
import 'package:miru_app/utils/color.dart';
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
    return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(tabs: [
              Tab(
                text: "common.common".i18n,
              ),
              Tab(text: "common.tts".i18n),
              Tab(
                text: "settings.theme".i18n,
              )
            ]),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 阅读模式
                          const SizedBox(height: 16),
                          Text('reader-settings.indicator-alignment'.i18n),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton(
                              segments: [
                                ButtonSegment<Alignment>(
                                  value: Alignment.bottomLeft,
                                  label: Transform.rotate(
                                      angle: -3.14,
                                      child: const Icon(Icons.arrow_outward)),
                                ),
                                ButtonSegment<Alignment>(
                                  value: Alignment.bottomRight,
                                  label: Transform.rotate(
                                      angle: 1.57,
                                      child: const Icon(Icons.arrow_outward)),
                                ),
                                ButtonSegment<Alignment>(
                                  value: Alignment.topLeft,
                                  label: Transform.rotate(
                                      angle: -1.57,
                                      child: const Icon(Icons.arrow_outward)),
                                ),
                                const ButtonSegment<Alignment>(
                                  value: Alignment.topRight,
                                  label: Icon(Icons.arrow_outward),
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
                              buildValue: () => _c.enableWakeLock.value,
                              onChanged: (val) {
                                WakelockPlus.toggle(enable: val);
                                _c.enableWakeLock.value = val;
                                MiruStorage.setSetting(
                                    SettingKey.enableWakelock, val);
                              }),
                          const SizedBox(height: 16),
                          Text('novel-settings.font-size'.i18n),
                          const SizedBox(height: 5),
                          SizedBox(
                              width: double.infinity,
                              child: Slider(
                                value: _c.fontSize.value,
                                onChanged: (value) {
                                  _c.fontSize.value = value;
                                },
                                label: _c.fontSize.value.toString(),
                                divisions: 24,
                                min: 12,
                                max: 24,
                              )),
                          const SizedBox(height: 16),
                          Text("novel-settings.leading".i18n),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: double.infinity,
                            child: Slider(
                              value: _c.leading.value,
                              onChanged: (value) {
                                _c.leading.value = value;
                              },
                              label: _c.leading.value.toString(),
                              divisions: 40,
                              min: 0,
                              max: 40,
                            ),
                          ),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SettingsSwitchTile(
                              icon: const Icon(Icons.play_arrow_rounded),
                              title: "novel-settings.enable-tts".i18n,
                              buildValue: () => _c.enableAutoScroll.value,
                              onChanged: (val) {
                                Get.back();
                                _c.enableAutoScroll.value = val;
                              }),
                          const SizedBox(height: 16),
                          // Text('novel-settings.ttslang'.i18n),
                          // const SizedBox(height: 5),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('novel-settings.tts-lang'.i18n),
                                DropdownMenu<String>(
                                  initialSelection: _c.ttsLangValue.value,
                                  dropdownMenuEntries: _c.ttsLang
                                      .map<DropdownMenuEntry<String>>(
                                          (element) {
                                    return DropdownMenuEntry<String>(
                                      value: element,
                                      label: element.toString(),
                                    );
                                  }).toList(),
                                  onSelected: (String? newValue) {
                                    if (newValue != null) {
                                      _c.ttsLangValue.value = newValue;
                                      MiruStorage.setSetting(
                                          SettingKey.ttsLanguage, newValue);
                                    }
                                  },
                                )
                              ]),
                          const SizedBox(height: 16),
                          Text('novel-settings.tts-rate'.i18n),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: double.infinity,
                            child: Slider(
                              value: _c.ttsRate.value,
                              onChanged: (value) {
                                _c.ttsRate.value = value;
                                MiruStorage.setSetting(
                                    SettingKey.ttsRate, value);
                              },
                              min: 0,
                              max: 1,
                              divisions: 20,
                              label: _c.ttsRate.value.toStringAsFixed(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('novel-settings.tts-volume'.i18n),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: double.infinity,
                            child: Slider(
                              value: _c.ttsVolume.value,
                              onChanged: (value) {
                                _c.ttsVolume.value = value;
                                MiruStorage.setSetting(
                                    SettingKey.ttsVolume, value);
                              },
                              min: 0,
                              max: 1,
                              divisions: 20,
                              label: _c.ttsVolume.value.toStringAsFixed(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('novel-settings.tts-pitch'.i18n),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: double.infinity,
                            child: Slider(
                              value: _c.ttsPitch.value,
                              onChanged: (value) {
                                _c.ttsPitch.value = value;
                                MiruStorage.setSetting(
                                    SettingKey.ttsPitch, value);
                              },
                              label: _c.ttsPitch.value.toStringAsFixed(2),
                              min: 0.5,
                              max: 2,
                              divisions: 30,
                            ),
                          ),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("novel-settings.text-color".i18n),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 5,
                            children: List<Widget>.generate(
                                ColorUtils.baseColors.length,
                                (index) => ChoiceChip(
                                    onSelected: (val) {
                                      if (val) {
                                        _c.textColor.value =
                                            ColorUtils.baseColors[index];
                                        // MiruStorage.setSetting(
                                        //     SettingKey.textColor,
                                        //     ColorUtils.baseColors[index]);
                                      }
                                    },
                                    label: Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ColorUtils.baseColors[index],
                                      ),
                                    ),
                                    selected: ColorUtils.baseColors[index] ==
                                        _c.textColor.value)),
                          ),
                          const SizedBox(height: 16),
                          Text("novel-settings.heighlight-color".i18n),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 5,
                            children: List<Widget>.generate(
                                ColorUtils.baseColors.length,
                                (index) => ChoiceChip(
                                    onSelected: (val) {
                                      if (val) {
                                        _c.heighLightColor.value =
                                            ColorUtils.baseColors[index];
                                      }
                                    },
                                    label: Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ColorUtils.baseColors[index],
                                      ),
                                    ),
                                    selected: ColorUtils.baseColors[index] ==
                                        _c.heighLightColor.value)),
                          ),
                          const SizedBox(height: 16),
                          Text("novel-settings.heighlight-text-color".i18n),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 5,
                            children: List<Widget>.generate(
                                ColorUtils.baseColors.length,
                                (index) => ChoiceChip(
                                    onSelected: (val) {
                                      if (val) {
                                        _c.heighLightTextColor.value =
                                            ColorUtils.baseColors[index];
                                      }
                                    },
                                    label: Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ColorUtils.baseColors[index],
                                      ),
                                    ),
                                    selected: ColorUtils.baseColors[index] ==
                                        _c.heighLightTextColor.value)),
                          ),
                        ],
                      )),
                )
              ]),
            )
          ],
        ));
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
