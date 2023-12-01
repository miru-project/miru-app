import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/views/pages/code_edit_page.dart';
import 'package:miru_app/views/pages/extension/extension_settings_page.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
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

  Widget _buildAndroid(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 35,
        height: 35,
        child: CacheNetWorkImagePic(
          widget.extension.icon ?? '',
          key: ValueKey(widget.extension.icon),
          fit: BoxFit.contain,
          fallback: const Icon(Icons.extension),
        ),
      ),
      title: Text(widget.extension.name),
      subtitle: Text(
        '${widget.extension.version}  ${ExtensionUtils.typeToString(widget.extension.type)} ',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () {
        Get.to(ExtensionSettingsPage(package: widget.extension.package));
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
                    title: Text('extension.edit-code'.i18n),
                    onTap: () async {
                      Get.back();
                      Get.to(CodeEditPage(extension: widget.extension));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: Text('common.uninstall'.i18n),
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
          Expanded(
            flex: 3,
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
                    child: CacheNetWorkImagePic(
                      widget.extension.icon ?? '',
                      key: ValueKey(widget.extension.icon),
                      fit: BoxFit.contain,
                      fallback: const Icon(fluent.FluentIcons.add_in),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.extension.name,
                        style: const TextStyle(
                          fontSize: 17,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        widget.extension.author,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text(widget.extension.version)),
          Expanded(
            child: Text(ExtensionUtils.typeToString(widget.extension.type)),
          ),
          const Spacer(),
          fluent.IconButton(
              // child: Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 20,
              //     vertical: 2,
              //   ),
              //   child: Text('common.settings'.i18n),
              // ),
              icon: const Icon(fluent.FluentIcons.settings),
              onPressed: () {
                router.push(Uri(
                  path: '/extension_settings',
                  queryParameters: {'package': widget.extension.package},
                ).toString());
              }),
          const SizedBox(width: 8),
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
                          text: Text('extension.edit-code'.i18n),
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
                          text: Text('common.uninstall'.i18n),
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
