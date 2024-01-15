// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:flutter/services.dart';

late PackageInfo packageInfo;
late AndroidDeviceInfo androidDeviceInfo;
late WindowsDeviceInfo windowsDeviceInfo;

class ApplicationUtils {
  static Future ensureInitialized() async {
    packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfo.androidInfo;
    }
    if (Platform.isWindows) {
      windowsDeviceInfo = await deviceInfo.windowsInfo;
    }
    return packageInfo;
  }

  static feedbackDialog(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    if (Platform.isAndroid) {
      final issueUrl =
          Uri.parse("https://github.com/miru-project/miru-app/issues");
      final bool showdialog = MiruStorage.getSetting(SettingKey.showBugReport);
      final isShowdialog = showdialog.obs;
      final List errorMessage = MiruStorage.getSetting(SettingKey.errorMessage);
      Get.to(() => Scaffold(
            bottomSheet: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    children: [
                      Obx(() => Checkbox(
                            value: isShowdialog.value,
                            onChanged: (val) {
                              if (val != null) {
                                MiruStorage.setSetting(
                                    SettingKey.showBugReport, val);
                                isShowdialog.value = val;
                              }
                            },
                          )),
                      Text("report.show-report-checkbox".i18n)
                    ],
                  ),
                  Row(children: [
                    FilledButton(
                        onPressed: () async {
                          MiruStorage.setSetting(SettingKey.errorMessage, []);
                          Clipboard.setData(ClipboardData(
                              text: errorMessage
                                  .map((map) => map.entries
                                      .map((e) => '${e.key}:${e.value}')
                                      .join('\n'))
                                  .join('\n')));
                          showPlatformSnackbar(
                              context: context, content: "report.copied".i18n);
                          if (await canLaunchUrl(issueUrl)) {
                            await launchUrl(issueUrl);
                          } else {
                            throw 'failed to launch $issueUrl';
                          }
                          Get.back();
                        },
                        child: Text("report.github-bug-report".i18n)),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: errorMessage
                                  .map((map) => map["exception"])
                                  .join('\n')));
                          showPlatformSnackbar(
                              context: context, content: "report.copied".i18n);
                        },
                        child: Text("report.copy-message".i18n)),
                    ElevatedButton(
                        onPressed: () async {
                          MiruStorage.setSetting(SettingKey.errorMessage, []);
                          Get.back();
                        },
                        child: Text("common.close".i18n)),
                  ])
                ])),
            appBar: AppBar(
              title: Text('report.title'.i18n),
            ),
            body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: errorMessage.length,
                        itemBuilder: (context, index) {
                          return Card(
                              child: ListTile(
                            isThreeLine: true,
                            title: Text(
                                "Context : ${errorMessage[index]["context"]}"),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Exception : ${errorMessage[index]["exception"]}"),
                                  Text("${errorMessage[index]["stackTrace"]}")
                                ]),
                          ));
                        }),
                  ),
                ])),
          ));
      return;
    }
    context.go("/bug-report");
  }

  static checkUpdate(BuildContext context, {bool showSnackbar = false}) async {
    try {
      const url =
          "https://api.github.com/repos/miru-project/miru-app/releases/latest";
      final res = await Dio().get(url);
      final remoteVersion =
          (res.data["tag_name"] as String).replaceFirst('v', '');
      debugPrint('remoteVersion: $remoteVersion');
      if (packageInfo.version != remoteVersion) {
        if (Platform.isAndroid) {
          Get.to(
            Scaffold(
              appBar: AppBar(
                title: Text(
                  FlutterI18n.translate(
                    context,
                    'upgrade.new-version',
                    translationParams: {
                      'version': remoteVersion,
                    },
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(child: Markdown(data: res.data['body'])),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PlatformFilledButton(
                        onPressed: () {
                          RouterUtils.pop();
                          launchUrl(
                            Uri.parse(res.data['html_url']),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text('upgrade.download'.i18n),
                      ),
                    )
                  ],
                ),
              ),
            ),
            transition: Transition.rightToLeftWithFade,
          );
          return;
        }

        showPlatformDialog(
          context: context,
          title: FlutterI18n.translate(
            context,
            'upgrade.new-version',
            translationParams: {
              'version': remoteVersion,
            },
          ),
          content: Markdown(
            shrinkWrap: true,
            data: res.data['body'],
          ),
          actions: [
            PlatformTextButton(
              onPressed: () {
                RouterUtils.pop();
              },
              child: Text('upgrade.not-now'.i18n),
            ),
            PlatformFilledButton(
              onPressed: () {
                RouterUtils.pop();
                launchUrl(
                  Uri.parse(res.data['html_url']),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Text('upgrade.download'.i18n),
            )
          ],
        );
      } else {
        if (!showSnackbar) {
          return;
        }
        showPlatformSnackbar(
          context: context,
          title: 'upgrade.check-update'.i18n,
          content: "upgrade.no-update".i18n,
        );
      }
    } catch (e) {
      if (!showSnackbar) {
        return;
      }
      showPlatformSnackbar(
        context: context,
        title: 'upgrade.check-update'.i18n,
        content: 'upgrade.error'.i18n,
      );
    }
  }
}
