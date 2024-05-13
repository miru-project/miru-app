import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/bt_dialog_controller.dart';
import 'package:miru_app/utils/bt_server.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/progress.dart';

class BTDialog extends StatefulWidget {
  const BTDialog({super.key});

  @override
  State<BTDialog> createState() => _BTDialogState();
}

class _BTDialogState extends State<BTDialog> {
  final BTDialogController c = Get.put(BTDialogController());

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      if (!c.isInstalled.value) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("bt-server.not-installed".i18n),
            const SizedBox(height: 16),
            if (c.isDownloading.value)
              SizedBox(
                width: double.infinity,
                child: ProgressBar(value: c.progress.value),
              )
            else
              PlatformFilledButton(
                child: Text("common.install".i18n),
                onPressed: () {
                  c.downloadOrUpgradeServer(context);
                },
              ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.isRuning.value)
            Text("bt-server.running".i18n)
          else
            Text("bt-server.stopped".i18n),
          const SizedBox(height: 16),
          if (c.isRuning.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Text(
                    FlutterI18n.translate(
                      context,
                      'bt-server.version',
                      translationParams: {
                        "version": c.version.value,
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (c.hasUpdate.value)
                    Text(
                      FlutterI18n.translate(
                        context,
                        'bt-server.remote-version',
                        translationParams: {
                          "version": c.remoteVersion.value,
                        },
                      ),
                    ),
                ],
              ),
            ),
          Wrap(
            children: [
              if (c.isRuning.value) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PlatformFilledButton(
                    child: Text('bt-server.stop'.i18n),
                    onPressed: () {
                      BTServerUtils.stopServer();
                    },
                  ),
                ),
                // 升级按钮
                if (c.hasUpdate.value)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PlatformFilledButton(
                      child: Text("bt-server.upgrade".i18n),
                      onPressed: () {
                        c.downloadOrUpgradeServer(context);
                      },
                    ),
                  ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PlatformFilledButton(
                    child: Text("bt-server.start".i18n),
                    onPressed: () {
                      BTServerUtils.startServer();
                    },
                  ),
                ),
              if (c.isInstalled.value)
                //  卸载
                PlatformFilledButton(
                  child: Text("common.uninstall".i18n),
                  onPressed: () async {
                    await BTServerUtils.uninstall();
                    c.isInstalled.value = false;
                  },
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildMobile(BuildContext context) {
    return AlertDialog(
      title: const Text("BT-Server"),
      content: _buildContent(context),
      actions: [
        PlatformTextButton(
          child: Text("common.close".i18n),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.ContentDialog(
      title: const Text("BT-Server"),
      content: _buildContent(context),
      actions: [
        fluent.Button(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("common.close".i18n),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
