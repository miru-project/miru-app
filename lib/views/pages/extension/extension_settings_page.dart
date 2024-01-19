import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:get/get.dart';
import 'package:miru_app/models/extension_setting.dart';
import 'package:miru_app/views/pages/code_edit_page.dart';
import 'package:miru_app/controllers/extension/extension_settings_controller.dart';
import 'package:miru_app/views/widgets/extension/info_card.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/layout.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/card_tile.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/progress.dart';
import 'package:miru_app/views/widgets/settings/settings_input_tile.dart';
import 'package:miru_app/views/widgets/settings/settings_radios_tile.dart';
import 'package:miru_app/views/widgets/settings/settings_switch_tile.dart';
import 'package:miru_app/views/widgets/settings/settings_tile.dart';

class ExtensionSettingsPage extends StatefulWidget {
  const ExtensionSettingsPage({
    super.key,
    required this.package,
  });
  final String package;

  @override
  State<ExtensionSettingsPage> createState() => _ExtensionSettingsPageState();
}

class _ExtensionSettingsPageState extends State<ExtensionSettingsPage> {
  late ExtensionSettingsPageController c;

  @override
  void initState() {
    c = Get.put(
      ExtensionSettingsPageController(widget.package),
      tag: widget.package,
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ExtensionSettingsPageController>(tag: widget.package);
    super.dispose();
  }

  List<Widget> settingsContent() {
    final list = <Widget>[];

    for (final setting in c.settings) {
      if (setting.type == ExtensionSettingType.input) {
        list.add(SettingsIntpuTile(
          isCard: true,
          title: setting.title,
          onChanged: (value) async {
            await DatabaseService.putExtensionSetting(
              setting.package,
              setting.key,
              value,
            );
            setting.value = value;
            if (Platform.isAndroid) {
              // 如果是安卓，需要触发一下更新
              setState(() {});
            }
          },
          text: setting.value ?? setting.defaultValue,
          buildSubtitle: () {
            if (Platform.isAndroid) {
              return '${setting.value ?? setting.defaultValue}\n${setting.description ?? ''}';
            }
            return setting.description ?? '';
          },
        ));
      }
      if (setting.type == ExtensionSettingType.radio) {
        final map = Map<String, String>.from(jsonDecode(setting.options!));
        list.add(SettingsRadiosTile(
          isCard: true,
          title: setting.title,
          itemNameValue: () {
            return map;
          }(),
          buildSubtitle: () => setting.description ?? '',
          applyValue: (value) {
            DatabaseService.putExtensionSetting(
              setting.package,
              setting.key,
              value,
            );
            setting.value = value;
            setState(() {});
          },
          buildGroupValue: () => setting.value ?? setting.defaultValue,
        ));
      }
      if (setting.type == ExtensionSettingType.toggle) {
        list.add(SettingsSwitchTile(
          isCard: true,
          title: setting.title,
          onChanged: (value) {
            DatabaseService.putExtensionSetting(
              setting.package,
              setting.key,
              value.toString(),
            );
            setting.value = value.toString();
          },
          buildSubtitle: () => setting.description ?? '',
          buildValue: () {
            return (setting.value ?? setting.defaultValue).toLowerCase() ==
                'true';
          },
        ));
      }
      list.add(const SizedBox(height: 8));
    }
    return list;
  }

  Widget _buildAndroid(BuildContext context) {
    return Obx(() {
      if (c.runtime.value == null) {
        return const Center(
          child: ProgressRing(),
        );
      }
      final extension = c.runtime.value!.extension;

      final content = SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: CacheNetWorkImagePic(
                  extension.icon ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              extension.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              extension.package,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                children: [
                  InfoCard(
                    icon: Icons.person,
                    title: 'extension-info.author'.i18n,
                    content: extension.author,
                  ),
                  InfoCard(
                    icon: Icons.info,
                    title: 'extension-info.version'.i18n,
                    content: extension.version,
                  ),
                  InfoCard(
                    icon: Icons.language,
                    title: 'extension-info.language'.i18n,
                    content: extension.lang,
                  ),
                  InfoCard(
                    icon: Icons.description,
                    title: 'extension-info.license'.i18n,
                    content: extension.license,
                  ),
                  InfoCard(
                    icon: Icons.link,
                    title: 'extension-info.original-site'.i18n,
                    content: extension.webSite,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await ExtensionUtils.uninstall(extension.package);
                        Get.back();
                      },
                      child: Text('common.uninstall'.i18n),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Get.to(CodeEditPage(extension: extension));
                      },
                      child: Text('extension.edit-code'.i18n),
                    ),
                  )
                ],
              ),
            ),
            if (!LayoutUtils.isTablet) ...[
              const Divider(),
              SettingsTile(
                isCard: true,
                title: 'cookie-clean.title'.i18n,
                buildSubtitle: () => 'cookie-clean.subtitle'.i18n,
                trailing: TextButton(
                  child: Text('cookie-clean.clean'.i18n),
                  onPressed: () {
                    c.runtime.value!.cleanCookie();
                    showPlatformSnackbar(
                      context: context,
                      content: 'cookie-clean.success'.i18n,
                    );
                  },
                ),
              ),
              ...settingsContent(),
            ]
          ],
        ),
      );

      return Scaffold(
        appBar: AppBar(
          title: Text('extension-info.title'.i18n),
        ),
        body: LayoutUtils.isTablet
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SettingsTile(
                            isCard: true,
                            title: 'cookie-clean.title'.i18n,
                            buildSubtitle: () => 'cookie-clean.subtitle'.i18n,
                            trailing: TextButton(
                              child: Text('cookie-clean.clean'.i18n),
                              onPressed: () {
                                c.runtime.value!.cleanCookie();
                                showPlatformSnackbar(
                                  context: context,
                                  content: 'cookie-clean.success'.i18n,
                                );
                              },
                            ),
                          ),
                          ...settingsContent(),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : content,
      );
    });
  }

  Widget _buildDesktop(BuildContext context) {
    return Obx(() {
      if (c.runtime.value == null) {
        return const Center(
          child: ProgressRing(),
        );
      }

      final extension = c.runtime.value!.extension;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: ((context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (constraints.maxWidth > 800)
                SizedBox(
                  width: 320,
                  child: fluent.Card(
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CacheNetWorkImagePic(
                            extension.icon ?? '',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          extension.name,
                          style: fluent.FluentTheme.of(context)
                              .typography
                              .bodyLarge,
                        ),
                        Text(
                          extension.package,
                          style: fluent.FluentTheme.of(context).typography.body,
                        ),
                        const SizedBox(height: 16),
                        fluent.FilledButton(
                          onPressed: () async {
                            await ExtensionUtils.uninstall(extension.package);
                            router.pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 2),
                            child: Text('common.uninstall'.i18n),
                          ),
                        ),
                        const SizedBox(height: 50),
                        fluent.Card(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          child: Text(
                            ExtensionUtils.typeToString(extension.type),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 16),
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (extension.description != null) ...[
                          CardTile(
                            title: 'extension-info.description'.i18n,
                            child: SelectableText(
                              extension.description!,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        CardTile(
                          title: 'extension-info.other-infomation'.i18n,
                          child: Wrap(
                            children: [
                              InfoCard(
                                icon: fluent.FluentIcons.contact,
                                title: 'extension-info.author'.i18n,
                                content: extension.author,
                              ),
                              InfoCard(
                                icon: fluent.FluentIcons.code,
                                title: 'extension-info.version'.i18n,
                                content: extension.version,
                              ),
                              InfoCard(
                                icon: fluent.FluentIcons.locale_language,
                                title: 'extension-info.language'.i18n,
                                content: extension.lang,
                              ),
                              InfoCard(
                                icon: fluent.FluentIcons.page,
                                title: 'extension-info.license'.i18n,
                                content: extension.license,
                              ),
                              InfoCard(
                                icon: fluent.FluentIcons.globe,
                                title: 'extension-info.original-site'.i18n,
                                content: extension.webSite,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'common.settings'.i18n,
                          style: fluent.FluentTheme.of(context)
                              .typography
                              .subtitle,
                        ),
                        const SizedBox(height: 16),
                        SettingsTile(
                          isCard: true,
                          title: 'cookie-clean.title'.i18n,
                          buildSubtitle: () => 'cookie-clean.subtitle'.i18n,
                          trailing: fluent.FilledButton(
                            child: Text('cookie-clean.clean'.i18n),
                            onPressed: () {
                              c.runtime.value!.cleanCookie();
                              showPlatformSnackbar(
                                context: context,
                                content: 'cookie-clean.success'.i18n,
                                severity: fluent.InfoBarSeverity.success,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...settingsContent(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        })),
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
