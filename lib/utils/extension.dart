import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/controllers/extension/extension_controller.dart';
import 'package:miru_app/controllers/search_controller.dart';
import 'package:miru_app/controllers/settings_controller.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:miru_app/utils/request.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:path/path.dart' as path;

class ExtensionUtils {
  static Map<String, ExtensionService> runtimes = {};
  static Map<String, String> extensionErrorMap = {};
  static Timer? _timer;

  static Future<String> get getExtensionsDir async =>
      path.join(MiruDirectory.getDirectory, 'extensions');

  // 初始化扩展
  static ensureInitialized() async {
    // 创建目录
    Directory(await getExtensionsDir).createSync(recursive: true);
    await _loadExtensions();
    // 监听目录变化
    Directory(await getExtensionsDir).watch().listen((event) {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 1), () async {
        await _loadExtensions();
        debugPrint("load extension");
      });
    });
  }

  static _loadExtensions() async {
    final Map<String, ExtensionService> exts = {};
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
            throw Exception("Inconsistency between file name and package name");
          }
          exts[ext.package] = await ExtensionService().initRuntime(ext);
        } catch (e) {
          extErrorMap[extension.path] = e.toString();
        }
      }
    }

    runtimes = exts;
    extensionErrorMap = extErrorMap;
    // 重载扩展页面
    if (Get.isRegistered<ExtensionPageController>()) {
      Get.find<ExtensionPageController>().callRefresh();
    }
    // 重载搜索页面
    if (Get.isRegistered<SearchPageController>()) {
      Get.find<SearchPageController>().callRefresh();
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
      final res = await dio.get<String>(url);
      if (res.data == null) {
        throw Exception("Does not seem to be an extension");
      }
      final ext = ExtensionUtils.parseExtension(res.data!);
      final savePath = path.join(await getExtensionsDir, '${ext.package}.js');
      // 保存文件
      File(savePath).writeAsStringSync(res.data!);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showPlatformDialog(
        context: context,
        title: 'extension-install-error'.i18n,
        content: Text(e.toString()),
        actions: [
          PlatformButton(
            child: Text('common.close'.i18n),
            onPressed: () {
              RouterUtils.pop();
            },
          )
        ],
      );
      rethrow;
    }
  }

  static String typeToString(ExtensionType type) {
    switch (type) {
      case ExtensionType.bangumi:
        return 'extension-type.video'.i18n;
      case ExtensionType.fikushon:
        return 'extension-type.novel'.i18n;
      case ExtensionType.manga:
        return 'extension-type.comic'.i18n;
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

  static addNetworkLog(
    String key,
    ExtensionNetworkLog log,
  ) {
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
        "addNetworkLog",
        jsonEncode({
          'key': key,
          'log': log.toJson(),
        }),
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
