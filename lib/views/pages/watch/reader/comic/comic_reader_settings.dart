import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
// import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:miru_app/views/widgets/watch/desktop_command_bar.dart';
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
  final fluent.FlyoutController _indicatorConfigFlyout =
      fluent.FlyoutController();
  final fluent.FlyoutController _indicatorAlignmentFlyout =
      fluent.FlyoutController();
  final alignMode = <String, Alignment>{
    "comic-settings.bottomLeft".i18n: Alignment.bottomLeft,
    "comic-settings.bottomRight".i18n: Alignment.bottomRight,
    "comic-settings.topLeft".i18n: Alignment.topLeft,
    "comic-settings.topRight".i18n: Alignment.topRight,
  }.obs;

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
    return Obx(() => fluent.CommandBarCard(
        // backgroundColor: fluent.FluentTheme.of(context).micaBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        margin: const EdgeInsets.fromLTRB(40, 20, 40, 0),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: fluent.CommandBar(
          isCompact: true,
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
                            items: _c.readmode.keys
                                .map((e) => fluent.MenuFlyoutItem(
                                      leading: _c.readType.value ==
                                              _c.readmode[e]!
                                          ? const Icon(
                                              fluent.FluentIcons.location_dot)
                                          : null,
                                      onPressed: () {
                                        _c.readType.value = _c.readmode[e]!;
                                      },
                                      text: Text(e),
                                    ))
                                .toList()));
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
            const CommnadBarDivider(),
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
            const CommnadBarDivider(),
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
            ),
            const CommnadBarDivider(),
            CommandBarFlyOutTarget(
                controller: _indicatorConfigFlyout,
                child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: fluent.IconButton(
                      icon: Row(children: [
                        const Icon(fluent.FluentIcons.number_field, size: 17),
                        const SizedBox(width: 8),
                        Text("comic-settings.status-bar".i18n)
                      ]),
                      onPressed: () {
                        _indicatorConfigFlyout.showFlyout(
                            builder: (context) => fluent.FlyoutContent(
                                  constraints:
                                      const BoxConstraints(maxWidth: 200),
                                  child: Obx(() => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                          _c.statusBarElement.length,
                                          (index) => fluent.FlyoutListTile(
                                                onPressed: () {
                                                  _c
                                                          .statusBarElement[
                                                              _c.statusBarElement
                                                                  .keys
                                                                  .elementAt(
                                                                      index)]!
                                                          .value =
                                                      !_c
                                                          .statusBarElement[_c
                                                              .statusBarElement
                                                              .keys
                                                              .elementAt(
                                                                  index)]!
                                                          .value;
                                                },
                                                text: Row(children: [
                                                  fluent.Checkbox(
                                                    checked: _c
                                                        .statusBarElement.values
                                                        .elementAt(index)
                                                        .value,
                                                    onChanged: (val) {
                                                      if (val == null) {
                                                        return;
                                                      }
                                                      _c
                                                          .statusBarElement[_c
                                                              .statusBarElement
                                                              .keys
                                                              .elementAt(
                                                                  index)]!
                                                          .value = val;
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(_c.statusBarElement.keys
                                                      .elementAt(index))
                                                ]),
                                              )))),
                                ));
                      },
                    ))),
            const CommnadBarDivider(),
            CommandBarFlyOutTarget(
              controller: _indicatorAlignmentFlyout,
              child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: fluent.IconButton(
                    icon: Row(children: [
                      const Icon(fluent.FluentIcons.align_center, size: 17),
                      const SizedBox(width: 8),
                      Text("comic-settings.indicator-alignment".i18n)
                    ]),
                    onPressed: () {
                      _indicatorAlignmentFlyout.showFlyout(
                          builder: (context) => fluent.FlyoutContent(
                                constraints:
                                    const BoxConstraints(maxWidth: 200),
                                child: Obx(() => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                        alignMode.keys.length,
                                        (index) => fluent.FlyoutListTile(
                                              onPressed: () {
                                                _c.alignMode.value = alignMode
                                                    .values
                                                    .elementAt(index);
                                              },
                                              selected: _c.alignMode.value ==
                                                  alignMode.values
                                                      .elementAt(index),
                                              text: Text(alignMode.keys
                                                  .elementAt(index)),
                                            )))),
                              ));
                    },
                  )),
            ),
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
