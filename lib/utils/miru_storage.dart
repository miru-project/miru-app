import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:isar/isar.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/miru_directory.dart';
import 'package:path/path.dart' as p;

class MiruStorage {
  static late final Isar database;
  static late final Box settings;
  static const int _lastDatabaseVersion = 2;
  static late String _path;

  static ensureInitialized() async {
    _path = MiruDirectory.getDirectory;
    // 初始化设置
    await Hive.initFlutter(_path);
    settings = await Hive.openBox("settings");
    await _initSettings();

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
      directory: _path,
    );

    // 数据库升级
    await performMigrationIfNeeded();
  }

  static performMigrationIfNeeded() async {
    final currentVersion = await getDatabaseVersion();
    debugPrint(currentVersion.toString());
    switch (currentVersion) {
      case 1:
        await migrateV1ToV2();
        break;
      case 2:
        return;
      default:
        throw Exception('Unknown version: $currentVersion');
    }

    // 更新到最新版本
    await settings.put(SettingKey.databaseVersion, _lastDatabaseVersion);
  }

  static migrateV1ToV2() async {
    // 获取所有的 TMDB 数据
    final tmdbList = await database.tMDBs.where().findAll();
    database.writeTxn(() async {
      // 给所有的 TMDB 数据添加 mediaType 字段
      for (final tmdb in tmdbList) {
        final tmdbdetail = TMDBDetail.fromJson(jsonDecode(tmdb.data));
        tmdb.mediaType = tmdbdetail.mediaType;
        await database.tMDBs.put(tmdb);
      }
    });

    // 修改所有 miruDetail 的 tmdbId 字段为本地的 TMDB id
    final miruList = await database.miruDetails.where().findAll();
    database.writeTxn(() async {
      for (final miru in miruList) {
        final tmdb = await database.tMDBs
            .where()
            .filter()
            .tmdbIDEqualTo(miru.tmdbID!)
            .findFirst();
        if (tmdb != null) {
          miru.tmdbID = tmdb.id;
          await database.miruDetails.put(miru);
        }
      }
    });
  }

  // 获取数据库版本
  static Future<int> getDatabaseVersion() async {
    // 先获取数据库版本
    final version = await settings.get(SettingKey.databaseVersion);
    // 如果没有版本号，并且没有数据库文件说明是第一次使用，返回最新的数据库版本
    if (version == null) {
      final path = MiruDirectory.getDirectory;
      final dbPath = p.join(path, 'default.isar');
      if (File(dbPath).existsSync()) {
        return 1;
      }
      // 设置数据库版本并返回最新版本
      await settings.put(SettingKey.databaseVersion, _lastDatabaseVersion);
      return _lastDatabaseVersion;
    }
    // 如果有版本号，返回版本号
    return version;
  }

  static _initSettings() async {
    await _initSetting(SettingKey.miruRepoUrl, "https://miru-repo.0n0.dev");
    await _initSetting(SettingKey.tmdbKey, "");
    await _initSetting(SettingKey.autoCheckUpdate, true);
    await _initSetting(SettingKey.language, 'en');
    await _initSetting(SettingKey.novelFontSize, 18.0);
    await _initSetting(SettingKey.theme, 'system');
    await _initSetting(SettingKey.enableNSFW, false);
    await _initSetting(SettingKey.videoPlayer, 'built-in');
    await _initSetting(SettingKey.listMode, "grid");
    await _initSetting(SettingKey.keyI, 10.0);
    await _initSetting(SettingKey.keyJ, -10.0);
    await _initSetting(SettingKey.arrowLeft, -2.0);
    await _initSetting(SettingKey.arrowRight, 2.0);
    await _initSetting(SettingKey.readingMode, "standard");
    await _initSetting(SettingKey.aniListToken, '');
    await _initSetting(SettingKey.aniListUserId, '');
    await _initSetting(SettingKey.autoTracking, true);
    await _initSetting(SettingKey.windowSize, "1280,720");
    await _initSetting(SettingKey.androidWebviewUA,
        "Mozilla/5.0 (Linux; Android 13; Android) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.43 Mobile Safari/537.36");
    await _initSetting(SettingKey.windowsWebviewUA,
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0");
    await _initSetting(SettingKey.proxy, '');
    await _initSetting(SettingKey.proxyType, 'DIRECT');
    await _initSetting(SettingKey.saveLog, true);
    await _initSetting(SettingKey.subtitleFontSize, 46.0);
    await _initSetting(SettingKey.subtitleFontColor, Colors.white.value);
    await _initSetting(SettingKey.subtitleFontWeight, 'bold');
    await _initSetting(SettingKey.subtitleBackgroundColor, Colors.black.value);
    await _initSetting(SettingKey.subtitleBackgroundOpacity, 0.5);
    await _initSetting(SettingKey.subtitleTextAlign, TextAlign.center.index);
    await _initSetting(SettingKey.extensionData, {});
  }

  static _initSetting(String key, dynamic value) async {
    if (!settings.containsKey(key)) {
      await settings.put(key, value);
    }
  }

  static setSetting(String key, dynamic value) async {
    await settings.put(key, value);
  }

  static setExtensionData(String packageName, String key, dynamic value) async {
    final data = settings.get(SettingKey.extensionData);
    data[packageName] ??= {};
    data[packageName][key] = value;
    await settings.put(SettingKey.extensionData, data);
  }

  static getExtensionData(String packageName, String key) {
    final data = settings.get(SettingKey.extensionData);
    return data[packageName][key];
  }

  static getSetting(String key) {
    return settings.get(key);
  }

  static getUASetting() {
    if (Platform.isAndroid) {
      return settings.get(SettingKey.androidWebviewUA);
    }
    return settings.get(SettingKey.windowsWebviewUA);
  }

  static setUASetting(String value) async {
    if (Platform.isAndroid) {
      setSetting(SettingKey.androidWebviewUA, value);
    } else {
      setSetting(SettingKey.windowsWebviewUA, value);
    }
  }
}

