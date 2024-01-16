import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/views/widgets/debug/extension_log_tile.dart';
import 'package:highlight/languages/json.dart';

// 待执行的方法
final List<Map<String, dynamic>> _methodList = [];
// 执行结果 key 和 completer
final Map<String, Completer> _resultMap = {};

// 调用方法 往方法列表里添加方法
Future<dynamic> callMethod(String method, [dynamic arguments]) async {
  final key = UniqueKey().toString();
  _methodList.add({
    "key": key,
    "method": method,
    "arguments": arguments,
  });
  // 等待结果
  final completer = Completer();
  _resultMap[key] = completer;
  final result = await completer.future;
  _resultMap.remove(key);
  return result;
}

class ExtensionDebugWindow extends StatefulWidget {
  const ExtensionDebugWindow({
    super.key,
    required this.windowController,
  });
  final WindowController windowController;

  @override
  State<ExtensionDebugWindow> createState() => _ExtensionDebugWindowState();
}

class _ExtensionDebugWindowState extends State<ExtensionDebugWindow> {
  final List<ExtensionLog> _logs = [];
  final Map<String, ExtensionNetworkLog> _networkLogs = {};

  // tab 列表
  final List<String> _tabs = [
    "Log",
    "Network",
    "Debug",
  ];
  // 当前选中的 tab
  String _currentTab = "Log";

  // 扩展列表
  final List<Extension> _extensions = [];

  // 选择的扩展
  Extension? _selectedExtension;

  @override
  void initState() {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      if (call.method == "addLog") {
        final log = ExtensionLog.fromJson(jsonDecode(call.arguments));
        debugPrint(_selectedExtension.toString());
        if (_selectedExtension == null) {
          setState(() {
            _logs.add(log);
          });
          return null;
        }
        if (_selectedExtension!.package == log.extension.package) {
          setState(() {
            _logs.add(log);
          });
        }
      }

      if (call.method == "addNetworkLog") {
        final args = jsonDecode(call.arguments);
        final key = args["key"];
        final log = ExtensionNetworkLog.fromJson(args["log"]);
        if (_selectedExtension == null) {
          setState(() {
            _networkLogs[key] = log;
          });
          return null;
        }
        if (_selectedExtension!.package == log.extension.package) {
          setState(() {
            _networkLogs[key] = log;
          });
        }
      }

      if (call.method == "state") {
        return "yes";
      }
      // 主窗口轮询，返回方法列表里的方法
      if (call.method == "getMethods") {
        final methods = [..._methodList];
        _methodList.clear();
        return methods;
      }

      // 主窗口返回执行结果
      if (call.method == "result") {
        final arg = call.arguments;
        final key = arg["key"];
        final result = arg["result"];
        final completer = _resultMap[key];
        if (completer != null) {
          completer.complete(
            result,
          );
        }
      }
    });
    _getInstalledExtensions();
    super.initState();
  }

  // 获取已安装扩展列表
  _getInstalledExtensions() async {
    final extensions = await callMethod("getInstalledExtensions");
    debugPrint(extensions.toString());
    List<dynamic> list = List<dynamic>.from(extensions);
    final extList = list.map((e) => Map<String, dynamic>.from(e)).toList();
    setState(() {
      _extensions.clear();
      _extensions.addAll(
        extList.map((e) => Extension.fromJson(e)).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final views = [
      ConsoleView(
        logs: _logs,
        onClear: () {
          setState(() {
            _logs.clear();
          });
        },
      ),
      NetworkView(
        logs: _networkLogs,
        onClear: () {
          setState(() {
            _networkLogs.clear();
          });
        },
      ),
      DebugView(
        selectedExtension: _selectedExtension,
      ),
    ];

    return FluentApp(
      debugShowCheckedModeBanner: false,
      theme: FluentThemeData.dark(),
      home: Container(
        color: FluentThemeData.dark().acrylicBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var tab in _tabs)
                          ToggleButton(
                            checked: _currentTab == tab,
                            onChanged: (value) {
                              if (!value) {
                                return;
                              }
                              setState(() {
                                _currentTab = tab;
                              });
                            },
                            child: Text(tab),
                          ),
                      ],
                    ),
                  ),
                  // 获取扩展列表
                  Button(
                    onPressed: _getInstalledExtensions,
                    child: const Text("Refresh"),
                  ),
                  const SizedBox(width: 8),
                  // 选择扩展
                  ComboBox<Extension>(
                    onChanged: (value) {
                      setState(() {
                        _selectedExtension = value;
                      });
                    },
                    items: [
                      for (var ext in _extensions)
                        ComboBoxItem<Extension>(
                          value: ext,
                          child: Row(
                            children: [
                              Text(ext.name),
                              const SizedBox(width: 8),
                              Text(
                                ext.package,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                    ],
                    value: _selectedExtension,
                  ),
                  const SizedBox(width: 8),
                  // 清空选择
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedExtension = null;
                      });
                    },
                    icon: const Icon(
                      FluentIcons.clear,
                      size: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: IndexedStack(
                index: _tabs.indexOf(_currentTab),
                children: views,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsoleView extends StatefulWidget {
  const ConsoleView({
    super.key,
    required this.logs,
    this.onClear,
  });
  final List<ExtensionLog> logs;
  final VoidCallback? onClear;

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<ConsoleView> {
  final ScrollController _controller = ScrollController();

  List<ExtensionLog> get logs => widget.logs;
  // 是否滚动到底部
  bool _isScrollToBottom = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(covariant ConsoleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!_isScrollToBottom) {
        return;
      }
      scrollToBottom();
    });
  }

  // 滚动到底部
  void scrollToBottom() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Text("No log"),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                onPressed: widget.onClear,
                child: const Text("Clear"),
              ),
              const SizedBox(width: 8),
              // 自动滚动到底部
              ToggleButton(
                checked: _isScrollToBottom,
                onChanged: (value) {
                  setState(() {
                    _isScrollToBottom = value;
                  });
                },
                child: const Text("Auto Scroll"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            controller: _controller,
            padding: const EdgeInsets.all(10),
            children: [
              for (var log in logs) ExtensionLogTile(log: log),
            ],
          ),
        )
      ],
    );
  }
}

