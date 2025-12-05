import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:html/dom.dart';
import 'package:miru_app/data/services/extension_jscore_plugin.dart';
import 'package:miru_app/utils/log.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/request.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/utils/extension.dart';
import './extension_service.dart';

class ExtensionServiceApi2 extends ExtensionService {
  String _cuurentRequestUrl = '';
  static Map<dynamic, dynamic> evalMap = {};
  late material.BuildContext currentcontext;
  @override
  void initService() {
    jsLog(dynamic args) {
      logger.info(args[0]);
      ExtensionUtils.addLog(
        extension,
        ExtensionLogLevel.info,
        args[0],
      );
    }

    jsRequest(dynamic args) async {
      _cuurentRequestUrl = args[0];
      final headers = args[1]['headers'] ?? {};
      if (headers['User-Agent'] == null) {
        headers['User-Agent'] = MiruStorage.getUASetting();
      }

      final url = args[0];
      final method = args[1]['method'] ?? 'get';
      final requestBody = args[1]['data'];
      final useByteToDecode = args[2] ?? false;
      final log = ExtensionNetworkLog(
        extension: extension,
        url: args[0],
        method: method,
        requestHeaders: headers,
      );
      final key = UniqueKey().toString();
      ExtensionUtils.addNetworkLog(
        key,
        log,
      );

      try {
        final res = await dio.request(
          url,
          data: requestBody,
          queryParameters: args[1]['queryParameters'] ?? {},
          options: Options(
            responseType: useByteToDecode ? ResponseType.bytes : null,
            headers: headers,
            method: method,
          ),
        );
        if (useByteToDecode) {
          res.data = utf8.decode(res.data);
        }
        log.requestHeaders = res.requestOptions.headers;
        log.responseBody = res.data;
        log.responseHeaders = res.headers.map.map(
          (key, value) => MapEntry(
            key,
            value.join(';'),
          ),
        );
        log.statusCode = res.statusCode;

        ExtensionUtils.addNetworkLog(
          key,
          log,
        );
        return res.data;
      } on DioException catch (e) {
        log.url = e.requestOptions.uri.toString();
        log.requestHeaders = e.requestOptions.headers;
        log.responseBody = e.response?.data;
        log.responseHeaders = e.response?.headers.map.map(
          (key, value) => MapEntry(
            key,
            value.join(';'),
          ),
        );
        log.statusCode = e.response?.statusCode;
        ExtensionUtils.addNetworkLog(
          key,
          log,
        );
        rethrow;
      }
    }

    jsRawRequest(dynamic args) async {
      _cuurentRequestUrl = args[0];
      final headers = args[1]['headers'] ?? {};
      if (headers['User-Agent'] == null) {
        headers['User-Agent'] = MiruStorage.getUASetting();
      }

      final url = args[0];
      final method = args[1]['method'] ?? 'get';
      final requestBody = args[1]['data'];

      final log = ExtensionNetworkLog(
        extension: extension,
        url: args[0],
        method: method,
        requestHeaders: headers,
      );
      final key = UniqueKey().toString();
      ExtensionUtils.addNetworkLog(
        key,
        log,
      );

      try {
        final res = await dio.request<String>(
          url,
          data: requestBody,
          queryParameters: args[1]['queryParameters'] ?? {},
          options: Options(
            headers: headers,
            method: method,
          ),
        );
        log.requestHeaders = res.requestOptions.headers;
        log.responseBody = res.data;
        log.responseHeaders = res.headers.map.map(
          (key, value) => MapEntry(
            key,
            value.join(';'),
          ),
        );
        log.statusCode = res.statusCode;

        ExtensionUtils.addNetworkLog(
          key,
          log,
        );
        return {
          "data": res.data,
          "headers": res.headers.map.map(
            (key, value) => MapEntry(
              key,
              value.join(';'),
            ),
          )
        };
      } on DioException catch (e) {
        log.url = e.requestOptions.uri.toString();
        log.requestHeaders = e.requestOptions.headers;
        log.responseBody = e.response?.data;
        log.responseHeaders = e.response?.headers.map.map(
          (key, value) => MapEntry(
            key,
            value.join(';'),
          ),
        );
        log.statusCode = e.response?.statusCode;
        ExtensionUtils.addNetworkLog(
          key,
          log,
        );
        rethrow;
      }
    }

    jsRegisterSetting(dynamic args) async {
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
    }

    jsGetMessage(dynamic args) async {
      final setting =
          await DatabaseService.getExtensionSetting(extension.package, args[0]);
      return setting!.value ?? setting.defaultValue;
    }

    jsCleanSettings(dynamic args) async {
      // debugPrint('cleanSettings: ${args[0]}');
      return DatabaseService.cleanExtensionSettings(
          extension.package, List<String>.from(args[0]));
    }

    jsSnackBar(dynamic args) {
      Future.delayed(Duration.zero, () {
        if (currentcontext.mounted) {
          showPlatformSnackbar(context: currentcontext, content: args[0]);
        }
      });
    }

    jsSaveData(dynamic args) async {
      await MiruStorage.setExtensionData(extension.package, args[0], args[1]);
    }

    jsGetData(dynamic args) async {
      return await MiruStorage.getExtensionData(extension.package, args[0]);
    }

    jsConvert(dynamic args) async {
      final String data = args[0];
      final String from = args[1].toLowerCase();
      final String to = args[2].toLowerCase();
      try {
        const typeMap = <String, Codec>{
          'utf8': utf8,
          'base64': base64,
          'latin1': latin1,
          'ascii': ascii,
        };
        List<int> byte = typeMap[from]!.encode(data);
        String result = to == "utf8"
            ? utf8.decode(byte, allowMalformed: true)
            : typeMap[to]!.decode(byte);
        return result;
      } catch (e) {
        return e.toString();
      }
    }

    jsQueryXPath(args) {
      final content = args[0];
      final selector = args[1];
      final fun = args[2];

      final xpath = HtmlXPath.html(content);
      final result = xpath.queryXPath(selector);
      String returnVal = '';
      switch (fun) {
        case 'attr':
          returnVal = result.attr ?? '';
        case 'attrs':
          returnVal = jsonEncode(result.attrs);
        case 'text':
          returnVal = result.node?.text ?? '';
        case 'allHTML':
          returnVal = result.nodes
              .map((e) => (e.node as Element).outerHtml)
              .toList()
              .toString();
        case 'outerHTML':
          returnVal = (result.node?.node as Element).outerHtml;
        default:
          returnVal = result.node?.text ?? "";
      }
      return returnVal;
    }

    runtime.onMessage('getSetting', (dynamic args) => jsGetMessage(args));
    // 日志
    runtime.onMessage('log', (args) => jsLog(args));
    // 请求
    runtime.onMessage('request', (args) => jsRequest(args));
    // 设置
    runtime.onMessage('registerSetting', (args) => jsRegisterSetting(args));
    // 清理扩展设置
    runtime.onMessage('cleanSettings', (dynamic args) => jsCleanSettings(args));
    // xpath 选择器
    runtime.onMessage('queryXPath', (arg) => jsQueryXPath(arg));
    runtime.onMessage('saveData', (args) => jsSaveData(args));
    runtime.onMessage('getData', (args) => jsGetData(args));
    runtime.onMessage('snackbar', (args) => jsSnackBar(args));
    runtime.onMessage('rawRequest', (args) => jsRawRequest(args));
    runtime.onMessage('listCookies', (_) async {
      return await listCookie();
    });
    runtime.onMessage('setCookie', (cookie) async {
      try {
        await setCookie(cookie[0]);
        return true;
      } catch (e) {
        return false;
      }
    });
    // 数据转换 utf8 base64 ascii latin1
    runtime.onMessage('convert', (args) => jsConvert(args));
    if (Platform.isLinux) {
      handleDartBridge(String channelName, Function fn) {
        jsBridge.setHandler(channelName, (message) async {
          final args = jsonDecode(message);
          final result = await fn(args);
          await jsBridge.sendMessage(channelName, result);
        });
      }

      jsBridge = JsBridge(jsRuntime: runtime);
      handleDartBridge('cleanSettings$className', jsCleanSettings);
      handleDartBridge('request$className', jsRequest);
      handleDartBridge('log$className', jsLog);
      handleDartBridge('queryXPath$className', jsQueryXPath);
      handleDartBridge('registerSetting$className', jsRegisterSetting);
      handleDartBridge('getSetting$className', jsGetMessage);
      handleDartBridge('saveData$className', jsSaveData);
      handleDartBridge('getData$className', jsGetData);
      handleDartBridge('snackbar$className', jsSnackBar);
      handleDartBridge('rawRequest$className', jsRawRequest);
      handleDartBridge('convert$className', jsConvert);
      jsBridge.setHandler('listCookies$className', (message) async {
        final result = await listCookie();
        await jsBridge.sendMessage('listCookies$className', result);
      });
      jsBridge.setHandler('setCookie$className', (message) async {
        try {
          await setCookie(message);
          await jsBridge.sendMessage('setCookie$className', true);
        } catch (e) {
          await jsBridge.sendMessage('setCookie$className', false);
        }
      });
      // handleDartBridge('setCookie$className', setCookie);
    }
  }

