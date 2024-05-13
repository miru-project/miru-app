import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:miru_app/controllers/watch/video_controller.dart';
import 'package:miru_app/utils/color.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/list_title.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/watch/playlist.dart';

enum SidebarTab {
  episodes,
  qualitys,
  torrentFiles,
  tracks,
  settings,
}

_sidebarTabToString(SidebarTab tab) {
  return "video.sidebar.tab.${tab.name}".i18n;
}

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

  late final Map<SidebarTab, Widget> _tabs = {
    SidebarTab.episodes: PlayList(
      title: _c.title,
      list: _c.playList.map((e) => e.name).toList(),
      selectIndex: _c.index.value,
      onChange: (value) {
        _c.index.value = value;
        _c.showSidebar.value = false;
      },
    ),
  };

  Widget _buildMobile(BuildContext context) {
    return Container(
      color: ThemeData.dark().colorScheme.background,
      child: DefaultTabController(
        length: _tabs.length,
        initialIndex: !_tabs.keys.toList().contains(_c.initSidebarTab.value)
            ? 0
            : _tabs.keys.toList().indexOf(_c.initSidebarTab.value),
        child: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              tabs: _tabs.keys
                  .map((e) => Tab(text: _sidebarTabToString(e)))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                children: _tabs.values.toList(),
              ),
            ),
          ],
        ),
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
                  "common.settings".i18n,
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
            _tabs[SidebarTab.settings]!
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_c.torrentMediaFileList.isNotEmpty) {
      _tabs.addAll(
        {
          SidebarTab.torrentFiles: _TorrentFiles(
            controller: _c,
          ),
        },
      );
    }

    if (_c.qualityMap.isNotEmpty) {
      _tabs.addAll(
        {
          SidebarTab.qualitys: _QualitySelector(
            controller: _c,
          ),
        },
      );
    }

    _tabs.addAll(
      {
        SidebarTab.tracks: _TrackSelector(
          controller: _c,
        ),
        SidebarTab.settings: _SideBarSettings(
          controller: _c,
        ),
      },
    );
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('video.sidebar.subtitle.title'.i18n),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('video.sidebar.subtitle.font-size'.i18n),
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
                  Text('video.sidebar.subtitle.font-color'.i18n),
                  const SizedBox(width: 10),
                  fluent.SplitButton(
                    flyout: fluent.FlyoutContent(
                      constraints: const BoxConstraints(maxWidth: 200.0),
                      child: Obx(
                        () => Wrap(
                          runSpacing: 10.0,
                          spacing: 8.0,
                          children: [
                            ...ColorUtils.baseColors.map((color) {
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
                  Text('video.sidebar.subtitle.background-color'.i18n),
                  const SizedBox(width: 10),
                  fluent.SplitButton(
                    flyout: fluent.FlyoutContent(
                      constraints: const BoxConstraints(maxWidth: 200.0),
                      child: Obx(
                        () => Wrap(
                          runSpacing: 10.0,
                          spacing: 8.0,
                          children: [
                            ...ColorUtils.baseColors.map((color) {
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
                  Text('video.sidebar.subtitle.background-opacity'.i18n),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => fluent.Slider(
                        value: _c.subtitleBackgroundOpacity.value,
                        onChanged: (value) {
                          _c.subtitleBackgroundOpacity.value = value;
                        },
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(
                    () => Text(
                      _c.subtitleBackgroundOpacity.value.toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // textAlign
              Row(
                children: [
                  Text('video.sidebar.subtitle.text-align'.i18n),
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
              Text('video.sidebar.subtitle.font-weight'.i18n),
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
                      child: Text(
                        'video.sidebar.subtitle.font-weight-normal'.i18n,
                      ),
                    ),
                    fluent.ToggleButton(
                      checked: _c.subtitleFontWeight.value == FontWeight.bold,
                      onChanged: (value) {
                        _c.subtitleFontWeight.value = FontWeight.bold;
                      },
                      child: Text(
                        'video.sidebar.subtitle.font-weight-bold'.i18n,
                      ),
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('video.sidebar.play-mode.title'.i18n),
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
                      child: Text('video.sidebar.play-mode.loop'.i18n),
                    ),
                    fluent.ToggleButton(
                      checked: _c.playMode.value == PlaylistMode.single,
                      onChanged: (value) {
                        _c.playMode.value = PlaylistMode.single;
                      },
                      child: Text('video.sidebar.play-mode.single'.i18n),
                    ),
                    fluent.ToggleButton(
                      checked: _c.playMode.value == PlaylistMode.none,
                      onChanged: (value) {
                        _c.playMode.value = PlaylistMode.none;
                      },
                      child: Text('video.sidebar.play-mode.auto-next'.i18n),
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

  Widget _buildMobile(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      children: [
        Text(
          'video.sidebar.subtitle.title'.i18n,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 20),
        Text('video.sidebar.subtitle.font-size'.i18n),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => SliderTheme(
                  data: SliderThemeData(
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _c.subtitleFontSize.value,
                    onChanged: (value) {
                      _c.subtitleFontSize.value = value;
                    },
                    min: 20,
                    max: 80,
                  ),
                ),
              ),
            ),
            Obx(
              () => Text(
                _c.subtitleFontSize.value.toStringAsFixed(0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('video.sidebar.subtitle.font-color'.i18n),
        const SizedBox(height: 10),
        Obx(
          () {
            final selectColor = _c.subtitleFontColor.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final color in ColorUtils.baseColors) ...[
                    GestureDetector(
                      onTap: () {
                        _c.subtitleFontColor.value = color;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: selectColor == color
                              ? Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                )
                              : null,
                          color: color,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        height: 32,
                        width: 32,
                      ),
                    ),
                    const SizedBox(width: 10)
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text('video.sidebar.subtitle.background-color'.i18n),
        const SizedBox(height: 10),
        Obx(
          () {
            final selectColor = _c.subtitleBackgroundColor.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final color in ColorUtils.baseColors) ...[
                    GestureDetector(
                      onTap: () {
                        _c.subtitleBackgroundColor.value = color;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: selectColor == color
                              ? Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                )
                              : null,
                          color: color,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        height: 32,
                        width: 32,
                      ),
                    ),
                    const SizedBox(width: 10)
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          'video.sidebar.subtitle.background-opacity'.i18n,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => SliderTheme(
                  data: SliderThemeData(
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _c.subtitleBackgroundOpacity.value,
                    onChanged: (value) {
                      _c.subtitleBackgroundOpacity.value = value;
                    },
                    min: 0,
                    max: 1,
                  ),
                ),
              ),
            ),
            Obx(
              () => Text(
                _c.subtitleBackgroundOpacity.value.toStringAsFixed(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // textAlign
        Text('video.sidebar.subtitle.text-align'.i18n),
        const SizedBox(height: 10),

        Obx(
          () => Wrap(
            children: [
              for (final align in TextAlign.values) ...[
                GestureDetector(
                  onTap: () {
                    _c.subtitleTextAlign.value = align;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: _c.subtitleTextAlign.value == align
                          ? Border.all(
                              color: Colors.grey,
                              width: 2,
                            )
                          : null,
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    height: 32,
                    width: 32,
                    child: Icon(
                      align == TextAlign.justify
                          ? Icons.format_align_justify
                          : align == TextAlign.left
                              ? Icons.format_align_left
                              : align == TextAlign.right
                                  ? Icons.format_align_right
                                  : Icons.format_align_center,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10)
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'video.sidebar.subtitle.font-weight'.i18n,
        ),
        const SizedBox(height: 10),
        Obx(
          () => SegmentedButton(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: FontWeight.normal,
                label: Text(
                  'video.sidebar.subtitle.font-weight-normal'.i18n,
                ),
              ),
              ButtonSegment(
                value: FontWeight.bold,
                label: Text(
                  'video.sidebar.subtitle.font-weight-bold'.i18n,
                ),
              ),
            ],
            selected: <FontWeight>{_c.subtitleFontWeight.value},
            onSelectionChanged: (value) {
              _c.subtitleFontWeight.value = value.first;
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'video.sidebar.play-mode.title'.i18n,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 10),
        Obx(
          () => SegmentedButton(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: PlaylistMode.loop,
                label: Text(
                  'video.sidebar.play-mode.loop'.i18n,
                ),
              ),
              ButtonSegment(
                value: PlaylistMode.single,
                label: Text(
                  'video.sidebar.play-mode.single'.i18n,
                ),
              ),
              ButtonSegment(
                value: PlaylistMode.none,
                label: Text(
                  'video.sidebar.play-mode.auto-next'.i18n,
                ),
              ),
            ],
            selected: <PlaylistMode>{_c.playMode.value},
            onSelectionChanged: (value) {
              _c.playMode.value = value.first;
            },
          ),
        ),
      ],
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

class _QualitySelector extends StatefulWidget {
  const _QualitySelector({
    required this.controller,
  });
  final VideoPlayerController controller;

  @override
  State<_QualitySelector> createState() => _QualitySelectorState();
}

class _QualitySelectorState extends State<_QualitySelector> {
  late final _c = widget.controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final quality in _c.qualityMap.entries)
          ListTile(
            onTap: () {
              _c.switchQuality(quality.value);
              _c.showSidebar.value = false;
            },
            title: Text(
              quality.key,
            ),
          ),
      ],
    );
  }
}

class _TrackSelector extends StatelessWidget {
  const _TrackSelector({
    required this.controller,
  });
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        ListTitle(
          title: 'video.subtitle'.i18n,
        ),
        ListTile(
          selected:
              SubtitleTrack.no() == controller.player.state.track.subtitle,
          title: Text('common.off'.i18n),
          onTap: () {
            controller.setSubtitleTrack(
              SubtitleTrack.no(),
            );
            controller.showSidebar.value = false;
          },
        ),
        ListTile(
          title: Text('video.subtitle-file'.i18n),
          onTap: () {
            controller.addSubtitleFile();
            controller.showSidebar.value = false;
          },
        ),
        // 来自扩展的字幕
        for (final subtitle in controller.subtitles)
          ListTile(
            selected: subtitle == controller.player.state.track.subtitle,
            title: Text(subtitle.title ?? ''),
            subtitle: Text(subtitle.language ?? ''),
            onTap: () {
              controller.setSubtitleTrack(
                subtitle,
              );
              controller.showSidebar.value = false;
            },
          ),
        // 来自视频本身的字幕
        for (final subtitle in controller.player.state.tracks.subtitle)
          if (subtitle != SubtitleTrack.no() &&
              (subtitle.language != null || subtitle.title != null))
            ListTile(
              selected: subtitle == controller.player.state.track.subtitle,
              title: Text(subtitle.title ?? ''),
              subtitle: Text(subtitle.language ?? ''),
              onTap: () {
                controller.setSubtitleTrack(
                  subtitle,
                );
                controller.showSidebar.value = false;
              },
            ),
        const SizedBox(height: 10),
        ListTitle(
          title: 'video.audio'.i18n,
        ),
        const SizedBox(height: 5),
        for (final audio in controller.player.state.tracks.audio)
          if (audio.language != null || audio.title != null)
            ListTile(
              selected: audio == controller.player.state.track.audio,
              title: Text(audio.title ?? ''),
              subtitle: Text(audio.language ?? ''),
              onTap: () {
                controller.player.setAudioTrack(
                  audio,
                );
                controller.showSidebar.value = false;
              },
            ),
      ],
    );
  }
}

class _TorrentFiles extends StatelessWidget {
  const _TorrentFiles({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final file in controller.torrentMediaFileList)
          ListTile(
            selected: controller.currentTorrentFile.value == file,
            title: Text(
              file,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
            onTap: () {
              controller.playTorrentFile(file);
              controller.showSidebar.value = false;
            },
          ),
      ],
    );
  }
}
