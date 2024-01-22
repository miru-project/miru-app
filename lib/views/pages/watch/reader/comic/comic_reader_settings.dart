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
import 'package:miru_app/views/widgets/settings/settings_tile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ComicReaderSettings extends StatefulWidget {
  const ComicReaderSettings(this.tag, {super.key});
  final String tag;

  @override
  State<ComicReaderSettings> createState() => _ComicReaderSettingsState();
}

class _ComicReaderSettingsState extends State<ComicReaderSettings> {
  late final ComicController _c = Get.find<ComicController>(tag: widget.tag);

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
                          SettingsSwitchTile(
                              icon: const Icon(Icons.coffee),
                              title: "reader-settings.enable-wakelock".i18n,
                              buildValue: () => MiruStorage.getSetting(
                                  SettingKey.enableWakelock),
                              onChanged: (val) {
                                WakelockPlus.toggle(enable: val);
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
