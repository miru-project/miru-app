import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final extensionLogWindowId = (-1).obs;

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
}
