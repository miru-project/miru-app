import 'dart:convert';
import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:miru_app/pages/detail/view.dart';
import 'package:miru_app/pages/extension/view.dart';
import 'package:miru_app/pages/extension_log/view.dart';
import 'package:miru_app/pages/extension_repo/view.dart';
import 'package:miru_app/pages/home/view.dart';
import 'package:miru_app/pages/main/view.dart';
import 'package:miru_app/pages/search/view.dart';
import 'package:miru_app/pages/settings/view.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/package_info.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await ExtensionUtils.ensureInitialized();
  await PackageInfoUtil.ensureInitialized();
  MediaKit.ensureInitialized();

  if (!Platform.isAndroid) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(1280, 720),
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
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Widget _buildMobileMain(BuildContext context) {
    return GetMaterialApp(
      title: "Miru",
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(useMaterial3: true),
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
      themeMode: ThemeMode.system,
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

_animation(Widget child) {
  return Animate(
    child: child,
  ).moveY(
    begin: 40,
    end: 0,
    curve: Curves.easeOutCubic,
  );
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return DesktopMainPage(
          shellContext: _shellNavigatorKey.currentContext,
          state: state,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => _animation(const HomePage()),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => _animation(const SearchPage()),
        ),
        GoRoute(
          path: '/extension',
          builder: (context, state) => _animation(const ExtensionPage()),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => _animation(const SettingsPage()),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => _animation(const SettingsPage()),
        ),
        GoRoute(
          path: '/extension_repo',
          builder: (context, state) => _animation(const ExtensionRepoPage()),
        ),
        GoRoute(
          path: '/detail',
          builder: (context, state) => _animation(
            DetailPage(
              url: state.queryParameters['url']!,
              package: state.queryParameters['package']!,
            ),
          ),
        ),
      ],
    )
  ],
);
