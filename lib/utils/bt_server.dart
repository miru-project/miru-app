import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/api/bt_server.dart';
import 'package:miru_app/pages/bt_dialog/controller.dart';
import 'package:miru_app/pages/main/controller.dart';
import 'package:miru_app/utils/application.dart';
import 'package:miru_app/utils/miru_directory.dart';
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

    final dio = Dio();
    final res = dio.get(url);
    final remoteVersion = (await res).data["tag_name"] as String;
    debugPrint("最新版本: $remoteVersion");
    late String structure;
    late String platform;
    if (Platform.isAndroid) {
      final supportedAbis = androidDeviceInfo.supportedAbis;
      if (supportedAbis.contains("armeabi-v7a")) {
        structure = "arm";
      }
      if (supportedAbis.contains("x86_64")) {
        structure = "amd64";
      }
      if (supportedAbis.contains("arm64-v8a")) {
        structure = "arm64";
      }
      platform = "android";
    }
    if (Platform.isWindows) {
      structure = "amd64.exe";
      platform = "windows";
    }

    debugPrint("下载 bt-server $remoteVersion $platform $structure");

    final downloadUrl =
        "https://github.com/miru-project/bt-server/releases/download/$remoteVersion/bt-server-$remoteVersion-$platform-$structure";

    final savePath = await MiruDirectory.getDirectory;
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

    final savePath = await MiruDirectory.getDirectory;
    final btServerPath = path.join(savePath, _getBTServerFilename());

    try {
      if (Platform.isWindows) {
        await Process.run(
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
        Get.find<BTDialogController>().isInstalled.value = false;
      }
      rethrow;
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

  static Future<bool> isInstalled() async {
    final savePath = await MiruDirectory.getDirectory;
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
