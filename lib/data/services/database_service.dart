import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:isar/isar.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/miru_storage.dart';

class DatabaseService {
  static final db = MiruStorage.database;

  static toggleFavorite({
    required String package,
    required String url,
    required String name,
    String? cover,
  }) async {
    return db.writeTxn(() async {
      if (await isFavorite(
        package: package,
        url: url,
      )) {
        return db.favorites
            .filter()
            .packageEqualTo(package)
            .and()
            .urlEqualTo(url)
            .deleteAll();
      } else {
        final runtime = ExtensionUtils.runtimes[package];
        if (runtime == null) {
          throw Exception('extension not found');
        }
        final extension = runtime.extension;
        return db.favorites.put(
          Favorite()
            ..cover = cover
            ..title = name
            ..package = extension.package
            ..type = extension.type
            ..url = url,
        );
      }
    });
  }

  static Future<bool> isFavorite({
    required String package,
    required String url,
  }) async {
    return (await db.favorites
            .filter()
            .packageEqualTo(package)
            .and()
            .urlEqualTo(url)
            .findFirst()) !=
        null;
  }

  static Future<List<Favorite>> getFavoritesByType({
    ExtensionType? type,
    int? limit,
  }) async {
    if (type == null) {
      final query = db.favorites.where().sortByDateDesc();
      if (limit != null) {
        return query.limit(limit).findAll();
      }
      return query.findAll();
    }
    final query = db.favorites.filter().typeEqualTo(type).sortByDateDesc();
    if (limit != null) {
      return query.limit(limit).findAll();
    }
    return query.findAll();
  }

  // 历史记录
  static Future<List<History>> getHistorysByType({ExtensionType? type}) async {
    if (type == null) {
      return db.historys.where().sortByDateDesc().findAll();
    }
    return db.historys.filter().typeEqualTo(type).sortByDateDesc().findAll();
  }

  static Future<History?> getHistoryByPackageAndUrl(
      String package, String url) async {
    return db.historys
        .filter()
        .packageEqualTo(package)
        .and()
        .urlEqualTo(url)
        .findFirst();
  }

  // 更新历史

  static Future<Id> putHistory(History history) async {
    // 判断是否存在，存在则更新
    // final hst = await getHistoryByPackageAndUrl(history.package, history.url);
    // if (hst != null) {
    //   hst
    //     ..date = DateTime.now()
    //     ..cover = history.cover
    //     ..title = history.title
    //     ..episodeGroupId = history.episodeGroupId
    //     ..episodeId = history.episodeId
    //     ..episodeTitle = history.episodeTitle
    //     ..progress = history.progress
    //     ..totalProgress = history.totalProgress;
    //   return db.writeTxn(() => db.historys.put(hst));
    // }

    return db.writeTxn(() => db.historys.putByIndex(r'package&url', history));
  }

  // 删除历史
  static Future<void> deleteHistoryByPackageAndUrl(
      String package, String url) async {
    return db.writeTxn(
      () => db.historys
          .filter()
          .packageEqualTo(package)
          .urlEqualTo(url)
          .deleteAll(),
    );
  }

  // 删除全部历史
  static Future<void> deleteAllHistory() async {
    return db.writeTxn(() => db.historys.where().deleteAll());
  }

  // 扩展设置
  // 获取扩展设置
  static Future<List<ExtensionSetting>> getExtensionSettings(String package) {
    return db.extensionSettings.filter().packageEqualTo(package).findAll();
  }

  // 更新扩展设置
  static Future<Id?> putExtensionSetting(
      String package, String key, String value) async {
    final extensionSetting = await getExtensionSetting(package, key);
    if (extensionSetting == null) {
      return null;
    }
    extensionSetting.value = value;
    debugPrint(extensionSetting.value);
    return db.writeTxn(() => db.extensionSettings.put(extensionSetting));
  }

  // 获取扩展设置
  static Future<ExtensionSetting?> getExtensionSetting(
      String package, String key) async {
    return db.extensionSettings
        .filter()
        .packageEqualTo(package)
        .and()
        .keyEqualTo(key)
        .findFirst();
  }

