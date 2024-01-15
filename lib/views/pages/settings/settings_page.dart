import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/providers/tmdb_provider.dart';
import 'package:miru_app/controllers/application_controller.dart';
import 'package:miru_app/views/dialogs/bt_dialog.dart';
import 'package:miru_app/controllers/extension/extension_repo_controller.dart';
import 'package:miru_app/controllers/settings_controller.dart';
import 'package:miru_app/views/widgets/settings/settings_expander_tile.dart';
import 'package:miru_app/views/widgets/settings/settings_input_tile.dart';
import 'package:miru_app/views/widgets/settings/settings_radios_tile.dart';
import 'package:miru_app/views/widgets/settings/settings_switch_tile.dart';
import 'package:miru_app/views/widgets/settings/settings_numberbox_button.dart';
import 'package:miru_app/views/widgets/settings/settings_tile.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/application.dart';
import 'package:miru_app/views/widgets/list_title.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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

  List<Widget> _buildContent() {
    return [
      if (!Platform.isAndroid) ...[
        Text(
          'common.settings'.i18n,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
      ],
      // 常规设置
      SettingsExpanderTile(
        icon: fluent.FluentIcons.developer_tools,
        androidIcon: Icons.construction,
        title: 'settings.general'.i18n,
        subTitle: 'settings.general-subtitle'.i18n,
        content: Column(
          children: [
            // TMDB KEY 设置
            SettingsIntpuTile(
              title: 'settings.tmdb-key'.i18n,
              buildSubtitle: () {
                if (!Platform.isAndroid) {
                  return 'settings.tmdb-key-subtitle'.i18n;
                }
                final key =
                    MiruStorage.getSetting(SettingKey.tmdbKay) as String;
                if (key.isEmpty) {
                  return 'common.unset'.i18n;
                }
                // 替换为*号
                return key.replaceAll(RegExp(r"."), '*');
              },
              onChanged: (value) {
                MiruStorage.setSetting(SettingKey.tmdbKay, value);
                TmdbApi.tmdb = TMDB(
                  ApiKeys(value, ''),
                  defaultLanguage: MiruStorage.getSetting(SettingKey.language),
                );
              },
              text: MiruStorage.getSetting(SettingKey.tmdbKay),
            ),
            // 语言设置
            SettingsRadiosTile(
              title: 'settings.language'.i18n,
              itemNameValue: {
                'languages.en'.i18n: 'en',
                'languages.zh'.i18n: 'zh',
                'languages.be'.i18n: 'be',
                'languages.es'.i18n: 'es',
                'languages.fr'.i18n: 'fr',
                'languages.ja'.i18n: 'ja',
                'languages.ryu'.i18n: 'ryu',
                'languages.ru'.i18n: 'ru',
                'languages.uk'.i18n: 'uk',
                'languages.hi'.i18n: 'hi',
                'languages.zhHant'.i18n: 'zhHant',
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
            // 主题设置
            SettingsRadiosTile(
              title: 'settings.theme'.i18n,
              itemNameValue: () {
                final map = {
                  'settings.theme-system'.i18n: 'system',
                  'settings.theme-light'.i18n: 'light',
                  'settings.theme-dark'.i18n: 'dark',
                };
                if (Platform.isAndroid) {
                  map['settings.theme-black'.i18n] = 'black';
                }
                return map;
              }(),
              buildSubtitle: () => 'settings.theme-subtitle'.i18n,
              applyValue: (value) {
                Get.find<ApplicationController>().changeTheme(value);
              },
              buildGroupValue: () {
                return Get.find<ApplicationController>().themeText.value;
              },
            ),
            // 启动检查更新
            SettingsSwitchTile(
              title: 'settings.auto-check-update'.i18n,
              buildSubtitle: () => 'settings.auto-check-update-subtitle'.i18n,
              buildValue: () =>
                  MiruStorage.getSetting(SettingKey.autoCheckUpdate),
              onChanged: (value) {
                MiruStorage.setSetting(SettingKey.autoCheckUpdate, value);
              },
            ),
            // NSFW
            SettingsSwitchTile(
              title: 'settings.nsfw'.i18n,
              buildSubtitle: () => "settings.nsfw-subtitle".i18n,
              buildValue: () {
                return MiruStorage.getSetting(SettingKey.enableNSFW);
              },
              onChanged: (value) {
                MiruStorage.setSetting(SettingKey.enableNSFW, value);
              },
            ),
            // UA
            SettingsIntpuTile(
              title: 'settings.webview-ua'.i18n,
              buildSubtitle: () {
                if (!Platform.isAndroid) {
                  return 'settings.webview-ua-subtitle'.i18n;
                }
                return MiruStorage.getUASetting();
              },
              onChanged: (value) {
                MiruStorage.setUASetting(value);
              },
              text: MiruStorage.getUASetting(),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      // 扩展仓库
      SettingsExpanderTile(
        icon: fluent.FluentIcons.repo,
        androidIcon: Icons.extension,
        title: 'settings.extension'.i18n,
        subTitle: 'settings.extension-subtitle'.i18n,
        content: Column(
          children: [
            SettingsIntpuTile(
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
          ],
        ),
      ),
      const SizedBox(height: 10),
      // 视频播放器
      SettingsExpanderTile(
        icon: fluent.FluentIcons.play,
        androidIcon: Icons.play_arrow,
        title: 'settings.video-player'.i18n,
        subTitle: 'settings.video-player-subtitle'.i18n,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTile(
              title: 'settings.bt-server'.i18n,
              buildSubtitle: () => "settings.bt-server-subtitle".i18n,
              trailing: PlatformWidget(
                androidWidget: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const BTDialog(),
                    );
                  },
                  child: Text('settings.bt-server-manager'.i18n),
                ),
                desktopWidget: fluent.FilledButton(
                  onPressed: () {
                    fluent.showDialog(
                      context: context,
                      builder: (context) => const BTDialog(),
                    );
                  },
                  child: Text('settings.bt-server-manager'.i18n),
                ),
              ),
            ),
            SettingsRadiosTile(
              title: 'settings.external-player'.i18n,
              itemNameValue: () {
                if (Platform.isAndroid) {
                  return {
                    "settings.external-player-builtin".i18n: "built-in",
                    "VLC": "vlc",
                    "Other": "other",
                  };
                }
                return {
                  "settings.external-player-builtin".i18n: "built-in",
                  "VLC": "vlc",
                  "PotPlayer": "potplayer",
                };
              }(),
              buildSubtitle: () => FlutterI18n.translate(
                context,
                'settings.external-player-subtitle',
                translationParams: {
                  'player': MiruStorage.getSetting(SettingKey.videoPlayer),
                },
              ),
              applyValue: (value) {
                MiruStorage.setSetting(SettingKey.videoPlayer, value);
              },
              buildGroupValue: () {
                return MiruStorage.getSetting(SettingKey.videoPlayer);
              },
            ),
            const SizedBox(height: 10),
            if (!Platform.isAndroid) ...[
              Text("settings.skip-interval".i18n),
              const SizedBox(height: 2),
              Text(
                "settings.skip-interval-subtitle".i18n,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 15),
              Column(
                children: [
                  Row(children: [
                    Expanded(
                        child: SettingNumboxButton(
                      title: "key I",
                      button1text: "1s",
                      button2text: "0.1s",
                      onChanged: (value) {
                        MiruStorage.setSetting(
                            SettingKey.keyI, value ??= -10.0);
                      },
                      numberBoxvalue:
                          MiruStorage.getSetting(SettingKey.keyI) ?? -10.0,
                    )),
                    const SizedBox(width: 30),
                    Expanded(
                        child: SettingNumboxButton(
                      title: "key J",
                      button1text: "1s",
                      button2text: "0.1s",
                      onChanged: (value) {
                        MiruStorage.setSetting(SettingKey.keyJ, value ??= 10.0);
                      },
                      numberBoxvalue:
                          MiruStorage.getSetting(SettingKey.keyJ) ?? 10.0,
                    ))
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: SettingNumboxButton(
                        title: "arrow left",
                        icon: const Icon(fluent.FluentIcons.chevron_left_med),
                        button1text: "1s",
                        button2text: "0.1s",
                        numberBoxvalue:
                            MiruStorage.getSetting(SettingKey.arrowLeft) ??
                                10.0,
                        onChanged: (value) {
                          MiruStorage.setSetting(
                              SettingKey.arrowLeft, value ??= -2.0);
                        },
                      )),
                      const SizedBox(width: 30),
                      Expanded(
                          child: SettingNumboxButton(
                        title: "arrow right",
                        icon: const Icon(fluent.FluentIcons.chevron_right_med),
                        button1text: "1s",
                        button2text: "0.1s",
                        onChanged: (value) {
                          MiruStorage.setSetting(
                              SettingKey.arrowRight, value ??= 2);
                        },
                        numberBoxvalue:
                            MiruStorage.getSetting(SettingKey.arrowRight) ??
                                10.0,
                      ))
                    ],
                  )
                ],
              ),
            ]
          ],
        ),
      ),
      const SizedBox(height: 10),
      // 漫画阅读器设置
      SettingsExpanderTile(
        icon: fluent.FluentIcons.reading_mode,
        androidIcon: Icons.image,
        title: 'settings.comic-reader'.i18n,
        subTitle: 'settings.comic-reader-subtitle'.i18n,
        content: Column(
          children: [
            SettingsRadiosTile(
              title: 'settings.default-reader-mode'.i18n,
              itemNameValue: () {
                final map = {
                  'comic-settings.standard'.i18n: 'standard',
                  'comic-settings.right-to-left'.i18n: 'rightToLeft',
                  'comic-settings.web-tonn'.i18n: 'webTonn',
                };
                return map;
              }(),
              buildSubtitle: () =>
                  '${MiruStorage.getSetting(SettingKey.readingMode)}'.i18n,
              applyValue: (value) {
                MiruStorage.setSetting(SettingKey.readingMode, value);
              },
              buildGroupValue: () {
                return MiruStorage.getSetting(SettingKey.readingMode);
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      // 同步数据
      SettingsExpanderTile(
        icon: fluent.FluentIcons.sync,
        androidIcon: Icons.sync,
        content: const SizedBox.shrink(),
        title: 'settings.tracking'.i18n,
        subTitle: 'settings.tracking-subtitle'.i18n,
      ),
      const SizedBox(height: 10),
      // Debug
      if (!Platform.isAndroid)
        Obx(
          () {
            final value = c.extensionLogWindowId.value != -1;
            return SettingsSwitchTile(
              icon: const Icon(
                fluent.FluentIcons.bug,
                size: 24,
              ),
              title: 'settings.extension-log'.i18n,
              buildSubtitle: () => 'settings.extension-log-subtitle'.i18n,
              buildValue: () => value,
              onChanged: (value) {
                c.toggleExtensionLogWindow(value);
              },
              isCard: true,
            );
          },
        ),
      // 关于
      const SizedBox(height: 20),
      ListTitle(title: 'settings.about'.i18n),
      const SizedBox(height: 20),
      SettingsTile(
        isCard: true,
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
              ApplicationUtils.checkUpdate(
                context,
                showSnackbar: true,
              );
            },
            child: Text('settings.upgrade-training'.i18n),
          ),
          desktopWidget: fluent.FilledButton(
            onPressed: () {
              ApplicationUtils.checkUpdate(
                context,
                showSnackbar: true,
              );
            },
            child: Text('settings.upgrade-training'.i18n),
          ),
        ),
      ),
      const SizedBox(height: 10),
      SettingsExpanderTile(
        leading: const Image(
          image: AssetImage('assets/icon/logo.png'),
          width: 24,
          height: 24,
        ),
        title: "Miru",
        subTitle: "AGPL-3.0 License",
        open: true,
        noPage: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SelectableText(
              "🎉 A versatile application that is free, open-source, and supports extension sources for videos, comics, and novels, available on Android, Windows, and Web platforms.",
            ),
            const SizedBox(height: 20),
            Text(
              'settings.links'.i18n,
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                for (final link in c.links.entries)
                  fluent.Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          await launchUrl(
                            Uri.parse(link.value),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(
                          link.key,
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'settings.contributors'.i18n,
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                children: [
                  if (c.contributors.isNotEmpty)
                    for (final contributor in c.contributors)
                      fluent.Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              await launchUrl(
                                Uri.parse(contributor['html_url']),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Text(
                              contributor['login'],
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      )
                ],
              ),
            ),
          ],
        ),
      )
    ];
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('common.settings'.i18n),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: _buildContent(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: (context) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        children: _buildContent(),
      ),
    );
  }
}