class SettingKey {
  static const theme = "Theme";
  static const miruRepoUrl = "MiruRepoUrl";
  static const tmdbKey = 'TMDBKey';
  static const autoCheckUpdate = 'AutoCheckUpdate';
  static const language = 'Language';
  static const novelFontSize = 'NovelFontSize';
  static const enableNSFW = 'EnableNSFW';
  static const videoPlayer = 'VideoPlayer';
  static const databaseVersion = 'DatabaseVersion';
  static const listMode = 'ListMode';
  static const keyI = 'KeyI';
  static const keyJ = 'KeyJ';
  static const arrowLeft = 'Arrowleft';
  static const arrowRight = 'Arrowright';
  static const readingMode = 'ReadingMode';
  static const aniListToken = 'AniListToken';
  static const aniListUserId = 'AniListUserId';
  static const autoTracking = 'AutoTracking';
  static const windowSize = 'WindowsSize';
  static const windowPosition = 'WindowsPosition';
  static const androidWebviewUA = "AndroidWebviewUA";
  static const windowsWebviewUA = "WindowsWebviewUA";
  static const proxy = "Proxy";
  static const proxyType = "ProxyType";
  static const saveLog = "SaveLog";
  static const subtitleFontSize = "SubtitleFontSize";
  static const subtitleFontWeight = "SubtitleFontWeight";
  static const subtitleFontColor = "SubtitleFontColor";
  static const subtitleBackgroundColor = "SubtitleBackgroundColor";
  static const subtitleBackgroundOpacity = "SubtitleBackgroundOpacity";
  static const subtitleTextAlign = "SubtitleTextAlign";
  static const subtitleLastLanguageSelected = "SubtitleLastLanguageSelected";
  static const subtitleLastTitleSelected = "SubtitleLastTitleSelected";
  static const extensionData = "ExtensionData";
}
