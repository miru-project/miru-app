// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/main.dart';
import 'package:miru_app/utils/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class MainController extends GetxController {
  final selectedTab = 0.obs;

  void changeTab(int i) {
    selectedTab.value = i;
  }

  // 更新
  checkUpdate(BuildContext context) async {
    try {
      // "https://api.github.com/repos/miru-project/miru-app/releases/latest"
      const url =
          "https://api.github.com/repos/miru-project/miru-app/releases/latest";
      final res = await Dio().get(url);
      final remoteVersion = res.data["tag_name"];
      if (packageInfo.version != remoteVersion) {
        if (Platform.isAndroid) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  '检测到新版本$remoteVersion',
                  style: Get.theme.textTheme.bodyLarge,
                ),
                content: Text(res.data['body']),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('关闭'),
                  ),
                  FilledButton(
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
            },
          );
          return;
        }

        fluent.showDialog(
          context: context,
          builder: (context) {
            return fluent.ContentDialog(
              title: Text('检测到新版本$remoteVersion'),
              content: Text(res.data['body']),
              actions: [
                fluent.Button(
                  onPressed: () {
                    router.pop();
                  },
                  child: const Text('关闭'),
                ),
                fluent.FilledButton(
                  child: const Text('前往更新'),
                  onPressed: () {
                    router.pop();
                    launchUrl(
                      Uri.parse(res.data['html_url']),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        if (Platform.isAndroid) {
          Get.rawSnackbar(
            message: '当前已是最新版本',
          );
          return;
        }

        fluent.displayInfoBar(context, builder: (context, close) {
          return const fluent.InfoBar(
            title: Text('当前已是最新版本'),
          );
        });
      }
    } catch (e) {
      if (Platform.isAndroid) {
        Get.rawSnackbar(
          message: '检查更新失败,网络出现异常',
        );
        return;
      }

      fluent.displayInfoBar(context, builder: (context, close) {
        return const fluent.InfoBar(
          title: Text('检查更新失败,网络出现异常'),
        );
      });
    }
  }
}
