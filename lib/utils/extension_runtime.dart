import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/miru_directory.dart';

class ExtensionRuntime {
  late JavascriptRuntime runtime;
  late Extension extension;
  late PersistCookieJar _cookieJar;
  final _dio = Dio();

  initRuntime(Extension ext) async {
    extension = ext;
    // 读取文件
    final file = File(
        '${await ExtensionUtils.getExtensionsDir}/${extension.package}.js');
    final content = file.readAsStringSync();

    // 初始化runtime
    runtime = getJavascriptRuntime();

    // 添加 cookie manager
    final appDocDir = await MiruDirectory.getDirectory;
    _cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage("$appDocDir/.cookies/"),
    );
    final cookieManager = CookieManager(_cookieJar);
    _dio.interceptors.add(cookieManager);

    // 注册方法
    // 日志
    runtime.onMessage('log', (dynamic args) {
      debugPrint(args[0]);
      ExtensionUtils.addLog(
        extension,
        ExtensionLogLevel.info,
        args[0],
      );
    });
    // 请求
    runtime.onMessage('request', (dynamic args) async {
      ExtensionUtils.addLog(
        extension,
        ExtensionLogLevel.info,
        "GET: ${args[0]} , ${args[1]}",
      );
      return (await _dio.get<String>(args[0],
              options: Options(
                headers: args[1]['headers'] ?? {},
                method: args[1]['method'] ?? 'get',
              )))
          .data;
    });

    // 设置
    runtime.onMessage('registerSetting', (dynamic args) async {
      args[0]['package'] = extension.package;

      // 处理下 options
      List<String>? options;
      if (args[0]['options'] != null) {
        options = [];
        for (final option in (args[0]['options'] as Map).entries) {
          options.add('${option.key}:${option.value}');
        }
      }

      return DatabaseUtils.registerExtensionSetting(
        ExtensionSetting()
          ..package = extension.package
          ..title = args[0]['title']
          ..key = args[0]['key']
          ..value = args[0]['value']
          ..type = ExtensionSetting.stringToType(args[0]['type'])
          ..description = args[0]['description']
          ..defaultValue = args[0]['defaultValue']
          ..options = options,
      );
    });
    runtime.onMessage('getSetting', (dynamic args) async {
      final setting =
          await DatabaseUtils.getExtensionSetting(extension.package, args[0]);
      return setting!.value ?? setting.defaultValue;
    });

    // 清理扩展设置
    runtime.onMessage('cleanSettings', (dynamic args) async {
      // debugPrint('cleanSettings: ${args[0]}');
      return DatabaseUtils.cleanExtensionSettings(
          extension.package, List<String>.from(args[0]));
    });

    // css 选择器
    runtime.onMessage('querySelector', (dynamic args) {
      final content = args[0];
      final selector = args[1];
      final fun = args[2];

      final doc = parse(content).querySelector(selector);

      switch (fun) {
        case 'text':
          return doc?.text;
        case 'outerHTML':
          return doc?.outerHtml;
        case 'innerHTML':
          return doc?.innerHtml;
        default:
          return doc?.outerHtml;
      }
    });

    runtime.onMessage('removeSelector', (dynamic args) {
      final content = args[0];
      final selector = args[1];
      final doc = parse(content);
      doc.querySelectorAll(selector).forEach((element) {
        element.remove();
      });
      return doc.outerHtml;
    });

    // 获取标签属性
    runtime.onMessage('getAttributeText', (args) {
      final content = args[0];
      final selector = args[1];
      final attr = args[2];
      final doc = parse(content).querySelector(selector);
      return doc?.attributes[attr];
    });

    runtime.onMessage('querySelectorAll', (dynamic args) async {
      final content = args[0];
      final selector = args[1];
      final doc = parse(content).querySelectorAll(selector);
      final elements = jsonEncode(doc.map((e) {
        return e.outerHtml;
      }).toList());
      return elements;
    });

