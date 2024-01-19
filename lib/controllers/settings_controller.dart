import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/request.dart';

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
        "name": 'debug',
      }));
      extensionLogWindowId.value = window.windowId;
      window
        ..center()
        ..setTitle("miru extension debug")
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
      // 轮询带执行的方法并执行方法
      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        if (extensionLogWindowId.value == -1) {
          timer.cancel();
          return;
        }
        await _handleMethods();
      });

      return;
    }
    WindowController.fromWindowId(extensionLogWindowId.value).close();
    extensionLogWindowId.value = -1;
  }

  // 返回执行结果
  _invokeMethodResult(String methodKey, dynamic result) async {
    await DesktopMultiWindow.invokeMethod(
      extensionLogWindowId.value,
      "result",
      {
        "key": methodKey,
        "result": result,
      },
    );
  }

  // 获取方法列表
  Future<List<Map<String, dynamic>>> _getMethods() async {
    final methods = await DesktopMultiWindow.invokeMethod(
      extensionLogWindowId.value,
      "getMethods",
    );

    return List<dynamic>.from(methods)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // 处理待执行的方法
  Future<void> _handleMethods() async {
    final methods = await _getMethods();
    for (final call in methods) {
      if (call["method"] == "getInstalledExtensions") {
        _invokeMethodResult(
          call["key"],
          ExtensionUtils.runtimes.values
              .toList()
              .map((e) => e.extension.toJson())
              .toList(),
        );
      }

      if (call["method"] == "debugExecute") {
        final arguments = call["arguments"];
        final extension = ExtensionUtils.runtimes[arguments["package"]];
        final method = arguments["method"];
        final runtime = extension!.runtime;
        try {
          final jsResult = await runtime.handlePromise(
            await runtime.evaluateAsync('stringify(()=>{return $method})'),
          );
          final result = jsResult.stringResult;
          _invokeMethodResult(
            call["key"],
            result,
          );
        } catch (e) {
          _invokeMethodResult(
            call["key"],
            e.toString(),
          );
        }
      }
    }
  }

  _getContributors() async {
    final res = await dio
        .get("https://api.github.com/repos/miru-project/miru-app/contributors");
    contributors.value = List.from(res.data)
        .where((element) => element["type"] == "User")
        .toList();
  }
}
