import 'dart:convert';
import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:miru_app/controllers/application_controller.dart';
import 'package:miru_app/views/pages/log_page.dart';
import 'package:miru_app/views/pages/main_page.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/application.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:window_manager/window_manager.dart';
import 'package:miru_app/utils/anilist.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (runWebViewTitleBarWidget(args)) {
    return;
  }

  // 多窗口
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    Map windows = {
      "log": ExtensionLogWindow(
        windowController: WindowController.fromWindowId(windowId),
      ),
    };
    runApp(windows[arguments["name"]]);
    return;
  }

  // 主窗口
  await MiruStorage.ensureInitialized();
  await ApplicationUtils.ensureInitialized();
  ExtensionUtils.ensureInitialized();
  MediaKit.ensureInitialized();
  AniList.initToken();

  if (!Platform.isAndroid) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(600, 500),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    );
    SystemChrome.setSystemUIOverlayStyle(style);
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(const MainApp());
}

class MainApp extends fluent.StatefulWidget {
  const MainApp({super.key});

  @override
  fluent.State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends fluent.State<MainApp> {
  late ApplicationController c;

  @override
  void initState() {
    c = Get.put(ApplicationController());
    super.initState();
  }

  Widget _buildMobileMain(BuildContext context) {
    return GetMaterialApp(
      title: "Miru",
      debugShowCheckedModeBanner: false,
      themeMode: c.theme,
      theme: c.currentThemeData,
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const AndroidMainPage(),
      localizationsDelegates: [
        I18nUtils.flutterI18nDelegate,
      ],
    );
  }

  Widget _buildDesktopMain(BuildContext context) {
    return fluent.FluentApp.router(
      title: 'Miru',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: c.theme,
      darkTheme: fluent.FluentThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        fontFamily: "Microsoft Yahei",
      ),
      theme: fluent.FluentThemeData(
        visualDensity: VisualDensity.standard,
        fontFamily: "Microsoft Yahei",
      ),
      localizationsDelegates: [
        I18nUtils.flutterI18nDelegate,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildMobileMain,
      desktopBuilder: _buildDesktopMain,
    );
  }
}