  // 添加扩展设置
  static Future<Id> registerExtensionSetting(
    ExtensionSetting extensionSetting,
  ) async {
    if (extensionSetting.type == ExtensionSettingType.radio &&
        extensionSetting.options == null) {
      throw Exception('options is null');
    }

    final extSetting = await getExtensionSetting(
        extensionSetting.package, extensionSetting.key);
    // 如果不存在相同设置，则添加
    if (extSetting == null) {
      return db.writeTxn(() => db.extensionSettings.put(extensionSetting));
    }

    extSetting.defaultValue = extensionSetting.defaultValue;

    // 如果类型不同，重置值
    if (extSetting.type != extensionSetting.type) {
      extSetting.type = extensionSetting.type;
      extSetting.value = extensionSetting.defaultValue;
    }
    extSetting.defaultValue = extensionSetting.defaultValue;
    extSetting.description = extensionSetting.description;
    extSetting.options = extensionSetting.options;
    extSetting.title = extensionSetting.title;

    return db.writeTxn(
      () => db.extensionSettings.putByIndex(r'package&key', extSetting),
    );
  }

  // 删除扩展设置
  static Future<void> deleteExtensionSetting(String package) async {
    return db.writeTxn(
      () => db.extensionSettings.filter().packageEqualTo(package).deleteAll(),
    );
  }

  // 清理不需要的扩展设置
  static Future<void> cleanExtensionSettings(
    String package,
    List<String> keys,
  ) async {
    // 需要删除的 id;
    final ids = <int>[];

    final extSettings =
        await db.extensionSettings.filter().packageEqualTo(package).findAll();

    for (final extSetting in extSettings) {
      if (!keys.contains(extSetting.key)) {
        ids.add(extSetting.id);
      }
    }

    return db.writeTxn(() => db.extensionSettings.deleteAll(ids));
  }

  // 获取漫画阅读模式
  static Future<MangaReadMode> getMnagaReaderType(
      String url, MangaReadMode defaultMode) {
    return db.mangaSettings.filter().urlEqualTo(url).findFirst().then(
          (value) => value?.readMode ?? defaultMode,
        );
  }

  // 设置漫画阅读模式
  static Future<Id> setMangaReaderType(
    String url,
    MangaReadMode readMode,
  ) {
    return db.writeTxn(
      () => db.mangaSettings.putByUrl(
        MangaSetting()
          ..url = url
          ..readMode = readMode,
      ),
    );
  }

  // 存储 MiruDetail
  static Future<Id> putMiruDetail(
    String package,
    String url,
    ExtensionDetail extensionDetail, {
    int? tmdbID,
  }) {
    return db.writeTxn(
      () => db.miruDetails.putByIndex(
        r'package&url',
        MiruDetail()
          ..data = jsonEncode(extensionDetail.toJson())
          ..package = package
          ..tmdbID = tmdbID
          ..url = url,
      ),
    );
  }

  // 获取 MiruDetail
  static Future<MiruDetail?> getMiruDetail(
    String package,
    String url,
  ) async {
    return await db.miruDetails
        .filter()
        .packageEqualTo(package)
        .and()
        .urlEqualTo(url)
        .findFirst();
  }

  // 更新 TMDB 数据
  static Future<Id> putTMDBDetail(
    int tmdbID,
    TMDBDetail tmdbDetail,
    String mediaType,
  ) {
    return db.writeTxn(
      () => db.tMDBs.putByTmdbID(
        TMDB()
          ..data = jsonEncode(tmdbDetail.toJson())
          ..tmdbID = tmdbID
          ..mediaType = mediaType,
      ),
    );
  }

  // 获取 TMDB 数据
  static Future<TMDBDetail?> getTMDBDetail(int tmdbID) async {
    final tmdb = await db.tMDBs.filter().idEqualTo(tmdbID).findFirst();
    if (tmdb == null) {
      return null;
    }
    try {
      return TMDBDetail.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(tmdb.data),
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
