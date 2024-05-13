import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:get/get.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/miru_storage.dart';

final _context =
    (Platform.isAndroid || Platform.isIOS) ? Get.context! : rootNavigatorKey.currentContext!;

class I18nUtils {
  static final flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: false,
      fallbackFile: 'en',
      basePath: 'assets/i18n',
      forcedLocale: Locale(MiruStorage.getSetting(SettingKey.language)),
      decodeStrategies: [JsonDecodeStrategy()],
    ),
  );

// 获取当前语言
  static Locale? get currentLanguage => FlutterI18n.currentLocale(_context);

// 切换语言
  static Future changeLanguage(String locale) async {
    await FlutterI18n.refresh(_context, Locale(locale));
    await Get.forceAppUpdate();
  }
}

extension I18nString on String {
  String get i18n => FlutterI18n.translate(_context, this);
}