  @override
  initRunExtension(String extScript) async {
    final cryptoJs = await rootBundle.loadString('assets/js/CryptoJS.min.js');
    final jsencrypt = await rootBundle.loadString('assets/js/jsencrypt.min.js');
    final md5 = await rootBundle.loadString('assets/js/md5.min.js');
    final dom = await rootBundle.loadString('assets/js/worker.js');
    runtime.evaluate(dom);
    final ext = Platform.isLinux
        ? '''
class XPathNode {
  constructor(content, selector) {
    this.content = content;
    this.selector = selector;
  }

  async excute(fun) {
    return await handlePromise("queryXPath$className", JSON.stringify([this.content, this.selector, fun]));
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

// 重写 console.log
console.log = function (message) {
  if (typeof message === "object") {
    message = JSON.stringify(message);
  }
  DartBridge.sendMessage("log$className", JSON.stringify([message.toString()]));
};

const package = "${extension.package}";
const name = "${extension.name}";
// 在 load 中注册的 keys
const settingKeys = [];



const Miru = {
  request: async (url, options) => {
    options = options || {};
    options.headers = options.headers || {};
    const miruUrl = options.headers["Miru-Url"] || "${extension.webSite}";
    options.method = options.method || "get";
    // 確定是否使用 responseType.byte 來解碼
    const useByteToDecode = options.useByteToDecode|| false;
    const message = await handlePromise("request$className", JSON.stringify([miruUrl + url, options, useByteToDecode]));
    try {
      return JSON.parse(message);
    } catch (e) {
      return message;
    }
  },
  rawRequest: async (url, options) => {
    options = options || {};
    options.headers = options.headers || {};
    options.method = options.method || "get";
    const message = await handlePromise("rawRequest$className", JSON.stringify([url, options, "${extension.package}"]));
    try {
      return JSON.parse(message);
    } catch (e) {
      return message;
    }
  },
  listCookies: async () => {
    return await handlePromise("listCookies$className", "");
  },
  setCookie: async (cookie) => {
    return await handlePromise("setCookie$className", cookie);
  },
  saveData: async (key, data) => {
    try { await handlePromise("saveData$className", JSON.stringify([key, data])); return true; } catch (e) { return false; }
  },
  snackbar: (message) => {
    return handlePromise("snackbar$className", JSON.stringify([message]));
  },
  getData: async (key) => {
    return await handlePromise("getData$className", JSON.stringify([key]));
  },
  queryXPath: (content, selector) => {
    return new XPathNode(content, selector);
  },
  registerSetting: async (settings) => {
    console.log(JSON.stringify([settings]));
    settingKeys.push(settings.key);
    return await handlePromise("registerSetting$className", JSON.stringify([settings]));
  },
  getSetting: async (key) => {
    return await handlePromise("getSetting$className", JSON.stringify([key]));
  },
  convert:async (data,from,to)=>{
    return await handlePromise("convert$className",JSON.stringify([JSON.stringify(data),from,to]));
  }
}
var latest = () => {
  throw new Error("not implement latest");
}
var search = () => {
  throw new Error("not implement search");
}
var createFilter = () => {
  throw new Error("not implement createFilter");
}
var detail = () => {
  throw new Error("not implement detail");
}
var watch = () => {
  throw new Error("not implement watch");
}
var checkUpdate = () => {
  throw new Error("not implement checkUpdate");
}


async function load() { }

const handlePromise = async (channelName, message) => {
  const waitForChange = new Promise(resolve => {
    DartBridge.setHandler(channelName, async (arg) => {
      resolve(arg);
    })
  });
  DartBridge.sendMessage(channelName, message);
  return await waitForChange
}
const stringify = async (callback) => {
  const data = await callback();
  return typeof data === "object" ? JSON.stringify(data, 0, 2) : data;
}

'''
        : '''
var window = (global = globalThis);
$cryptoJs
$jsencrypt
$md5

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

// 重写 console.log
console.log = function (message) {
    if (typeof message === "object") {
        message = JSON.stringify(message);
    }
    sendMessage("log", JSON.stringify([message.toString()]));
};

const package = "${extension.package}";
const name = "${extension.name}";
// 在 load 中注册的 keys
const settingKeys = [];

const Miru = {
    request: async (url, options) => {
        options = options || {};
        options.headers = options.headers || {};
        const miruUrl = options.headers["Miru-Url"] || "${extension.webSite}";
        const useByteToDecode = options.useByteToDecode|| false;
        options.method = options.method || "get";
        const res = await sendMessage(
            "request",
            JSON.stringify([miruUrl + url, options,useByteToDecode])
        );
        try {
            return JSON.parse(res);
        } catch (e) {
            return res;
        }

    },
    rawRequest: async (url, options) => {
        options = options || {};
        options.headers = options.headers || {};
        options.method = options.method || "get";
         // 確定是否使用 responseType.byte 來解碼
        const useByteToDecode = options.useByteToDecode || false;
        const message = await sendMessage("rawRequest", JSON.stringify([url, options,useByteToDecode]));
        try {
            return JSON.parse(message);
        } catch (e) {
            return message;
        }
    },
    listCookies: async () => {
        return await sendMessage("listCookies", JSON.stringify([]));
    },
    setCookie: async (cookie) => {
        return await sendMessage("setCookie", JSON.stringify([cookie]));
    },
    saveData: async (key, data) => {
        try { await sendMessage("saveData", JSON.stringify([key, data])); return true; } catch (e) { return false; }
    },
    snackbar: (message) => {
        return sendMessage("snackbar", JSON.stringify([message]));
    },
    getData: async (key) => {
        return await sendMessage("getData", JSON.stringify([key]));
    },
    queryXPath: (content, selector) => {
        return new XPathNode(content, selector);
    },
    getSetting: async (key) => {
        return sendMessage("getSetting", JSON.stringify([key]));
    },
    registerSetting: async (settings) => {
        console.log(JSON.stringify([settings]));
        settingKeys.push(settings.key);
        return sendMessage("registerSetting", JSON.stringify([settings]));
    },
    convert: async (data, from, to) => {
        return await sendMessage("convert", JSON.stringify([JSON.stringify(data), from, to]));
    }
}
var latest = () => {
    throw new Error("not implement latest");
}
var search = () => {
    throw new Error("not implement search");
}
var createFilter = () => {
    throw new Error("not implement createFilter");
}
var detail = () => {
    throw new Error("not implement detail");
}
var watch = () => {
    throw new Error("not implement watch");
}
var checkUpdate = () => {
    throw new Error("not implement checkUpdate");
}
async function load() { }


const stringify = async (callback) => {
    const data = await callback();
    return typeof data === "object" ? JSON.stringify(data, 0, 2) : data;
}
    ''';
    runtime.evaluate('''
      $ext
      $extScript
      load().then(()=>
        {
          if (${Platform.isLinux}) {
              DartBridge.sendMessage("cleanSettings$className", JSON.stringify([settingKeys]));
          } else {
              sendMessage("cleanSettings", JSON.stringify([settingKeys]))
          }
      }
);
    ''');
  }