    // 初始化运行扩展
    await _initRunExtension(content);
    return this;
  }

  _initRunExtension(String extScript) async {
    runtime.evaluate('''
        class Element {
          constructor(content, selector) {
            this.content = content;
            this.selector = selector || "";
          }

          async querySelector(selector) {
            return new Element(await excute(), selector);
          }

          async excute(fun) {
            return await sendMessage(
              "querySelector",
              JSON.stringify([this.content, this.selector, fun])
            );
          }

          async removeSelector(selector) {
            this.content = await sendMessage(
              "removeSelector",
              JSON.stringify([await this.outerHTML, selector])
            );
            return this;
          }

          async getAttributeText(attr) {
            return await sendMessage(
              "getAttributeText",
              JSON.stringify([await this.outerHTML, this.selector, attr])
            );
          }

          get text() {
            return this.excute("text");
          }

          get outerHTML() {
            return this.excute("outerHTML");
          }

          get innerHTML() {
            return this.excute("innerHTML");
          }
        }
        // 重写 console.log
        var window = (global = globalThis);
        console.log = function (message) {
          if (typeof message === "object") {
            message = JSON.stringify(message);
          }
          sendMessage("log", JSON.stringify([message.toString()]));
        };
        class Extension {
          package = "${extension.package}";
          name = "${extension.name}";
          // 在 load 中注册的 keys
          settingKeys = [];
          async request(url, options) {
            options = options || {};
            options.headers = options.headers || {};
            const miruUrl = options.headers["Miru-Url"] || "${extension.webSite}";
            options.method = options.method || "get";
            const res = await sendMessage(
              "request",
              JSON.stringify([miruUrl + url, options])
            );
            try {
              return JSON.parse(res);
            } catch (e) {
              return res;
            }
          }
          querySelector(content, selector) {
            return new Element(content, selector);
          }
          async querySelectorAll(content, selector) {
            let elements = [];
            JSON.parse(
              await sendMessage("querySelectorAll", JSON.stringify([content, selector]))
            ).forEach((e) => {
              elements.push(new Element(e));
            });
            return elements;
          }
          async getAttributeText(content, selector, attr) {
            return await sendMessage(
              "getAttributeText",
              JSON.stringify([content, selector, attr])
            );
          }
          popular(page) {
            throw new Error("not implement popular");
          }
          latest(page) {
            throw new Error("not implement latest");
          }
          search(kw, page, screening) {
            throw new Error("not implement search");
          }
          detail(url) {
            throw new Error("not implement detail");
          }
          watch(url) {
            throw new Error("not implement watch");
          }
          checkUpdate(url) {
            throw new Error("not implement checkUpdate");
          }
          async getSetting(key) {
            return sendMessage("getSetting", JSON.stringify([key]));
          }
          async registerSetting(settings) {
            console.log(JSON.stringify([settings]));
            this.settingKeys.push(settings.key);
            return sendMessage("registerSetting", JSON.stringify([settings]));
          }
          async load() {}
        }

        async function stringify(callback) {
          const data = await callback();
          return typeof data === "object" ? JSON.stringify(data) : data;
        }

    ''');

    final ext = extScript.replaceAll(
        RegExp(r'export default class.*'), 'class Ext extends Extension {');

    JsEvalResult jsResult = await runtime.evaluateAsync('''
      $ext
      var extenstion = new Ext();
      extenstion.load().then(()=>{
        sendMessage("cleanSettings", JSON.stringify([extenstion.settingKeys]));
      });
    ''');
    await runtime.handlePromise(jsResult);
  }

  // 清理 cookie
  cleanCookie() async {
    await _cookieJar.delete(Uri.parse(extension.webSite));
  }

  /// 添加 cookie
  /// key=value; key=value
  setCookie(String cookies) async {
    final cookieList = cookies.split(';');
    for (final cookie in cookieList) {
      await _cookieJar.saveFromResponse(
        Uri.parse(extension.webSite),
        [Cookie.fromSetCookieValue(cookie)],
      );
    }
  }

  // 列出所有的 cookie
  // Future<String> listCookie() async {
  //   final cookies =
  //       await _cookieJar.loadForRequest(Uri.parse(extension.webSite));
  //   return cookies.map((e) => e.toString()).join(';');
  // }

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

  Future<List<ExtensionListItem>> latest(int page) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync('stringify(()=>extenstion.latest($page))'),
      );
      return jsonDecode(jsResult.stringResult).map<ExtensionListItem>((e) {
        return ExtensionListItem.fromJson(e);
      }).toList();
    });
  }

  Future<List<ExtensionListItem>> search(String kw, int page) async {
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

  Future<ExtensionDetail> detail(String url) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync('stringify(()=>extenstion.detail("$url"))'),
      );
      return ExtensionDetail.fromJson(jsonDecode(jsResult.stringResult));
    });
  }

  Future<Object?> watch(String url) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync('stringify(()=>extenstion.watch("$url"))'),
      );
      final data = jsonDecode(jsResult.stringResult);

      switch (extension.type) {
        case ExtensionType.bangumi:
          return ExtensionBangumiWatch.fromJson(data);
        case ExtensionType.manga:
          return ExtensionMangaWatch.fromJson(data);
        default:
          return ExtensionFikushonWatch.fromJson(data);
      }
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
