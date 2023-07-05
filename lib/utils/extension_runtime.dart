import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';

class ExtensionRuntime {
  late JavascriptRuntime runtime;
  late Extension extension;
  static final dio = Dio();

  initRuntime(Extension ext) async {
    extension = ext;
    // 读取文件
    final file = File(
        '${await ExtensionUtils.getExtensionsDir}/${extension.package}.js');
    final content = file.readAsStringSync();

    // 初始化runtime
    runtime = getJavascriptRuntime();

    // 注册方法
    runtime.onMessage('log', (dynamic args) {
      ExtensionUtils.addLog(
        extension,
        ExtensionLogLevel.info,
        args[0],
      );
    });
    runtime.onMessage('get', (dynamic args) async {
      debugPrint(args[0]);
      ExtensionUtils.addLog(
        extension,
        ExtensionLogLevel.info,
        "GET: ${args[0]}",
      );
      return (await dio.get<String>(args[0])).data;
    });
    // 初始化运行扩展
    await _initRunExtension(content);
    return this;
  }

  _initRunExtension(String extScript) async {
    runtime.evaluate('''
          // 重写 console.log
          var window = global = globalThis;
          console.log = function (message) {
            sendMessage("log", JSON.stringify([message.toString()]));
          };
          class Extension {
            async request(url, options) {
              options = options || {};
              options.headers = options.headers || {};
              const miruUrl = options.headers["Miru-Url"] || "${extension.webSite}";
              options.method = options.method || "get";
              const res = await sendMessage(options.method, JSON.stringify([miruUrl+url, options]));
              try {
                return JSON.parse(res);
              } catch (e) {
                return res;
              }
            }
            latest(page) {
              throw new Error("not implement");
            }
            search(kw, page) {
              throw new Error("not implement");
            }
            detail(url) {
              throw new Error("not implement");
            }
            watch(url) {
              throw new Error("not implement");
            }
            checkUpdate(url) {
              throw new Error("not implement");
            }
            async getSetting(key) {
              return "";
            }
            async registerSetting(settings) {}
            load() {}
            unload() {}
          }
           
          async function stringify(callback){
              const data = await callback();
             return typeof data === "object" ? JSON.stringify(data) : data;
          }
    ''');

    final ext = extScript.replaceAll(
        RegExp(r'export default class.*'), 'class Ext extends Extension {');

    JsEvalResult jsResult = await runtime.evaluateAsync('''
      $ext
      var extenstion = new Ext();
    ''');
    await runtime.handlePromise(jsResult);
  }

  Future<T> _runExtension<T>(Future<T> Function() fun) async {
    try {
      return await fun();
    } catch (e) {
      ExtensionUtils.addLog(
        extension,
        ExtensionLogLevel.error,
        e.toString(),
      );
      rethrow;
    }
  }

  Future<List<ExtensionListItem>> latest(page) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync('stringify(()=>extenstion.latest($page))'),
      );
      return jsonDecode(jsResult.stringResult).map<ExtensionListItem>((e) {
        return ExtensionListItem.fromJson(e);
      }).toList();
    });
  }

  Future<List<ExtensionListItem>> search(kw, page) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime
            .evaluateAsync('stringify(()=>extenstion.search("$kw",$page))'),
      );
      return jsonDecode(jsResult.stringResult).map<ExtensionListItem>((e) {
        return ExtensionListItem.fromJson(e);
      }).toList();
    });
  }

  Future<ExtensionDetail> detail(url) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync('stringify(()=>extenstion.detail("$url"))'),
      );
      return ExtensionDetail.fromJson(jsonDecode(jsResult.stringResult));
    });
  }

  Future<ExtensionBangumiWatch> watch(url) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync('stringify(()=>extenstion.watch("$url"))'),
      );
      return ExtensionBangumiWatch.fromJson(jsonDecode(jsResult.stringResult));
    });
  }

  Future<String> checkUpdate(url) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime
            .evaluateAsync('stringify(()=>extenstion.checkUpdate("$url"))'),
      );
      return jsResult.stringResult;
    });
  }
}
