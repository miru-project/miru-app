import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/main.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/extension/controller.dart';
import 'package:miru_app/pages/search/controller.dart';
import 'package:miru_app/pages/settings/controller.dart';
import 'package:miru_app/utils/extension_runtime.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:path/path.dart' as path;

class ExtensionUtils {
  static late Map<String, ExtensionRuntime> extensions;
  static late Map<String, String> extensionErrorMap;

  static Future<String> get getExtensionsDir async =>
      path.join(await MiruDirectory.getDirectory, 'extensions');

  // 初始化扩展
  static ensureInitialized() async {
    // 创建目录
    Directory(await getExtensionsDir).createSync(recursive: true);
    await _loadExtensions();
    // 监听目录变化
    Directory(await getExtensionsDir).watch().listen((event) {
      _loadExtensions();
    });
  }

  static _loadExtensions() async {
    final Map<String, ExtensionRuntime> exts = {};
    final Map<String, String> extErrorMap = {};

    // 获取扩展列表
    final extensionsList = Directory(await getExtensionsDir).listSync();
    // 遍历扩展列表
    for (final extension in extensionsList) {
      if (path.extension(extension.path) == '.js') {
        final file = File(extension.path);
        final content = await file.readAsString();
        try {
          // 如果文件名和包名不一致，抛出异常
          final ext = ExtensionUtils.parseExtension(content);
          if (path.basenameWithoutExtension(extension.path) != ext.package) {
            throw Exception("文件名和包名不一致");
          }
          exts[ext.package] = await ExtensionRuntime().initRuntime(ext);
        } catch (e) {
          extErrorMap[extension.path] = e.toString();
        }
      }
    }

    extensions = exts;
    extensionErrorMap = extErrorMap;
    // 重载扩展页面
    if (Get.isRegistered<ExtensionPageController>()) {
      Get.find<ExtensionPageController>().onRefresh();
    }
    // 重载搜索页面
    if (Get.isRegistered<SearchPageController>()) {
      Get.find<SearchPageController>().onRefresh();
    }
  }

  static uninstall(String package) async {
    final file = File(path.join(await getExtensionsDir, '$package.js'));
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  static install(String url, BuildContext context) async {
    try {
      final res = await Dio().get<String>(url);
      if (res.data == null) {
        throw Exception("似乎不是扩展");
      }
      final ext = ExtensionUtils.parseExtension(res.data!);
      final savePath = path.join(await getExtensionsDir, '${ext.package}.js');
      // 保存文件
      File(savePath).writeAsStringSync(res.data!);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text("安装错误"),
          content: Text(e.toString()),
          actions: [
            Button(
              child: const Text("关闭"),
              onPressed: () {
                router.pop();
              },
            )
          ],
        ),
      );
      rethrow;
    }
  }

  static addLog(
    Extension ext,
    ExtensionLogLevel level,
    String logContent,
  ) async {
    if (!Get.isRegistered<SettingsController>()) {
      return;
    }
    final windowId = Get.find<SettingsController>().extensionLogWindowId.value;

    if (windowId == -1) {
      return;
    }
    try {
      DesktopMultiWindow.invokeMethod(
        windowId,
        "addLog",
        jsonEncode(
          ExtensionLog(
            extension: ext,
            content: logContent,
            time: DateTime.now(),
            level: level,
          ).toJson(),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ==MiruExtension==
  // @name         Enime
  // @version      v0.0.1
  // @author       MiaoMint
  // @lang         all
  // @license      MIT
  // @icon         https://avatars.githubusercontent.com/u/74993083?s=200&v=4
  // @package      moe.enime
  // @type         bangumi
  // @webSite      https://api.enime.moe/
  // @description  Enime API is an open source API service for developers to access anime info (as well as their video sources) https://github.com/Enime-Project/api.enime.moe
  // ==/MiruExtension==

  // 解析扩展为元数据
  static Extension parseExtension(String extension) {
    Map<String, dynamic> result = {};
    RegExp exp = RegExp(r'@(\w+)\s+(.*)');
    Iterable<RegExpMatch> matches = exp.allMatches(extension);
    for (RegExpMatch match in matches) {
      result[match.group(1)!] = match.group(2);
    }
    result['nsfw'] = result['nsfw'] == "true";
    return Extension.fromJson(result);
  }
}
