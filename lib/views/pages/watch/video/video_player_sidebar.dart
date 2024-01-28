import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:miru_app/controllers/watch/video_controller.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/watch/playlist.dart';

class VideoPlayerSidebar extends StatefulWidget {
  const VideoPlayerSidebar({
    super.key,
    required this.controller,
  });
  final VideoPlayerController controller;

  @override
  State<VideoPlayerSidebar> createState() => _VideoPlayerSidebarState();
}

class _VideoPlayerSidebarState extends State<VideoPlayerSidebar> {
  late final _c = widget.controller;

  late final Map<String, Widget> _tabs = {
    "Episodes": PlayList(
      title: _c.title,
      list: _c.playList.map((e) => e.name).toList(),
      selectIndex: _c.index.value,
      onChange: (value) {
        _c.index.value = value;
        _c.showSidebar.value = false;
      },
    ),
    "Settings": _SideBarSettings(
      controller: _c,
    ),
  };

  Widget _buildAndroid(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Column(
        children: [
          TabBar(
            tabs: _tabs.keys.map((e) => Tab(text: e)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: _tabs.values.toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.FluentTheme(
      data: fluent.FluentThemeData(
        brightness: Brightness.dark,
      ),
      child: Container(
        color: fluent.FluentThemeData.dark().micaBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Row(
              children: [
                Text(
                  "Settings",
                  style: fluent.FluentThemeData.dark().typography.bodyLarge,
                ),
                const Spacer(),
                fluent.IconButton(
                  onPressed: () {
                    _c.showSidebar.value = false;
                  },
                  icon: const Icon(fluent.FluentIcons.chrome_close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _tabs["Settings"]!
          ],
        ),
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

class _SideBarSettings extends StatefulWidget {
  const _SideBarSettings({
    required this.controller,
  });
  final VideoPlayerController controller;

  @override
  State<_SideBarSettings> createState() => _SideBarSettingsState();
}

class _SideBarSettingsState extends State<_SideBarSettings> {
  late final _c = widget.controller;

  Widget _buildDesktop(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fluent.Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Subtitle'),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Font size'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => fluent.Slider(
                        value: _c.subtitleFontSize.value,
                        onChanged: (value) {
                          _c.subtitleFontSize.value = value;
                        },
                        min: 20,
                        max: 80,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(
                    () => Text(
                      _c.subtitleFontSize.value.toStringAsFixed(0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Font color'),
                  const SizedBox(width: 10),
                  fluent.SplitButton(
                    flyout: fluent.FlyoutContent(
                      constraints: const BoxConstraints(maxWidth: 200.0),
                      child: Obx(
                        () => Wrap(
                          runSpacing: 10.0,
                          spacing: 8.0,
                          children: [
                            fluent.Button(
                              autofocus:
                                  _c.subtitleFontColor.value == Colors.white,
                              style: fluent.ButtonStyle(
                                padding: fluent.ButtonState.all(
                                  const EdgeInsets.all(4.0),
                                ),
                              ),
                              onPressed: () {
                                _c.subtitleFontColor.value = Colors.white;
                                Navigator.of(context).pop(Colors.white);
                              },
                              child: Container(
                                height: 32,
                                width: 32,
                                color: Colors.white,
                              ),
                            ),
                            ...fluent.Colors.accentColors.map((color) {
                              return fluent.Button(
                                autofocus: _c.subtitleFontColor.value == color,
                                style: fluent.ButtonStyle(
                                  padding: fluent.ButtonState.all(
                                    const EdgeInsets.all(4.0),
                                  ),
                                ),
                                onPressed: () {
                                  _c.subtitleFontColor.value = color;
                                  Navigator.of(context).pop(color);
                                },
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  color: color,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    child: Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          color: _c.subtitleFontColor.value,
                          borderRadius:
                              const BorderRadiusDirectional.horizontal(
                            start: Radius.circular(4.0),
                          ),
                        ),
                        height: 32,
                        width: 36,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Background color'),
                  const SizedBox(width: 10),
                  fluent.SplitButton(
                    flyout: fluent.FlyoutContent(
                      constraints: const BoxConstraints(maxWidth: 200.0),
                      child: Obx(
                        () => Wrap(
                          runSpacing: 10.0,
                          spacing: 8.0,
                          children: [
                            fluent.Button(
                              autofocus: _c.subtitleBackgroundColor.value ==
                                  Colors.transparent,
                              style: fluent.ButtonStyle(
                                padding: fluent.ButtonState.all(
                                  const EdgeInsets.all(4.0),
                                ),
                              ),
                              onPressed: () {
                                _c.subtitleBackgroundColor.value =
                                    Colors.transparent;
                                Navigator.of(context).pop(Colors.transparent);
                              },
                              child: Container(
                                height: 32,
                                width: 32,
                                color: Colors.transparent,
                              ),
                            ),
                            ...fluent.Colors.accentColors.map((color) {
                              return fluent.Button(
                                autofocus:
                                    _c.subtitleBackgroundColor.value == color,
                                style: fluent.ButtonStyle(
                                  padding: fluent.ButtonState.all(
                                    const EdgeInsets.all(4.0),
                                  ),
                                ),
                                onPressed: () {
                                  _c.subtitleBackgroundColor.value = color;
                                  Navigator.of(context).pop(color);
                                },
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  color: color,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    child: Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          color: _c.subtitleBackgroundColor.value,
                          borderRadius:
                              const BorderRadiusDirectional.horizontal(
                            start: Radius.circular(4.0),
                          ),
                        ),
                        height: 32,
                        width: 36,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Background opacity'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => fluent.Slider(
                        value: _c.subtitleBackgroundColor.value.opacity,
                        onChanged: (value) {
                          _c.subtitleBackgroundColor.value = _c
                              .subtitleBackgroundColor.value
                              .withOpacity(value);
                        },
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(
                    () => Text(
                      _c.subtitleBackgroundColor.value.opacity
                          .toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // textAlign
              Row(
                children: [
                  const Text('Text align'),
                  const SizedBox(width: 10),
                  fluent.SplitButton(
                    flyout: fluent.FlyoutContent(
                      constraints: const BoxConstraints(maxWidth: 200.0),
                      child: Obx(
                        () => Wrap(
                          runSpacing: 10.0,
                          spacing: 8.0,
                          children: [
                            fluent.Button(
                              autofocus: _c.subtitleTextAlign.value ==
                                  TextAlign.justify,
                              style: fluent.ButtonStyle(
                                padding: fluent.ButtonState.all(
                                  const EdgeInsets.all(4.0),
                                ),
                              ),
                              onPressed: () {
                                _c.subtitleTextAlign.value = TextAlign.justify;
                                Navigator.of(context).pop(TextAlign.justify);
                              },
                              child: Container(
                                height: 32,
                                width: 32,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.format_align_justify,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            fluent.Button(
                              autofocus:
                                  _c.subtitleTextAlign.value == TextAlign.left,
                              style: fluent.ButtonStyle(
                                padding: fluent.ButtonState.all(
                                  const EdgeInsets.all(4.0),
                                ),
                              ),
                              onPressed: () {
                                _c.subtitleTextAlign.value = TextAlign.left;
                                Navigator.of(context).pop(TextAlign.left);
                              },
                              child: Container(
                                height: 32,
                                width: 32,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.format_align_left,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            fluent.Button(
                              autofocus:
                                  _c.subtitleTextAlign.value == TextAlign.right,
                              style: fluent.ButtonStyle(
                                padding: fluent.ButtonState.all(
                                  const EdgeInsets.all(4.0),
                                ),
                              ),
                              onPressed: () {
                                _c.subtitleTextAlign.value = TextAlign.right;
                                Navigator.of(context).pop(TextAlign.right);
                              },
                              child: Container(
                                height: 32,
                                width: 32,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.format_align_right,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            fluent.Button(
                              autofocus: _c.subtitleTextAlign.value ==
                                  TextAlign.center,
                              style: fluent.ButtonStyle(
                                padding: fluent.ButtonState.all(
                                  const EdgeInsets.all(4.0),
                                ),
                              ),
                              onPressed: () {
                                _c.subtitleTextAlign.value = TextAlign.center;
                                Navigator.of(context).pop(TextAlign.center);
                              },
                              child: Container(
                                height: 32,
                                width: 32,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.format_align_center,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: Obx(
                      () => SizedBox(
                        height: 32,
                        width: 36,
                        child: Icon(
                          _c.subtitleTextAlign.value == TextAlign.justify
                              ? Icons.format_align_justify
                              : _c.subtitleTextAlign.value == TextAlign.left
                                  ? Icons.format_align_left
                                  : _c.subtitleTextAlign.value ==
                                          TextAlign.right
                                      ? Icons.format_align_right
                                      : Icons.format_align_center,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text("Font weight"),
              const SizedBox(height: 10),
              Obx(
                () => Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    fluent.ToggleButton(
                      checked: _c.subtitleFontWeight.value == FontWeight.normal,
                      onChanged: (value) {
                        _c.subtitleFontWeight.value = FontWeight.normal;
                      },
                      child: const Text("Normal"),
                    ),
                    fluent.ToggleButton(
                      checked: _c.subtitleFontWeight.value == FontWeight.bold,
                      onChanged: (value) {
                        _c.subtitleFontWeight.value = FontWeight.bold;
                      },
                      child: const Text("Bold"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        fluent.Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Play mode"),
              const SizedBox(
                height: 10,
                width: double.infinity,
              ),
              Obx(
                () => Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    fluent.ToggleButton(
                      checked: _c.playMode.value == PlaylistMode.loop,
                      onChanged: (value) {
                        _c.playMode.value = PlaylistMode.loop;
                      },
                      child: const Text("Loop"),
                    ),
                    fluent.ToggleButton(
                      checked: _c.playMode.value == PlaylistMode.single,
                      onChanged: (value) {
                        _c.playMode.value = PlaylistMode.single;
                      },
                      child: const Text("Single"),
                    ),
                    fluent.ToggleButton(
                      checked: _c.playMode.value == PlaylistMode.none,
                      onChanged: (value) {
                        _c.playMode.value = PlaylistMode.none;
                      },
                      child: const Text("Auto next"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
