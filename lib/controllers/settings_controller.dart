import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final contributors = [].obs;
  final extensionLogWindowId = (-1).obs;

  final links = {
    'Github': 'https://github.com/miru-project/miru-app',
    'Telegram Group': 'https://t.me/MiruChat',
    'Website': 'https://miru.js.org',
    'F-Droid': 'https://f-droid.org/zh_Hans/packages/miru.miaomint/',
  };

  @override
  void onInit() {
    super.onInit();
    _getContributors();
  }

  void toggleExtensionLogWindow(bool open) async {
    if (open && extensionLogWindowId.value == -1) {
      final window = await DesktopMultiWindow.createWindow(jsonEncode({
        "name": 'log',
      }));
      extensionLogWindowId.value = window.windowId;
      window
        ..center()
        ..setTitle("miru extension log")
        ..show();

      // 用于检测窗口是否关闭
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        try {
          await DesktopMultiWindow.invokeMethod(
            extensionLogWindowId.value,
            "state",
          );
        } catch (e) {
          extensionLogWindowId.value = -1;
          timer.cancel();
        }
      });
      return;
    }
    WindowController.fromWindowId(extensionLogWindowId.value).close();
    extensionLogWindowId.value = -1;
  }

  _getContributors() async {
    final res = await Dio()
        .get("https://api.github.com/repos/miru-project/miru-app/contributors");
    contributors.value = List.from(res.data)
        .where((element) => element["type"] == "User")
        .toList();
  }
}
