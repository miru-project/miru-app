import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/extension_repo/controller.dart';
import 'package:miru_app/pages/main/controller.dart';
import 'package:miru_app/pages/settings/controller.dart';
import 'package:miru_app/pages/settings/widgets/setting_input_tile.dart';
import 'package:miru_app/pages/settings/widgets/setting_switch_tile.dart';
import 'package:miru_app/pages/settings/widgets/setting_tile.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/package_info.dart';
import 'package:miru_app/widgets/platform_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsController c;

  @override
  void initState() {
    c = Get.put(SettingsController());
    super.initState();
  }

  _buildContent() {
    return ListView(
      children: [
        if (!Platform.isAndroid) ...[
          const Text(
            "设置",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
        SettingsIntpuTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.link),
            desktopWidget: Icon(fluent.FluentIcons.repo, size: 24),
          ),
          title: "扩展仓库地址",
          buildSubtitle: () {
            if (!Platform.isAndroid) {
              return "获取扩展的仓库地址";
            }
            return MiruStorage.getSetting(SettingKey.miruRepoUrl);
          },
          onChanged: (value) {
            MiruStorage.setSetting(SettingKey.miruRepoUrl, value);
            Get.find<ExtensionRepoPageController>().onRefresh();
          },
          text: MiruStorage.getSetting(SettingKey.miruRepoUrl),
        ),
        const SizedBox(height: 8),
        SettingsIntpuTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.key),
            desktopWidget:
                Icon(fluent.FluentIcons.key_phrase_extraction, size: 24),
          ),
          title: "TMDB API Key",
          buildSubtitle: () {
            if (!Platform.isAndroid) {
              return "获取TMDB API Key";
            }
            final key = MiruStorage.getSetting(SettingKey.tmdbKay) as String;
            if (key.isEmpty) {
              return "未设置";
            }
            // 替换为*号
            return key.replaceAll(RegExp(r"."), '*');
          },
          onChanged: (value) {
            MiruStorage.setSetting(SettingKey.tmdbKay, value);
          },
          text: MiruStorage.getSetting(SettingKey.tmdbKay),
        ),
        const SizedBox(height: 8),
        SettingTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.update),
            desktopWidget: Icon(fluent.FluentIcons.update_restore, size: 24),
          ),
          title: "更新软件",
          buildSubtitle: () => "当前版本: ${packageInfo.version}",
          trailing: PlatformWidget(
            androidWidget: TextButton(
              onPressed: () {
                Get.find<MainController>().checkUpdate(context);
              },
              child: const Text("检查更新"),
            ),
            desktopWidget: fluent.FilledButton(
              onPressed: () {
                Get.find<MainController>().checkUpdate(context);
              },
              child: const Text("检查更新"),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SettingSwitchTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.autorenew_sharp),
            desktopWidget:
                Icon(fluent.FluentIcons.auto_deploy_settings, size: 24),
          ),
          title: "自动检查更新",
          buildSubtitle: () => "启动时检查更新",
          buildValue: () => MiruStorage.getSetting(SettingKey.autoCheckUpdate),
          onChanged: (value) {
            MiruStorage.setSetting(SettingKey.autoCheckUpdate, value);
          },
        ),
        const SizedBox(height: 8),
        if (!Platform.isAndroid)
          Obx(() {
            final value = c.extensionLogWindowId.value != -1;
            return SettingSwitchTile(
              icon: const Icon(fluent.FluentIcons.bug),
              title: "扩展日志窗口",
              buildSubtitle: () => "用于调试扩展",
              buildValue: () => value,
              onChanged: (value) {
                c.toggleExtensionLogWindow(value);
              },
            );
          }),
      ],
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildContent(),
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