class NetworkView extends StatefulWidget {
  const NetworkView({
    super.key,
    required this.logs,
    required this.onClear,
  });
  final Map<String, ExtensionNetworkLog> logs;
  final VoidCallback? onClear;

  @override
  State<NetworkView> createState() => _NetworkViewState();
}

class _NetworkViewState extends State<NetworkView> {
  String _selectLogKey = "";
  ExtensionNetworkLog? get _selectLog => widget.logs[_selectLogKey];

  @override
  Widget build(BuildContext context) {
    if (widget.logs.isEmpty) {
      return const Center(
        child: Text("No log"),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                onPressed: widget.onClear,
                child: const Text("Clear"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    for (var log in widget.logs.entries)
                      ListTile.selectable(
                        selectionMode: ListTileSelectionMode.none,
                        subtitle: Text(
                          log.value.url,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: _selectLogKey == log.key,
                        title: Text(
                          log.value.url.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_selectLogKey == log.key) {
                              _selectLogKey = "";
                              return;
                            }
                            _selectLogKey = log.key;
                          });
                        },
                      ),
                  ],
                ),
              ),
              if (_selectLogKey.isNotEmpty && _selectLog != null)
                Expanded(
                  flex: 2,
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text("URL"),
                        subtitle: SelectableText(
                          _selectLog!.url,
                        ),
                      ),
                      ListTile(
                        title: const Text("Method"),
                        subtitle: SelectableText(
                          _selectLog!.method,
                        ),
                      ),
                      ListTile(
                        title: const Text("Status Code"),
                        subtitle: SelectableText(
                          _selectLog!.statusCode.toString(),
                        ),
                      ),
                      if (_selectLog!.requestHeaders != null)
                        ListTile(
                          title: const Text("Request Headers"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var header
                                  in _selectLog!.requestHeaders!.entries)
                                SelectableText(
                                  "${header.key}: ${header.value}",
                                ),
                            ],
                          ),
                        ),
                      ListTile(
                        title: const Text("Request Body"),
                        subtitle: SelectableText(
                          _selectLog!.requestBody.toString(),
                        ),
                      ),
                      if (_selectLog!.responseHeaders != null)
                        ListTile(
                          title: const Text("Response Headers"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var header
                                  in _selectLog!.responseHeaders!.entries)
                                SelectableText(
                                  "${header.key}: ${header.value}",
                                ),
                            ],
                          ),
                        ),
                      ListTile(
                        title: const Text("Response Body"),
                        subtitle: TextBox(
                          readOnly: true,
                          maxLines: 100,
                          controller: TextEditingController(
                            text: _selectLog!.responseBody,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}

class DebugView extends StatefulWidget {
  const DebugView({
    super.key,
    required this.selectedExtension,
  });
  final Extension? selectedExtension;

  @override
  State<DebugView> createState() => _DebugViewState();
}

class _DebugViewState extends State<DebugView> {
  // 方法列表
  final Map<String, String> _methods = {
    "latest(page: number)": "Get latest data form search page",
    "search(keyword: string, page: number, filter: map)":
        "Search data by keyword",
    "detail(url: string)": "Get detail data by url",
    "createFilter(filter: map)": "Create filter by url",
    "watch(url: string)": "Watch data by url",
  };

  final _controller = TextEditingController();

  final _resultController = CodeController(
    language: json,
  );

  // 是否等待接收数据
  bool _isLoading = false;

  // 执行方法
  void execute() async {
    _isLoading = true;
    final method = _controller.text;
    if (method.isEmpty) {
      return;
    }
    final result = await callMethod("debugExecute", {
      "method": method,
      "package": widget.selectedExtension!.package,
    });
    debugPrint(result.toString());
    _resultController.text = result.toString();
    _isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedExtension == null) {
      return const Center(
        child: Text("No extension selected, please select an extension first"),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ListView(
            children: [
              for (var method in _methods.entries)
                ListTile.selectable(
                  title: Text(
                    method.key,
                  ),
                  subtitle: Text(method.value),
                  onSelectionChange: (value) {
                    if (!value) {
                      return;
                    }
                    setState(() {
                      _controller.text = 'extension.${method.key}';
                    });
                  },
                )
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextBox(
                        placeholder: "call method",
                        controller: _controller,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Button(
                      onPressed: _isLoading
                          ? null
                          : () {
                              execute();
                            },
                      child: const Text("Execute"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Result"),
                const SizedBox(height: 10),
                Expanded(
                  child: material.MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: material.Scaffold(
                      backgroundColor: Colors.transparent,
                      body: CodeTheme(
                        data: CodeThemeData(
                          styles: monokaiSublimeTheme,
                        ),
                        child: SingleChildScrollView(
                          child: CodeField(
                            controller: _resultController,
                            textStyle: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
