import 'package:hive_flutter/adapters.dart';
import 'package:isar/isar.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/miru_directory.dart';

class MiruStorage {
  static late final Isar database;
  static late final Box settings;

  static ensureInitialized() async {
    final path = await MiruDirectory.getDirectory;
    // 初始化数据库
    database = await Isar.open(
      [
        FavoriteSchema,
        HistorySchema,
        ExtensionSettingSchema,
        MangaSettingSchema,
        MiruDetailSchema,
        TMDBSchema,
      ],
      directory: path,
    );
    // 初始化设置
    await Hive.initFlutter(path);
    settings = await Hive.openBox("settings");
    await _initSettings();
  }

  static _initSettings() async {
    await _initSetting(SettingKey.miruRepoUrl, "https://miru-repo.0n0.dev");
    await _initSetting(SettingKey.tmdbKay, "");
    await _initSetting(SettingKey.autoCheckUpdate, true);
    await _initSetting(SettingKey.language, 'en');
    await _initSetting(SettingKey.novelFontSize, 18.0);
  }

  static _initSetting(String key, dynamic value) async {
    if (!settings.containsKey(key)) {
      await settings.put(key, value);
    }
  }

  static setSetting(String key, dynamic value) async {
    await settings.put(key, value);
  }

  static getSetting(String key) {
    return settings.get(key);
  }
}

class SettingKey {
  static String miruRepoUrl = "MiruRepoUrl";
  static String tmdbKay = 'TMDBKey';
  static String autoCheckUpdate = 'AutoCheckUpdate';
  static String language = 'Language';
  static String novelFontSize = 'NovelFontSize';
}
