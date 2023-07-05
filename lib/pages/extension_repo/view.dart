import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/extension_repo/controller.dart';
import 'package:miru_app/pages/extension_repo/widgets/extension_card.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';

class ExtensionRepoPage extends StatefulWidget {
  const ExtensionRepoPage({Key? key}) : super(key: key);

  @override
  State<ExtensionRepoPage> createState() => _ExtensionRepoPageState();
}

class _ExtensionRepoPageState extends State<ExtensionRepoPage> {
  late ExtensionRepoPageController c;

  @override
  void initState() {
    c = Get.put(ExtensionRepoPageController());
    super.initState();
  }

  _content() {
    if (c.isLoading.value) {
      return const Center(child: ProgressRing());
    }
    if (c.isError.value) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("发生错误了!"),
          const Text(
            "请检查仓库地址是否设置正确,或者网络是否能正常联通",
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          FilledButton(
              child: const Text("重试"),
              onPressed: () {
                c.onRefresh();
              })
        ],
      ));
    }
    if (c.extensions.isEmpty) {
      return const Center(child: Text("仓库为空"));
    }
    return PlatformBuildWidget(
      androidBuilder: (context) => ListView(
        children: c.extensions
            .map((e) => ExtensionCard(
                  key: ValueKey(e['package']),
                  name: e['name'],
                  icon: e['icon'] ?? 'https://github.com/miru-project.png',
                  version: e['version'],
                  package: e['package'],
                ))
            .toList(),
      ),
      desktopBuilder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            crossAxisCount: constraints.maxWidth ~/ 220,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: c.extensions
                .map((e) => ExtensionCard(
                      key: ValueKey(e['package']),
                      name: e['name'],
                      icon: e['icon'] ?? 'https://github.com/miru-project.png',
                      version: e['version'],
                      package: e['package'],
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Obx(() => _content());
  }

  Widget _buildDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Obx(() => Column(
            children: [
              Row(
                children: [
                  const Text(
                    "仓库",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 200,
                    child: fluent.TextBox(
                      controller: TextEditingController(text: c.search.value),
                      placeholder: "搜索",
                      onChanged: (value) {
                        if (value.isEmpty) {
                          c.onRefresh();
                          c.search.value = '';
                        }
                      },
                      onSubmitted: (value) {
                        c.search.value = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  fluent.IconButton(
                      icon: const Icon(fluent.FluentIcons.refresh),
                      onPressed: () {
                        c.onRefresh();
                      })
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _content()),
            ],
          )),
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
