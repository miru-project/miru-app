import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/code_edit/view.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/widgets/cache_network_image.dart';
import 'package:miru_app/widgets/messenger.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class ExtensionTile extends StatefulWidget {
  const ExtensionTile(this.extension, {Key? key}) : super(key: key);
  final Extension extension;

  @override
  State<ExtensionTile> createState() => _ExtensionTileState();
}

class _ExtensionTileState extends State<ExtensionTile> {
  final fluent.FlyoutController moreFlyoutController =
      fluent.FlyoutController();

  _extensionTypeToString(ExtensionType type) {
    switch (type) {
      case ExtensionType.bangumi:
        return '影视';
      case ExtensionType.fikushon:
        return '小说';
      case ExtensionType.manga:
        return '漫画';
    }
  }

  Widget _buildAndroid(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 35,
        height: 35,
        child: CacheNetWorkImage(
          widget.extension.icon ?? '',
          key: ValueKey(widget.extension.icon),
          fit: BoxFit.contain,
          fallback: const Icon(Icons.extension),
        ),
      ),
      title: Text(widget.extension.name),
      subtitle: Text(
        '${widget.extension.version}  ${_extensionTypeToString(widget.extension.type)} ',
      ),
      onTap: () {
        showPlatformSnackbar(context: context, title: '😣', content: '还没写的（');
      },
      trailing: IconButton(
        onPressed: () {
          // 弹出菜单
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('编辑代码'),
                    onTap: () async {
                      Get.back();
                      Get.to(CodeEditPage(extension: widget.extension));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('卸载'),
                    onTap: () {
                      ExtensionUtils.uninstall(widget.extension.package);
                      Get.back();
                    },
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.more_vert),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.Card(
      child: Row(
        children: [
          // extension icon
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              width: 45,
              height: 45,
              child: CacheNetWorkImage(
                widget.extension.icon ?? '',
                key: ValueKey(widget.extension.icon),
                fit: BoxFit.contain,
                fallback: const Icon(fluent.FluentIcons.add_in),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.extension.name, style: const TextStyle(fontSize: 17)),
              Text(widget.extension.author,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          const Spacer(),
          Text(widget.extension.version),
          const Spacer(),
          Text(_extensionTypeToString(widget.extension.type)),
          const Spacer(),
          fluent.Button(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: Text("设置"),
              ),
              onPressed: () {
                fluent.displayInfoBar(context, builder: (builder, colse) {
                  return const fluent.InfoBar(
                    title: Text("还没做的"),
                  );
                });
              }),
          const SizedBox(width: 16),
          fluent.FlyoutTarget(
            controller: moreFlyoutController,
            child: fluent.IconButton(
              icon: const Icon(fluent.FluentIcons.more),
              onPressed: () {
                moreFlyoutController.showFlyout(
                  autoModeConfiguration: fluent.FlyoutAutoConfiguration(
                    preferredMode: fluent.FlyoutPlacementMode.bottomLeft,
                  ),
                  builder: (context) {
                    return fluent.MenuFlyout(
                      items: [
                        fluent.MenuFlyoutItem(
                          leading: const Icon(fluent.FluentIcons.code),
                          text: const Text('编辑代码'),
                          onPressed: () async {
                            fluent.Flyout.of(context).close();
                            // final window =
                            //     await DesktopMultiWindow.createWindow(jsonEncode({
                            //   'name': 'code',
                            //   'args1': 'args',
                            // }));
                            // window
                            //   ..center()
                            //   ..setTitle('code edit')
                            //   ..show();

                            launchUrl(path.toUri(
                                '${await ExtensionUtils.getExtensionsDir}/${widget.extension.package}.js'));
                          },
                        ),
                        fluent.MenuFlyoutItem(
                          leading: const Icon(fluent.FluentIcons.delete),
                          text: const Text('卸载'),
                          onPressed: () {
                            ExtensionUtils.uninstall(widget.extension.package);
                            fluent.Flyout.of(context).close();
                          },
                        ),
                      ],
                    );
                  },
                  barrierDismissible: true,
                  dismissWithEsc: true,
                );
              },
            ),
          )
        ],
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
