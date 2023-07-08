import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:miru_app/main.dart';
import 'package:miru_app/pages/extension/controller.dart';
import 'package:miru_app/pages/extension/widgets/extension_tile.dart';
import 'package:miru_app/pages/extension_repo/view.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/widgets/button.dart';
import 'package:miru_app/widgets/messenger.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ExtensionPage extends StatefulWidget {
  const ExtensionPage({Key? key}) : super(key: key);

  @override
  State<ExtensionPage> createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> {
  late ExtensionPageController c;

  @override
  void initState() {
    c = Get.put(ExtensionPageController());
    super.initState();
  }

  // 导入扩展对话框
  _importDialog() {
    String url = '';
    showPlatformDialog(
      context: context,
      title: 'extension.import.title'.i18n,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlatformWidget(
            androidWidget: TextField(
              decoration: InputDecoration(
                labelText: 'extension.import.url-label'.i18n,
                hintText: "https://example.com/extension.js",
              ),
              onChanged: (value) {
                url = value;
              },
            ),
            desktopWidget: fluent.TextBox(
              placeholder: 'extension.import.url-label'.i18n,
              onChanged: (value) {
                url = value;
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(fluent.FluentIcons.error),
              const SizedBox(width: 8),
              Text(
                "extension.import.tips".i18n,
                softWrap: true,
              )
            ],
          ),
        ],
      ),
      actions: [
        PlatformButton(
          onPressed: () {
            RouterUtils.pop();
          },
          child: Text('common.cancel'.i18n),
        ),
        PlatformFilledButton(
          onPressed: () async {
            RouterUtils.pop();
            // 定位目录
            final dir = await ExtensionUtils.getExtensionsDir;
            if (Platform.isAndroid) {
              // 复制 dir
              Clipboard.setData(ClipboardData(text: dir));
              // ignore: use_build_context_synchronously
              showPlatformSnackbar(
                context: context,
                title: 'extension.import.extension-dir'.i18n,
                content: 'common.copied'.i18n,
              );
              return;
            }
            final uri = Uri.directory(dir);
            await launchUrl(uri);
          },
          child: Text('extension.import.extension-dir'.i18n),
        ),
        PlatformFilledButton(
          onPressed: () async {
            RouterUtils.pop();
            await ExtensionUtils.install(url, context);
          },
          child: Text('extension.import.import-by-url'.i18n),
        ),
      ],
    );
  }

  // 加载错误对话框
  _loadErrorDialog() {
    showPlatformDialog(
      context: context,
      title: 'extension.error-dialog'.i18n,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 输出key 和 value
            for (final e in c.errors.entries)
              PlatformWidget(
                androidWidget: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "${e.key}: ${e.value}",
                    ),
                  ),
                ),
                desktopWidget: fluent.Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "${e.key}: ${e.value}",
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        PlatformButton(
          onPressed: () {
            RouterUtils.pop();
          },
          child: Text('common.confirm'.i18n),
        ),
      ],
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Obx(() {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('common.extension'.i18n),
            bottom: TabBar(
              tabs: [
                Tab(text: 'extension.installed'.i18n),
                Tab(text: 'common.repo'.i18n),
              ],
            ),
            actions: [
              if (c.errors.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.error),
                  onPressed: () {
                    _loadErrorDialog();
                  },
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _importDialog();
            },
            child: const Icon(Icons.add),
          ),
          body: TabBarView(children: [
            ListView(
              children: [
                if (c.extensions.isEmpty)
                  SizedBox(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('common.no-extension'.i18n),
                      ],
                    ),
                  ),
                for (final ext in c.extensions.values)
                  ExtensionTile(ext.extension),
              ],
            ),
            const ExtensionRepoPage()
          ]),
        ),
      );
    });
  }

  Widget _buildDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Column(
          children: [
            Row(
              children: [
                Text(
                  'common.extension'.i18n,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // 错误按钮
                if (c.errors.isNotEmpty)
                  fluent.IconButton(
                    icon: const Icon(fluent.FluentIcons.error),
                    onPressed: () {
                      _loadErrorDialog();
                    },
                  ),
                // 导入按钮
                fluent.IconButton(
                  icon: const Icon(fluent.FluentIcons.add_space_before),
                  onPressed: () {
                    _importDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (c.extensions.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('common.no-extension'.i18n),
                    const SizedBox(height: 8),
                    fluent.FilledButton(
                      child: Text(
                        'common.extension-repo'.i18n,
                      ),
                      onPressed: () {
                        router.push('/extension_repo');
                      },
                    )
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final ext in c.extensions.values)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExtensionTile(ext.extension),
                    ),
                ],
              ),
            )
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
