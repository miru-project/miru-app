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
import 'package:miru_app/views/widgets/settings_input_tile.dart';
import 'package:miru_app/views/widgets/settings_radios_tile.dart';
import 'package:miru_app/views/widgets/settings_switch_tile.dart';
import 'package:miru_app/views/widgets/settings_numberbox_button.dart';
import 'package:miru_app/views/widgets/settings_tile.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/application.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/list_title.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:tmdb_api/tmdb_api.dart';
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
            TmdbApi.tmdb = TMDB(
              ApiKeys(value, ''),
              defaultLanguage: MiruStorage.getSetting(SettingKey.language),
            );
          },
          text: MiruStorage.getSetting(SettingKey.tmdbKay),
        ),
        const SizedBox(height: 8),
        SettingsTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.wifi_tethering),
            desktopWidget: Icon(
              fluent.FluentIcons.communications,
              size: 24,
            ),
          ),
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
        const SizedBox(height: 8),
        SettingsTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.backup),
            desktopWidget: Icon(fluent.FluentIcons.update_restore, size: 24),
          ),
          title: 'settings.backup'.i18n,
          buildSubtitle: () => FlutterI18n.translate(
            context,
            'settings.backup-subtitle',
            translationParams: {
              'version': packageInfo.version,
            },
          ),
          trailing: PlatformWidget(
            androidWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    ApplicationUtils.exportSaveFile(context);
                  },
                  child: Text('settings.export-file'.i18n),
                ),
                TextButton(
                  onPressed: () {
                    ApplicationUtils.importSaveFile(context);
                  },
                  child: Text('settings.import-file'.i18n),
                )
              ],
            ),
            desktopWidget: Row(children: [
              fluent.FilledButton(
                onPressed: () {
                  ApplicationUtils.exportSaveFile(
                    context,
                  );
                },
                child: Text('settings.export-file'.i18n),
              ),
              const SizedBox(width: 16),
              fluent.Button(
                onPressed: () {
                  ApplicationUtils.importSaveFile(
                    context,
                  );
                },
                child: Text('settings.import-file'.i18n),
              )
            ]),
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
            'languages.be'.i18n: 'be',
            'languages.es'.i18n: 'es',
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
        const SizedBox(height: 8),
        SettingsSwitchTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.warning_amber_rounded),
            desktopWidget: Icon(fluent.FluentIcons.warning, size: 24),
          ),
          title: 'settings.nsfw'.i18n,
          buildSubtitle: () => "settings.nsfw-subtitle".i18n,
          buildValue: () {
            return MiruStorage.getSetting(SettingKey.enableNSFW);
          },
          onChanged: (value) {
            MiruStorage.setSetting(SettingKey.enableNSFW, value);
          },
        ),
        const SizedBox(height: 8),
        SettingsRadiosTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.color_lens),
            desktopWidget: Icon(fluent.FluentIcons.color, size: 24),
          ),
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
        const SizedBox(height: 8),
        SettingsRadiosTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.chrome_reader_mode),
            desktopWidget:
                Icon(fluent.FluentIcons.reading_mode_solid, size: 24),
          ),
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
        const SizedBox(height: 8),
        SettingsRadiosTile(
          icon: const PlatformWidget(
            androidWidget: Icon(Icons.play_arrow),
            desktopWidget: Icon(fluent.FluentIcons.play_resume, size: 24),
          ),
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
        if (!Platform.isAndroid)
          fluent.Expander(
            header: Row(
              children: [
                const Icon(fluent.FluentIcons.keyboard_classic, size: 24),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("settings.skip-interval".i18n),
                    const SizedBox(height: 2),
                    Text(
                      "settings.skip-interval-subtitle".i18n,
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ),
                const Spacer(),
                const SizedBox(),
              ],
            ),
            content: Column(
              children: [
                Row(children: [
                  Expanded(
                      child: SettingNumboxButton(
                    title: "key I",
                    button1text: "1s",
                    button2text: "0.1s",
                    onChanged: (value) {
                      MiruStorage.setSetting(SettingKey.keyI, value ??= -10.0);
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
                Row(children: [
                  Expanded(
                      child: SettingNumboxButton(
                    title: "arrow left",
                    icon: const Icon(fluent.FluentIcons.chevron_left_med),
                    button1text: "1s",
                    button2text: "0.1s",
                    numberBoxvalue:
                        MiruStorage.getSetting(SettingKey.arrowLeft) ?? 10.0,
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
                        MiruStorage.getSetting(SettingKey.arrowRight) ?? 10.0,
                  ))
                ])
              ],
            ),
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
