// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/package_info.dart';
import 'package:miru_app/widgets/button.dart';
import 'package:miru_app/widgets/messenger.dart';
import 'package:url_launcher/url_launcher.dart';

class MainController extends GetxController {
  final selectedTab = 0.obs;

  void changeTab(int i) {
    selectedTab.value = i;
  }

  // 更新
  checkUpdate(BuildContext context, {bool showSnackbar = false}) async {
    try {
      // "https://api.github.com/repos/miru-project/miru-app/releases/latest"
      const url =
          "https://api.github.com/repos/miru-project/miru-app/releases/latest";
      final res = await Dio().get(url);
      final remoteVersion =
          (res.data["tag_name"] as String).replaceFirst('v', '');
      if (packageInfo.version != remoteVersion) {
        if (Platform.isAndroid) {
          showPlatformDialog(
            context: context,
            title: '检测到新版本$remoteVersion',
            content: Markdown(data: res.data['body']),
            actions: [
              PlatformTextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('关闭'),
              ),
              PlatformFilledButton(
                onPressed: () {
                  Get.back();
                  launchUrl(
                    Uri.parse(res.data['html_url']),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: const Text('前往更新'),
              )
            ],
          );
          return;
        }
      } else {
        if (!showSnackbar) {
          return;
        }
        showPlatformSnackbar(
          context: context,
          title: '检查更新',
          content: "当前已是最新版本",
        );
      }
    } catch (e) {
      if (!showSnackbar) {
        return;
      }
      showPlatformSnackbar(
        context: context,
        title: '检查更新',
        content: "检查更新失败,网络出现异常",
      );
    }
  }
}
