import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:get/get.dart';
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
        _c.showPlayList.value = false;
      },
    ),
    "Subtitles": const Text('Subtitles'),
  };

  String _selectedTab = "Episodes";

  Widget _buildAndroid(BuildContext context) {
    return _tabs[_selectedTab]!;
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.FluentTheme(
      data: fluent.FluentThemeData(
        brightness: Brightness.dark,
      ),
      child: Container(
        color: fluent.FluentThemeData.dark().micaBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "Settings",
              style: fluent.FluentThemeData.dark().typography.bodyLarge,
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
    return Obx(() {
      // if (c.torrentMediaFileList.isNotEmpty) {
      //   tabs.add(
      //     const Tab(
      //       text: 'Torrent File',
      //     ),
      //   );
      // }

      // if (c.qualityUrls.isNotEmpty) {
      //   tabs.add(
      //     const Tab(
      //       text: 'Quality',
      //     ),
      //   );
      // }

      _tabs["Settings"] = const Text('Settings');

      return PlatformBuildWidget(
        androidBuilder: _buildAndroid,
        desktopBuilder: _buildDesktop,
      );
    });
  }
}
