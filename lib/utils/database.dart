import 'package:isar/isar.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/favorite.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/miru_storage.dart';

class DatabaseUtils {
  static final db = MiruStorage.database;

  static toggleFavorite({
    required String package,
    required String url,
    required String cover,
    required String name,
  }) async {
    final ext = ExtensionUtils.extensions[package];
    if (ext == null) {
      throw Exception('extension not found');
    }
    final extension = ext.extension;
    return db.writeTxn(() async {
      if (await isFavorite(
        package: extension.package,
        url: url,
      )) {
        return db.favorites
            .filter()
            .packageEqualTo(extension.package)
            .and()
            .urlEqualTo(url)
            .deleteAll();
      } else {
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

  static Future<List<Favorite>> getFavoritesByType(ExtensionType type) async {
    return db.favorites.filter().typeEqualTo(type).sortByDateDesc().findAll();
  }

  // 历史记录

  static Future<List<History>> getHistorysByType(ExtensionType type) async {
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
    final hst = await getHistoryByPackageAndUrl(history.package, history.url);
    if (hst != null) {
      hst
        ..date = DateTime.now()
        ..cover = history.cover
        ..title = history.title
        ..episodeGroupId = history.episodeGroupId
        ..episodeId = history.episodeId
        ..episodeTitle = history.episodeTitle;
      return db.writeTxn(() => db.historys.put(hst));
    }

    return db.writeTxn(() => db.historys.put(history));
  }
}
