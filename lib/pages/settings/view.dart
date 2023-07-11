import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/extension_repo/controller.dart';
import 'package:miru_app/pages/main/controller.dart';
import 'package:miru_app/pages/settings/controller.dart';
import 'package:miru_app/widgets/settings_input_tile.dart';
import 'package:miru_app/widgets/settings_radios_tile.dart';
import 'package:miru_app/widgets/settings_switch_tile.dart';
import 'package:miru_app/widgets/settings_tile.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/package_info.dart';
import 'package:miru_app/widgets/button.dart';
import 'package:miru_app/widgets/list_title.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
          Text(
            'common.settings'.i18n,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
        SettingsIntpuTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.link),
            desktopWidget: Icon(fluent.FluentIcons.repo, size: 24),
          ),
          title: 'settings.repo-url'.i18n,
          buildSubtitle: () {
            if (!Platform.isAndroid) {
              return 'settings.repo-url-subtitle'.i18n;
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
          title: 'settings.tmdb-key'.i18n,
          buildSubtitle: () {
            if (!Platform.isAndroid) {
              return 'settings.tmdb-key-subtitle'.i18n;
            }
            final key = MiruStorage.getSetting(SettingKey.tmdbKay) as String;
            if (key.isEmpty) {
              return 'common.unset'.i18n;
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
        SettingsTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.update),
            desktopWidget: Icon(fluent.FluentIcons.update_restore, size: 24),
          ),
          title: 'settings.upgrade'.i18n,
          buildSubtitle: () => FlutterI18n.translate(
            context,
            'settings.upgrade-subtitle',
            translationParams: {
              'version': packageInfo.version,
            },
          ),
          trailing: PlatformWidget(
            androidWidget: TextButton(
              onPressed: () {
                Get.find<MainController>().checkUpdate(
                  context,
                  showSnackbar: true,
                );
              },
              child: Text('settings.upgrade-training'.i18n),
            ),
            desktopWidget: fluent.FilledButton(
              onPressed: () {
                Get.find<MainController>().checkUpdate(
                  context,
                  showSnackbar: true,
                );
              },
              child: Text('settings.upgrade-training'.i18n),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SettingsSwitchTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.autorenew_sharp),
            desktopWidget:
                Icon(fluent.FluentIcons.auto_deploy_settings, size: 24),
          ),
          title: 'settings.auto-check-update'.i18n,
          buildSubtitle: () => 'settings.auto-check-update-subtitle'.i18n,
          buildValue: () => MiruStorage.getSetting(SettingKey.autoCheckUpdate),
          onChanged: (value) {
            MiruStorage.setSetting(SettingKey.autoCheckUpdate, value);
          },
        ),
        const SizedBox(height: 8),
        SettingsRadiosTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.language),
            desktopWidget: Icon(fluent.FluentIcons.locale_language, size: 24),
          ),
          title: 'settings.language'.i18n,
          itemNameValue: {
            'languages.en'.i18n: 'en',
            'languages.zh'.i18n: 'zh',
          },
          buildSubtitle: () => 'settings.language-subtitle'.i18n,
          applyValue: (value) {
            MiruStorage.setSetting(SettingKey.language, value);
            I18nUtils.changeLanguage(value);
          },
          buildGroupValue: () {
            return MiruStorage.getSetting(SettingKey.language);
          },
        ),
        const SizedBox(height: 8),
        if (!Platform.isAndroid)
          Obx(
            () {
              final value = c.extensionLogWindowId.value != -1;
              return SettingsSwitchTile(
                icon: const Icon(fluent.FluentIcons.bug),
                title: 'settings.extension-log'.i18n,
                buildSubtitle: () => 'settings.extension-log-subtitle'.i18n,
                buildValue: () => value,
                onChanged: (value) {
                  c.toggleExtensionLogWindow(value);
                },
              );
            },
          ),
        const SizedBox(height: 8),
        ListTitle(title: 'settings.about'.i18n),
        const SizedBox(height: 8),
        SettingsTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.web),
            desktopWidget: Icon(fluent.FluentIcons.live_site, size: 24),
          ),
          title: 'settings.official-site'.i18n,
          buildSubtitle: () => 'https://miru.js.org',
          trailing: PlatformTextButton(
            child: Text('settings.official-site-training'.i18n),
            onPressed: () {
              launchUrl(
                Uri.parse('https://miru.js.org'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SettingsTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.code),
            desktopWidget: Icon(fluent.FluentIcons.code, size: 24),
          ),
          title: 'settings.source-code'.i18n,
          buildSubtitle: () => 'miru-project/miru-app',
          trailing: PlatformTextButton(
            child: Text('settings.source-code-training'.i18n),
            onPressed: () {
              launchUrl(
                Uri.parse('https://github.com/miru-project/miru-app'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ),
        if (Platform.isAndroid) ...[
          const SizedBox(height: 8),
          SettingsTile(
            icon: const Icon(Icons.library_books),
            title: 'settings.license'.i18n,
            buildSubtitle: () => 'settings.license-subtitle'.i18n,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.to(LicensePage(
                applicationIcon: const ImageIcon(
                  AssetImage('assets/icon/logo.png'),
                  size: 120,
                ),
                applicationName: "Miru",
                applicationVersion: packageInfo.version,
                applicationLegalese: "AGPLv3 © 2023 MiruProject.",
              ));
            },
          )
        ]
      ],
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('common.settings'.i18n),
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
