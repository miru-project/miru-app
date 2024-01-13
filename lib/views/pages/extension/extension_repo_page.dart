import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/controllers/extension/extension_repo_controller.dart';
import 'package:miru_app/views/widgets/extension/extension_card.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/progress.dart';

class ExtensionRepoPage extends StatefulWidget {
  const ExtensionRepoPage({super.key});

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
          Text('extension-repo.error'.i18n),
          const SizedBox(height: 8),
          fluent.Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'extension-repo.error-tips'.i18n,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 13),
          PlatformFilledButton(
            child: Text('common.retry'.i18n),
            onPressed: () {
              c.onRefresh();
            },
          )
        ],
      ));
    }

    final extensionCards = c.extensions
        .map((e) => ExtensionCard(
            key: ValueKey(e['package']),
            name: e['name'],
            icon: e['icon'],
            version: e['version'],
            package: e['package'],
            lang: e['lang'],
            nsfw: e['nsfw'] == 'true',
            type: ExtensionType.values.firstWhere(
              (element) => element.toString() == 'ExtensionType.${e['type']}',
            )))
        .toList();

    return PlatformBuildWidget(
      androidBuilder: (context) => ListView(
        children: extensionCards,
      ),
      desktopBuilder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            crossAxisCount: constraints.maxWidth ~/ 220,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: extensionCards,
          );
        },
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Obx(
      () => EasyRefresh(
        onRefresh: c.onRefresh,
        header: const ClassicHeader(
          showText: false,
          showMessage: false,
        ),
        child: _content(),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Obx(() => Column(
            children: [
              Row(
                children: [
                  Text(
                    'common.extension-repo'.i18n,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 200,
                    child: fluent.TextBox(
                      controller: TextEditingController(text: c.search.value),
                      placeholder: 'common.search'.i18n,
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
              Expanded(child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: ProgressRing());
                }
                if (c.extensions.isEmpty) {
                  return Center(child: Text('extension-repo.empty'.i18n));
                }
                return _content();
              })),
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
