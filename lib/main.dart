import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:miru_app/controllers/application_controller.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:miru_app/utils/request.dart';
import 'package:miru_app/views/pages/debug_page.dart';
import 'package:miru_app/views/pages/main_page.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/application.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 多窗口
    if (args.firstOrNull == 'multi_window') {
      final windowId = int.parse(args[1]);
      final arguments = args[2].isEmpty
          ? const {}
          : jsonDecode(args[2]) as Map<String, dynamic>;

      Map windows = {
        "debug": ExtensionDebugWindow(
          windowController: WindowController.fromWindowId(windowId),
        ),
      };
      runApp(windows[arguments["name"]]);
      return;
    }

    // 主窗口
    await MiruDirectory.ensureInitialized();
    await MiruStorage.ensureInitialized();
    await ApplicationUtils.ensureInitialized();
    await MiruRequest.ensureInitialized();
    ExtensionUtils.ensureInitialized();
    MediaKit.ensureInitialized();

    // 主窗口
    await MiruStorage.ensureInitialized();
    await ApplicationUtils.ensureInitialized();
    ExtensionUtils.ensureInitialized();
    MediaKit.ensureInitialized();
    final errorLog = MiruStorage.getSetting(SettingKey.errorMessage);
    final removeDate = MiruStorage.getSetting(SettingKey.logRemoveDateDiff);
    //remove after 7 days
    errorLog.removeWhere((log) {
      return DateTime.now().difference(log['time']).inDays > removeDate;
    });
    //Error handler
    FlutterError.onError = (details) {
      if (details.stack == null) {
        _onError(details.context.toString(), StackTrace.current.toString(),
            details.exceptionAsString());
      } else {
        _onError(details.context.toString(), details.stack.toString(),
            details.exceptionAsString());
      }
    };
    if (!Platform.isAndroid) {
      await windowManager.ensureInitialized();
      final sizeArr = MiruStorage.getSetting(SettingKey.windowSize).split(",");
      final size = Size(double.parse(sizeArr[0]), double.parse(sizeArr[1]));
      WindowOptions windowOptions = WindowOptions(
        size: size,
        center: true,
        minimumSize: const Size(600, 500),
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        final position = MiruStorage.getSetting(SettingKey.windowPosition);
        if (position != null) {
          final offsetArr = position.split(",");
          final offset = Offset(
            double.parse(offsetArr[0]),
            double.parse(offsetArr[1]),
          );
          await windowManager.setPosition(
            offset,
          );
        }
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
  }, (error, stack) {
    debugPrint("error logging \r\n");
    debugPrint(error.toString());
    debugPrint(stack.toString());
    _onError(error.toString(), stack.toString(), "");
  });
}

_onError(String errorContext, String stackTrace, String exception) {
  debugPrint("error logging \r\n");
  debugPrint(errorContext.toString());
  debugPrint(exception.toString());
  debugPrint(stackTrace.toString());
  final List errorlog = MiruStorage.getSetting(SettingKey.errorMessage);
  errorlog.add({
    "context": errorContext,
    "exception": exception,
    "stackTrace": stackTrace,
    "time": DateTime.now(),
  });
  MiruStorage.setSetting(SettingKey.errorMessage, errorlog);
  // showDialog(context: context, builder: builder)
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
