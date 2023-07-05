import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/main.dart';
import 'package:miru_app/pages/extension/controller.dart';
import 'package:miru_app/pages/extension/widgets/extension_tile.dart';
import 'package:miru_app/pages/extension_repo/view.dart';
import 'package:miru_app/utils/extension.dart';
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
    fluent.showDialog(
      context: context,
      builder: (context) => fluent.ContentDialog(
        title: const Text("导入扩展"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fluent.TextBox(
              placeholder: "扩展地址",
              onChanged: (value) {
                url = value;
              },
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(fluent.FluentIcons.error),
                SizedBox(width: 8),
                Text(
                  "你可以通过链接导入扩展，\n或者点击下方的扩展目录，将扩展文件\n放入其中。",
                  softWrap: true,
                )
              ],
            ),
          ],
        ),
        actions: [
          fluent.Button(
            onPressed: () {
              router.pop();
            },
            child: const Text("取消"),
          ),
          fluent.FilledButton(
            onPressed: () async {
              router.pop();
              // 定位目录
              final dir = await ExtensionUtils.getExtensionsDir;
              final uri = Uri.directory(dir);
              await launchUrl(uri);
            },
            child: const Text("扩展目录"),
          ),
          fluent.FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ExtensionUtils.install(url, context);
            },
            child: const Text("通过链接导入"),
          ),
        ],
      ),
    );
  }

  // 加载错误对话框
  _loadErrorDialog() {
    fluent.showDialog(
      context: context,
      builder: (context) => fluent.ContentDialog(
        title: const Text("错误信息"),
        content: ListView(
          shrinkWrap: true,
          children: [
            // 输出key 和 value
            for (final e in c.errors.entries)
              fluent.Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "${e.key}: ${e.value}",
                ),
              ),
          ],
        ),
        actions: [
          fluent.Button(
            onPressed: () {
              router.pop();
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Obx(() {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("扩展"),
            bottom: const TabBar(tabs: [
              Tab(text: "已安装"),
              Tab(text: "仓库"),
            ]),
          ),
          body: TabBarView(children: [
            ListView(
              children: [
                if (c.extensions.isEmpty)
                  const SizedBox(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("未安装任何扩展"),
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
                const Text(
                  "扩展",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    const Text("未安装任何扩展"),
                    const SizedBox(height: 8),
                    FilledButton(
                      child: const Text("扩展仓库"),
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
