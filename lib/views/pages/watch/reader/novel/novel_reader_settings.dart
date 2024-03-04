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
import 'package:miru_app/views/widgets/watch/desktop_command_bar.dart';
import 'package:window_manager/window_manager.dart';

class NovelReaderSettings extends StatefulWidget {
  const NovelReaderSettings(this.tag, {super.key});
  final String tag;

  @override
  State<NovelReaderSettings> createState() => _NovelReaderSettingsState();
}

class _NovelReaderSettingsState extends State<NovelReaderSettings> {
  late final NovelController _c = Get.find<NovelController>(tag: widget.tag);
  // final fluent.FlyoutController _readModeFlyout = fluent.FlyoutController();
  // final fluent.FlyoutController _indicatorConfigFlyout =
  //     fluent.FlyoutController();
  // final fluent.FlyoutController _indicatorAlignmentFlyout =
  //     fluent.FlyoutController();
  final alignMode = <String, Alignment>{
    "comic-settings.bottomLeft".i18n: Alignment.bottomLeft,
    "comic-settings.bottomRight".i18n: Alignment.bottomRight,
    "comic-settings.topLeft".i18n: Alignment.topLeft,
    "comic-settings.topRight".i18n: Alignment.topRight,
  }.obs;
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
                          Text('reader-settings.read-mode'.i18n),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton(
                              segments: [
                                ButtonSegment<NovelReadMode>(
                                  value: NovelReadMode.scroll,
                                  label: Text('novel-settings.scroll'.i18n),
                                ),
                                ButtonSegment<NovelReadMode>(
                                  value: NovelReadMode.singlePage,
                                  label: Text('novel-settings.singlePage'.i18n),
                                ),
                                // ButtonSegment<NovelReadMode>(
                                //   value: NovelReadMode.doublePage,
                                //   label: Text('novel-settings.doublePage'.i18n),
                                // ),
                              ],
                              selected: <NovelReadMode>{_c.readType.value},
                              onSelectionChanged: (value) {
                                if (value.isNotEmpty) {
                                  _c.readType.value = value.first;
                                }
                              },
                              showSelectedIcon: false,
                            ),
                          ),
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
                                  MiruStorage.setSetting(
                                      SettingKey.novelFontSize, value);
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
                                MiruStorage.setSetting(
                                    SettingKey.leading, value);
                              },
                              label: _c.leading.value.toString(),
                              divisions: 40,
                              min: 0,
                              max: 4,
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
                                        _c.highLightColor.value =
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
                                        _c.highLightColor.value)),
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
                                        _c.highLightTextColor.value =
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
                                        _c.highLightTextColor.value)),
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
    return Obx(
      () => fluent.CommandBar(
        isCompact: true,
        primaryItems: <fluent.CommandBarItem>[
          const CommandBarSpacer(width: 16),
          fluent.CommandBarBuilderItem(
              builder: (context, mode, w) => fluent.Tooltip(
                  message: "comic-settings.read-mode".i18n, child: w),
              wrappedItem: CommandBarDropDownButton(
                  leading: const Icon(
                    fluent.FluentIcons.reading_mode,
                    size: 17,
                  ),
                  items: _c.readmode.keys
                      .map((e) => fluent.MenuFlyoutItem(
                          text: Text(e),
                          leading: _c.readType.value == _c.readmode[e]!
                              ? const Icon(fluent.FluentIcons.location_dot)
                              : null,
                          onPressed: () {
                            _c.readType.value = _c.readmode[e]!;
                          }))
                      .toList())),
          const CommandBarSpacer(),
          const CommnadBarDivider(),
          fluent.CommandBarBuilderItem(
              wrappedItem: fluent.CommandBarButton(
                label: SizedBox(
                    width: 40,
                    child: fluent.NumberBox(
                      max: _c.watchData.value?.content.length ?? 1,
                      min: 1,
                      mode: fluent.SpinButtonPlacementMode.none,
                      clearButton: false,
                      value: _c.progress.value + 1,
                      onChanged: (value) {
                        if (value != null) {
                          _c.updateSlider.value = true;
                          _c.progress.value = value - 1;
                        }
                      },
                    )),
                onPressed: null,
              ),
              builder: (context, mode, w) => fluent.Tooltip(
                    message: "comic-settings.page".i18n,
                    child: w,
                  )),
          CommandBarText(text: "/ ${_c.watchData.value?.content.length ?? 0}"),
          const CommnadBarDivider(),
          fluent.CommandBarBuilderItem(
            builder: (context, mode, w) => fluent.Tooltip(
              message: "reader-settings.enable-wakelock".i18n,
              child: w,
            ),
            wrappedItem: CommandBarToggleButton(
                onchange: (val) {
                  _c.enableWakeLock.value = val;
                  WakelockPlus.toggle(enable: val);
                  MiruStorage.setSetting(SettingKey.enableWakelock, val);
                },
                checked: _c.enableWakeLock.value,
                child: const Icon(fluent.FluentIcons.coffee_script, size: 17)),
          ),
          const CommnadBarDivider(),
          fluent.CommandBarBuilderItem(
            builder: (context, mode, w) => fluent.Tooltip(
              message: "reader-settings.enable-fullScreen".i18n,
              child: w,
            ),
            wrappedItem: CommandBarToggleButton(
                onchange: (val) async {
                  _c.enableFullScreen.value = val;
                  await windowManager.setFullScreen(val);
                },
                checked: _c.enableFullScreen.value,
                child: const Icon(fluent.FluentIcons.full_screen, size: 17)),
          ),
          const CommnadBarDivider(),
          const CommandBarSpacer(),
          fluent.CommandBarBuilderItem(
              builder: (context, mode, w) => fluent.Tooltip(
                    message: ("comic-settings.status-bar".i18n),
                    child: w,
                  ),
              wrappedItem: CommandBarDropDownButton(
                leading: const Icon(fluent.FluentIcons.number_field, size: 17),
                items: _c.statusBarElement.keys
                    .map((e) => fluent.MenuFlyoutItem(
                        leading: fluent.Checkbox(
                          checked: _c.statusBarElement[e]!.value,
                          onChanged: (val) {
                            if (val == null) {
                              return;
                            }
                            _c.statusBarElement[e]!.value = val;
                          },
                        ),
                        text: Text(e),
                        onPressed: () {
                          _c.statusBarElement[e]!.value =
                              !_c.statusBarElement[e]!.value;
                        }))
                    .toList(),
              )),
          const CommandBarSpacer(),
          fluent.CommandBarBuilderItem(
              builder: (conetx, mode, w) => fluent.Tooltip(
                    message: "comic-settings.indicator-alignment".i18n,
                    child: w,
                  ),
              wrappedItem: CommandBarDropDownButton(
                  items: alignMode.keys
                      .map((e) => fluent.MenuFlyoutItem(
                          leading: _c.alignMode.value == alignMode[e]!
                              ? const Icon(fluent.FluentIcons.location_dot)
                              : null,
                          text: Text(e),
                          onPressed: () {
                            _c.alignMode.value = alignMode[e]!;
                          }))
                      .toList(),
                  leading:
                      const Icon(fluent.FluentIcons.align_center, size: 17))),
          const CommandBarSpacer(),
          const CommnadBarDivider(),
          const CommandBarSpacer(),
          fluent.CommandBarBuilderItem(
              builder: (context, displayMode, w) => fluent.Tooltip(
                    message: "novel-settings.highlight-text-color".i18n,
                    child: w,
                  ),
              wrappedItem: CommandBarDropDownButton(
                  title: Stack(children: [
                    const Icon(
                      fluent.FluentIcons.fabric_text_highlight,
                      size: 17,
                      // color: _c.heighLightTextColor.value,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          width: 17,
                          height: 3,
                          color: _c.highLightTextColor.value,
                        ))
                  ]),
                  items: ColorUtils.baseColors
                      .map((e) => fluent.MenuFlyoutItem(
                          text: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: e,
                            ),
                            child: e == Colors.transparent
                                ? const Icon(
                                    fluent.FluentIcons.clear,
                                    size: 17,
                                  )
                                : null,
                          ),
                          onPressed: () {
                            _c.highLightTextColor.value = e;
                          }))
                      .toList())),
          const CommandBarSpacer(),
          fluent.CommandBarBuilderItem(
              builder: (context, displayMode, w) => fluent.Tooltip(
                    message: "novel-settings.text-color".i18n,
                    child: w,
                  ),
              wrappedItem: CommandBarDropDownButton(
                  title: Stack(children: [
                    const Icon(
                      fluent.FluentIcons.font_color_a,
                      size: 17,
                      // color: _c.textColor.value,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          width: 17,
                          height: 3,
                          color: _c.textColor.value,
                        ))
                  ]),
                  items: ColorUtils.baseColors
                      .map((e) => fluent.MenuFlyoutItem(
                          text: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: e,
                            ),
                            child: e == Colors.transparent
                                ? const Icon(
                                    fluent.FluentIcons.clear,
                                    size: 17,
                                  )
                                : null,
                          ),
                          onPressed: () {
                            _c.textColor.value = e;
                          }))
                      .toList())),
          const CommandBarSpacer(),
          fluent.CommandBarBuilderItem(
              builder: (context, mode, w) => fluent.Tooltip(
                    message: "novel-settings.highlight-color".i18n,
                    child: w,
                  ),
              wrappedItem: CommandBarDropDownButton(
                  title: Stack(children: [
                    const Icon(
                      fluent.FluentIcons.highlight,
                      size: 17,
                      // color: _c.highLightColor.value,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          width: 17,
                          height: 3,
                          color: _c.highLightColor.value,
                        ))
                  ]),
                  items: ColorUtils.baseColors
                      .map((e) => fluent.MenuFlyoutItem(
                          text: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: e,
                            ),
                            child: e == Colors.transparent
                                ? const Icon(
                                    fluent.FluentIcons.clear,
                                    size: 17,
                                  )
                                : null,
                          ),
                          onPressed: () {
                            _c.highLightColor.value = e;
                          }))
                      .toList())),
          const CommandBarSpacer(),
          const CommnadBarDivider(),
          const CommandBarSpacer(),
          fluent.CommandBarBuilderItem(
            builder: (contex, mode, w) => fluent.Tooltip(
              message: "novel-settings.font-size".i18n,
              child: w,
            ),
            wrappedItem: CommandBarNumberBox(
              onchange: (value) {
                if (value != null) {
                  _c.fontSize.value = value;
                  MiruStorage.setSetting(SettingKey.novelFontSize, value);
                }
              },
              value: _c.fontSize.value,
              min: 1,
              max: 30,
              title: const Icon(
                fluent.FluentIcons.font_size,
                size: 17,
              ),
            ),
          )
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
