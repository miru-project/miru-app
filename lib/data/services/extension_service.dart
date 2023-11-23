import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/miru_directory.dart';

class ExtensionService {
  late JavascriptRuntime runtime;
  late Extension extension;
  late PersistCookieJar _cookieJar;
  final _dio = Dio();
  String _cuurentRequestUrl = '';

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
      // debugPrint(args[0]);
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
        "Request: ${args[0]} , ${args[1]}",
      );
      _cuurentRequestUrl = args[0];
      return (await _dio.request<String>(
        args[0],
        data: args[1]['data'],
        queryParameters: args[1]['queryParameters'] ?? {},
        options: Options(
          headers: args[1]['headers'] ?? {},
          method: args[1]['method'] ?? 'get',
        ),
      ))
          .data;
    });
    // request with headers
    runtime.onMessage('RequestWithHeader', (dynamic args) async {
      ExtensionUtils.addLog(
        extension,
        ExtensionLogLevel.info,
        "RequestWithHeader: ${args[0]} , ${args[1]}",
      );
      _cuurentRequestUrl = args[0];
      Response response = await _dio.request<String>(
        args[0],
        data: args[1]['data'],
        queryParameters: args[1]['queryParameters'] ?? {},
        options: Options(
          headers: args[1]['headers'] ?? {},
          method: args[1]['method'] ?? 'get',
        ),
      );
      Map<String, dynamic> headers = response.headers.map;
      return {'data': response.data, 'headers': headers};
    });
    // 设置
    runtime.onMessage('registerSetting', (dynamic args) async {
      args[0]['package'] = extension.package;

      return DatabaseService.registerExtensionSetting(
        ExtensionSetting()
          ..package = extension.package
          ..title = args[0]['title']
          ..key = args[0]['key']
          ..value = args[0]['value']
          ..type = ExtensionSetting.stringToType(args[0]['type'])
          ..description = args[0]['description']
          ..defaultValue = args[0]['defaultValue']
          ..options = jsonEncode(args[0]['options']),
      );
    });
    runtime.onMessage('getSetting', (dynamic args) async {
      final setting =
          await DatabaseService.getExtensionSetting(extension.package, args[0]);
      return setting!.value ?? setting.defaultValue;
    });

    // 清理扩展设置
    runtime.onMessage('cleanSettings', (dynamic args) async {
      // debugPrint('cleanSettings: ${args[0]}');
      return DatabaseService.cleanExtensionSettings(
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
          return doc?.text ?? '';
        case 'outerHTML':
          return doc?.outerHtml ?? '';
        case 'innerHTML':
          return doc?.innerHtml ?? '';
        default:
          return doc?.outerHtml ?? '';
      }
    });

    // xpath 选择器
    runtime.onMessage('queryXPath', (args) {
      final content = args[0];
      final selector = args[1];
      final fun = args[2];

      final xpath = HtmlXPath.html(content);
      final result = xpath.queryXPath(selector);

      switch (fun) {
        case 'attr':
          return result.attr ?? '';
        case 'attrs':
          return jsonEncode(result.attrs);
        case 'text':
          return result.node?.text;
        case 'allHTML':
          return result.nodes
              .map((e) => (e.node as Element).outerHtml)
              .toList();
        case 'outerHTML':
          return (result.node?.node as Element).outerHtml;
        default:
          return result.node?.text;
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
    final cryptoJs = await rootBundle.loadString('assets/js/CryptoJS.min.js');
    final jsencrypt = await rootBundle.loadString('assets/js/jsencrypt.min.js');
    final md5 = await rootBundle.loadString('assets/js/md5.min.js');
    runtime.evaluate('''
          // 重写 console.log
          var window = (global = globalThis);
          $cryptoJs
          $jsencrypt
          $md5
          class Element {
            constructor(content, selector) {
              this.content = content;
              this.selector = selector || "";
            }

            async querySelector(selector) {
              return new Element(await this.excute(), selector);
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
          class XPathNode {
            constructor(content, selector) {
              this.content = content;
              this.selector = selector;
            }

            async excute(fun) {
              return await sendMessage(
                "queryXPath",
                JSON.stringify([this.content, this.selector, fun])
              );
            }

            get attr() {
              return this.excute("attr");
            }

            get attrs() {
              return this.excute("attrs");
            }

            get text() {
              return this.excute("text");
            }
            
            get allHTML() {
              return this.excute("allHTML");
            }

            get outerHTML() {
              return this.excute("outerHTML");
            }
          }

          
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
            async RequestWithHeader(url, options) {
              options = options || {};
              options.headers = options.headers || {};
              const miruUrl = options.headers["Miru-Url"] || "${extension.webSite}";
              options.method = options.method || "get";
              const res = await sendMessage(
              "RequestWithHeader",
              JSON.stringify([miruUrl + url, options])
             );
             console.log(res)
            try {
              return JSON.parse(res);
            } catch (e) {
               return res;
              }
           }
            querySelector(content, selector) {
              return new Element(content, selector);
            }
            queryXPath(content, selector) {
              return new XPathNode(content, selector);
            }
            async querySelectorAll(content, selector) {
              let elements = [];
              JSON.parse(
                await sendMessage("querySelectorAll", JSON.stringify([content, selector]))
              ).forEach((e) => {
                elements.push(new Element(e, selector));
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
            search(kw, page, filter) {
              throw new Error("not implement search");
            }
            createFilter(filter){
              throw new Error("not implement createFilter");
            }
            updatePages(){

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
      List<ExtensionListItem> result =
          jsonDecode(jsResult.stringResult).map<ExtensionListItem>((e) {
        return ExtensionListItem.fromJson(e);
      }).toList();
      for (var element in result) {
        element.headers ??= {
          "Referer": _cuurentRequestUrl,
        };
      }
      return result;
    });
  }

  Future<List<ExtensionListItem>> search(
    String kw,
    int page, {
    Map<String, List<String>>? filter,
  }) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync(
            'stringify(()=>extenstion.search("$kw",$page,${filter == null ? null : jsonEncode(filter)}))'),
      );
      List<ExtensionListItem> result =
          jsonDecode(jsResult.stringResult).map<ExtensionListItem>((e) {
        return ExtensionListItem.fromJson(e);
      }).toList();
      for (var element in result) {
        element.headers ??= {
          "Referer": _cuurentRequestUrl,
        };
      }
      return result;
    });
  }

  Future<Map<String, ExtensionFilter>> createFilter({
    Map<String, List<String>>? filter,
  }) async {
    late String eval;
    if (filter == null) {
      eval = 'stringify(()=>extenstion.createFilter())';
    } else {
      eval =
          'stringify(()=>extenstion.createFilter(JSON.parse(\'${jsonEncode(filter)}\')))';
    }
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync(eval),
      );
      Map<String, dynamic> result = jsonDecode(jsResult.stringResult);
      return result.map(
        (key, value) => MapEntry(
          key,
          ExtensionFilter.fromJson(value),
        ),
      );
    });
  }

  Future<ExtensionDetail> detail(String url) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync('stringify(()=>extenstion.detail("$url"))'),
      );
      final result =
          ExtensionDetail.fromJson(jsonDecode(jsResult.stringResult));
      result.headers ??= {
        "Referer": _cuurentRequestUrl,
      };
      return result;
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
          final result = ExtensionBangumiWatch.fromJson(data);
          result.headers ??= {
            "Referer": _cuurentRequestUrl,
          };
          return result;
        case ExtensionType.manga:
          final result = ExtensionMangaWatch.fromJson(data);
          result.headers ??= {
            "Referer": _cuurentRequestUrl,
          };
          if (result.pages == null) {
            return result;
          }
          result.urls.addAll(
              List<String>.filled(result.pages! - result.urls.length, ""));
          return result;
        default:
          return ExtensionFikushonWatch.fromJson(data);
      }
    });
  }

  Future<Object?> updatePages(int page) async {
    return _runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime
            .evaluateAsync('stringify(()=>extenstion.updatePages("$page"))'),
      );
      final data = jsonDecode(jsResult.stringResult);

      final result = ExtensionUpdatePages.fromJson(data);
      result.headers ??= {
        "Referer": _cuurentRequestUrl,
      };
      return result;
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
