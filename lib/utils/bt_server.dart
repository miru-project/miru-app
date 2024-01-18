import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/providers/bt_server_provider.dart';
import 'package:miru_app/controllers/bt_dialog_controller.dart';
import 'package:miru_app/controllers/main_controller.dart';
import 'package:miru_app/utils/application.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:miru_app/utils/request.dart';
import 'package:path/path.dart' as path;

class BTServerUtils {
  static Timer? timer;
  static Process? _process;

  // 下载 bt-server
  static downloadLatestBTServer({
    Function(int, int)? onReceiveProgress,
  }) async {
    debugPrint("检测最新版本");
    // 获取最新版本
    const url =
        "https://api.github.com/repos/miru-project/bt-server/releases/latest";

    final res = dio.get(url);
    final remoteVersion = (await res).data["tag_name"] as String;
    debugPrint("最新版本: $remoteVersion");
    late String arch;
    late String platform;
    if (Platform.isAndroid) {
      final supportedAbis = androidDeviceInfo.supportedAbis;
      if (supportedAbis.contains("armeabi-v7a")) {
        arch = "arm";
      }
      if (supportedAbis.contains("x86_64")) {
        arch = "amd64";
      }
      if (supportedAbis.contains("arm64-v8a")) {
        arch = "arm64";
      }
      platform = "android";
    }
    if (Platform.isWindows) {
      arch = "amd64.exe";
      platform = "windows";
    }

    debugPrint("下载 bt-server $remoteVersion $platform $arch");

    final downloadUrl =
        "https://github.com/miru-project/bt-server/releases/download/$remoteVersion/bt-server-$remoteVersion-$platform-$arch";

    final savePath = MiruDirectory.getDirectory;
    await dio.download(
      downloadUrl,
      path.join(savePath, _getBTServerFilename()),
      onReceiveProgress: onReceiveProgress,
    );
  }

  // 启动服务器
  static startServer() async {
    final mainController = Get.find<MainController>();
    final isRunner = mainController.btServerisRunning.value;

    if (isRunner) {
      return;
    }

    final savePath = MiruDirectory.getDirectory;
    final btServerPath = path.join(savePath, _getBTServerFilename());

    try {
      if (Platform.isWindows) {
        _process = await Process.start(
          btServerPath,
          [],
          workingDirectory: savePath,
        );
      } else {
        // 添加运行权限
        await Process.run("chmod", ["+x", btServerPath]);
        _process = await Process.start(
          btServerPath,
          ["&"],
          workingDirectory: savePath,
        );
      }
    } catch (e) {
      final error = e.toString();
      if (error.contains("cannot find the file") ||
          error.contains("No such file or directory")) {
        if (Get.isRegistered<BTDialogController>()) {
          Get.find<BTDialogController>().isInstalled.value = false;
        }
      }
      throw StartServerException('Start bt-server failed');
    }
    checkServer();
  }

  static stopServer() async {
    _process?.kill();
  }

  // 定时检测服务器是否运行的方法
  static Future<void> checkServer() async {
    final mainController = Get.find<MainController>();
    final isRunner = mainController.btServerisRunning;
    final version = mainController.btServerVersion;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        version.value = await BTServerApi.getVersion();
        isRunner.value = true;
      } catch (e) {
        isRunner.value = false;
      }
    });
  }

  // 检查更新
  static Future<String> getRemoteVersion() async {
    try {
      const url =
          "https://api.github.com/repos/miru-project/bt-server/releases/latest";
      final res = dio.get(url);
      final remoteVersion = (await res).data["tag_name"] as String;
      return remoteVersion.replaceFirst("v", '');
    } catch (e) {
      return Get.find<MainController>().btServerVersion.value;
    }
  }

  // 卸载 bt-server
  static Future<void> uninstall() async {
    stopServer();
    final savePath = MiruDirectory.getDirectory;
    final btServerPath = path.join(savePath, _getBTServerFilename());
    await File(btServerPath).delete();
  }

  static Future<bool> isInstalled() async {
    final savePath = MiruDirectory.getDirectory;
    final btServerPath = path.join(savePath, _getBTServerFilename());
    return File(btServerPath).existsSync();
  }

  // 获取 bt-server 可执行文件名
  static String _getBTServerFilename() {
    if (Platform.isWindows) {
      return "btserver.exe";
    }
    return "btserver";
  }
}

class StartServerException implements Exception {
  final String message;
  StartServerException(this.message);
  @override
  String toString() {
    return message;
  }
}