  @override
  Future<List<ExtensionListItem>> latest(
      int page, material.BuildContext context) async {
    currentcontext = context;
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync(Platform.isLinux
            ? 'latest($page)'
            : 'stringify(()=>latest($page))'),
      );

      List<ExtensionListItem> result =
          jsonDecode(jsResult.stringResult).map<ExtensionListItem>((e) {
        return ExtensionListItem.fromJson(e);
      }).toList();
      for (var element in result) {
        element.headers ??= await defaultHeaders;
      }
      return result;
    });
  }

  @override
  Future<List<ExtensionListItem>> search(
    String kw,
    int page,
    material.BuildContext context, {
    Map<String, List<String>>? filter,
  }) async {
    currentcontext = context;
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync(Platform.isLinux
            ? 'search("$kw",$page,${filter == null ? null : jsonEncode(filter)})'
            : 'stringify(()=>search("$kw",$page,${filter == null ? null : jsonEncode(filter)}))'),
      );
      List<ExtensionListItem> result =
          jsonDecode(jsResult.stringResult).map<ExtensionListItem>((e) {
        return ExtensionListItem.fromJson(e);
      }).toList();
      for (var element in result) {
        element.headers ??= await defaultHeaders;
      }
      return result;
    });
  }

  @override
  Future<Map<String, ExtensionFilter>> createFilter({
    Map<String, List<String>>? filter,
  }) async {
    late String eval;
    if (filter == null) {
      eval =
          Platform.isLinux ? 'createFilter()' : 'stringify(()=>createFilter())';
    } else {
      eval = Platform.isLinux
          ? 'createFilter(JSON.parse(\'${jsonEncode(filter)}\'))'
          : 'stringify(()=>$createFilter(JSON.parse(\'${jsonEncode(filter)}\')))';
    }
    return runExtension(() async {
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

  Future<List<ReconstructPicVertex>> recompseImage(
      int width, int height, int imageIndex) {
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync(Platform.isLinux
            ? 'recomposeImage($width,$height,$imageIndex)'
            : 'stringify(()=>recomposeImage($width,$height,$imageIndex))'),
      );
      final List<ReconstructPicVertex> result = (jsonDecode(
              jsResult.stringResult) as List<dynamic>)
          .map((e) => ReconstructPicVertex.fromJson(e as Map<String, dynamic>))
          .toList();
      return result;
    });
  }

  @override
  Future<ExtensionDetail> detail(
      String url, material.BuildContext context) async {
    currentcontext = context;
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync(Platform.isLinux
            ? 'detail("$url")'
            : 'stringify(()=>detail("$url"))'),
      );
      final result =
          ExtensionDetail.fromJson(jsonDecode(jsResult.stringResult));
      result.headers ??= await defaultHeaders;
      return result;
    });
  }

  @override
  Future<Object?> watch(String url, material.BuildContext context) async {
    currentcontext = context;
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync(Platform.isLinux
            ? 'watch("$url")'
            : 'stringify(()=>watch("$url"))'),
      );
      final data = jsonDecode(jsResult.stringResult);

      switch (extension.type) {
        case ExtensionType.bangumi:
          final result = ExtensionBangumiWatch.fromJson(data);
          result.headers ??= await defaultHeaders;
          return result;
        case ExtensionType.manga:
          final result = ExtensionMangaWatch.fromJson(data);
          result.headers ??= await defaultHeaders;
          return result;
        default:
          return ExtensionFikushonWatch.fromJson(data);
      }
    });
  }

  @override
  Future<String> checkUpdate(url) async {
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(await runtime.evaluateAsync(
        Platform.isLinux
            ? 'checkUpdate("$url")'
            : 'stringify(()=>checkUpdate("$url"))',
      ));
      return jsResult.stringResult;
    });
  }

  @override
  Future<Map<String, String>> get defaultHeaders async {
    return {
      "Referer": _cuurentRequestUrl,
      "User-Agent": MiruStorage.getUASetting(),
      "Cookie": await listCookie(),
    };
  }
}
