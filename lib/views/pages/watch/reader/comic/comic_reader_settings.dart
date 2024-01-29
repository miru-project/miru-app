import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
// import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/controllers/watch/comic_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/settings/settings_switch_tile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

class ComicReaderSettings extends StatefulWidget {
  const ComicReaderSettings(this.tag, {super.key});
  final String tag;

  @override
  State<ComicReaderSettings> createState() => _ComicReaderSettingsState();
}

class _ComicReaderSettingsState extends State<ComicReaderSettings> {
  late final ComicController _c = Get.find<ComicController>(tag: widget.tag);
  final fluent.FlyoutController _readModeFlyout = fluent.FlyoutController();
  // double nextPageHitBox = MiruStorage.getSetting(SettingKey.nextPageHitBox);
  // double prevPageHitBox = MiruStorage.getSetting(SettingKey.prevPageHitBox);
  Widget _buildAndroid(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(tabs: [
              Tab(
                text: "Common".i18n,
              ),
              Tab(
                text: "Webtoon".i18n,
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
                                  label:
                                      Text('comic-settings.right-to-left'.i18n),
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
                                  if (value.first ==
                                      MangaReadMode.rightToLeft) {
                                    _c.tapRegionIsReversed.value = true;
                                    return;
                                  }
                                  _c.tapRegionIsReversed.value = false;
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
                                  label: Column(children: [
                                    Text('comic-settings.bottomLeft'.i18n),
                                    const SizedBox(height: 5),
                                    Transform.rotate(
                                        angle: -3.14,
                                        child: const Icon(Icons.arrow_outward))
                                  ]),
                                ),
                                ButtonSegment<Alignment>(
                                  value: Alignment.bottomRight,
                                  label: Column(children: [
                                    Text('comic-settings.bottomRight'.i18n),
                                    const SizedBox(height: 5),
                                    Transform.rotate(
                                        angle: 1.57,
                                        child: const Icon(Icons.arrow_outward))
                                  ]),
                                ),
                                ButtonSegment<Alignment>(
                                  value: Alignment.topLeft,
                                  label: Column(children: [
                                    Text('comic-settings.topLeft'.i18n),
                                    const SizedBox(height: 5),
                                    Transform.rotate(
                                        angle: -1.57,
                                        child: const Icon(Icons.arrow_outward))
                                  ]),
                                ),
                                ButtonSegment<Alignment>(
                                  value: Alignment.topRight,
                                  label: Column(children: [
                                    Text('comic-settings.topRight'.i18n),
                                    const SizedBox(height: 5),
                                    const Icon(Icons.arrow_outward)
                                  ]),
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
                          const SizedBox(height: 16),
                          Text('comic-settings.nextPageHitBox'.i18n),
                          Slider(
                              value: _c.nextPageHitBox.value,
                              max: 0.5,
                              divisions: 20,
                              label: _c.nextPageHitBox.toString(),
                              onChanged: (val) {
                                setState(() {
                                  _c.nextPageHitBox.value = val;
                                });
                                MiruStorage.setSetting(
                                    SettingKey.nextPageHitBox, val);
                              }),
                          const SizedBox(height: 16),
                          Text('comic-settings.prevPageHitBox'.i18n),
                          Slider(
                              value: _c.prevPageHitBox.value,
                              max: 0.5,
                              divisions: 20,
                              label: _c.prevPageHitBox.toString(),
                              onChanged: (val) {
                                setState(() {
                                  _c.prevPageHitBox.value = val;
                                });
                                MiruStorage.setSetting(
                                    SettingKey.prevPageHitBox, val);
                              }),
                          Obx(() => SettingsSwitchTile(
                              icon: const Icon(Icons.coffee),
                              title: "reader-settings.enable-wakelock".i18n,
                              buildValue: () => _c.enableWakeLock.value,
                              onChanged: (val) {
                                WakelockPlus.toggle(enable: val);
                                _c.enableWakeLock.value = val;
                                MiruStorage.setSetting(
                                    SettingKey.enableWakelock, val);
                              })),
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
                              title: "reader-settings.enable-autoscroller".i18n,
                              buildValue: () => _c.enableAutoScroll.value,
                              onChanged: (val) {
                                Get.back();
                                _c.enableAutoScroll.value = val;
                              }),
                          const SizedBox(height: 16),
                          Text('reader-settings.auto-scroller-interval'.i18n),
                          Slider(
                              value: _c.autoScrollInterval.value.toDouble(),
                              max: 500.0,
                              divisions: 25,
                              label: "${_c.autoScrollInterval} ms",
                              onChanged: (val) {
                                _c.autoScrollInterval.value = val.toInt();
                                MiruStorage.setSetting(
                                    SettingKey.autoScrollInterval, val.toInt());
                              }),
                          const SizedBox(height: 16),
                          Text('reader-settings.auto-scroller-offset'.i18n),
                          Slider(
                              value: _c.autoScrollOffset.value,
                              max: 300.0,
                              divisions: 30,
                              label: "${_c.autoScrollOffset} pixels",
                              onChanged: (val) {
                                _c.autoScrollOffset.value = val;
                                MiruStorage.setSetting(
                                    SettingKey.autoScrollOffset, val);
                              }),
                        ],
                      )),
                )
              ]),
            )
          ],
        ));
  }

  Widget _buildDesktop(BuildContext context) {
    return Obx(() => fluent.CommandBar(
          primaryItems: <fluent.CommandBarItem>[
            CommandBarFlyOutTarget(
                controller: _readModeFlyout,
                child: fluent.IconButton(
                  icon: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(
                      fluent.FluentIcons.reading_mode,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Text("comic-settings.read-mode".i18n)
                  ]),
                  onPressed: () {
                    _readModeFlyout.showFlyout(
                        builder: (context) => fluent.MenuFlyout(
                              items: [
                                fluent.MenuFlyoutItem(
                                    leading: _c.readType.value ==
                                            MangaReadMode.standard
                                        ? const Icon(
                                            fluent.FluentIcons.location_dot)
                                        : null,
                                    text: Text("comic-settings.standard".i18n),
                                    onPressed: () {
                                      _c.readType.value =
                                          MangaReadMode.standard;
                                    }),
                                fluent.MenuFlyoutItem(
                                    leading: _c.readType.value ==
                                            MangaReadMode.rightToLeft
                                        ? const Icon(
                                            fluent.FluentIcons.location_dot)
                                        : null,
                                    text: Text(
                                        "comic-settings.right-to-left".i18n),
                                    onPressed: () {
                                      _c.readType.value =
                                          MangaReadMode.rightToLeft;
                                    }),
                                fluent.MenuFlyoutItem(
                                    leading: _c.readType.value ==
                                            MangaReadMode.webTonn
                                        ? const Icon(
                                            fluent.FluentIcons.location_dot)
                                        : null,
                                    text: Text("comic-settings.web-tonn".i18n),
                                    onPressed: () {
                                      _c.readType.value = MangaReadMode.webTonn;
                                    })
                              ],
                            ));
                  },
                )),
            fluent.CommandBarBuilderItem(
                wrappedItem: fluent.CommandBarButton(
                  label: SizedBox(
                      width: 40,
                      child: fluent.NumberBox(
                        max: _c.watchData.value?.urls.length ?? 1,
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
                builder: (context, mode, w) => Tooltip(
                      message: "comic-settings.page".i18n,
                      child: w,
                    )),
            CommandBarText(text: "/ ${_c.watchData.value?.urls.length ?? 0}"),
            const fluent.CommandBarSeparator(thickness: 3),
            fluent.CommandBarBuilderItem(
              builder: (context, mode, w) => Tooltip(
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
                  child:
                      const Icon(fluent.FluentIcons.coffee_script, size: 17)),
            ),
            const fluent.CommandBarSeparator(thickness: 3),
            fluent.CommandBarBuilderItem(
              builder: (context, mode, w) => Tooltip(
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
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}

class CommandBarDropDownButton extends fluent.CommandBarItem {
  const CommandBarDropDownButton(
      {super.key, required this.items, this.onPressed, this.icon, this.label});
  final List<fluent.MenuFlyoutItem> items;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? label;

  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[icon!, const SizedBox(width: 8)],
      fluent.DropDownButton(items: items)
    ]);
  }
}

class CommandBarFlyOutTarget extends fluent.CommandBarItem {
  const CommandBarFlyOutTarget(
      {super.key, required this.controller, required this.child, this.label});
  final fluent.FlyoutController controller;
  final Widget child;
  final Widget? label;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (label != null) ...[
        label!,
        const SizedBox(
          width: 6.0,
        )
      ],
      fluent.FlyoutTarget(
        controller: controller,
        child: child,
      )
    ]);
  }
}

class CommandBarText extends fluent.CommandBarItem {
  const CommandBarText({super.key, required this.text});
  final String text;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Padding(padding: const EdgeInsets.all(10), child: Text(text));
  }
}

class CommandBarToggleButton extends fluent.CommandBarItem {
  const CommandBarToggleButton(
      {super.key,
      required this.onchange,
      required this.checked,
      required this.child});
  final bool checked;
  final void Function(bool)? onchange;
  final Widget child;
  @override
  Widget build(
      BuildContext context, fluent.CommandBarItemDisplayMode displayMode) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: fluent.ToggleButton(
          checked: checked,
          onChanged: onchange,
          child: child,
        ));
  }
}
