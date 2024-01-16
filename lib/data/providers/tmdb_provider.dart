import 'package:miru_app/models/tmdb.dart' as tmdb_model;
import 'package:miru_app/utils/miru_storage.dart';
import 'package:tmdb_api/tmdb_api.dart';

class TmdbApi {
  static TMDB tmdb = TMDB(
    ApiKeys(MiruStorage.getSetting(SettingKey.tmdbKey), ''),
    defaultLanguage: MiruStorage.getSetting(SettingKey.language),
  );

  static Future<tmdb_model.TMDBDetail?> getDetailBySearch(
    String keyword, {
    int page = 1,
  }) async {
    final result = await search(
      keyword,
      page: page,
    );
    // print(result);
    final results = result["results"] as List;
    if (results.isEmpty) {
      return null;
    }
    return getDetail(
      results.first["id"],
      results.first["media_type"],
    );
  }

  static Future<tmdb_model.TMDBDetail> getDetail(
    int id,
    String mediaType,
  ) async {
    late Map data;
    if (mediaType == "movie") {
      data = await tmdb.v3.movies.getDetails(
        id,
        appendToResponse: "credits,images",
      );
    } else {
      data = await tmdb.v3.tv.getDetails(
        id,
        appendToResponse: "credits,images",
      );
    }
    return tmdb_model.TMDBDetail(
      id: data["id"],
      mediaType: mediaType,
      title: data["title"] ?? data["name"],
      cover: data["poster_path"] ?? data["profile_path"],
      backdrop: data["backdrop_path"],
      genres: List<String>.from(data["genres"].map((e) => e["name"])),
      languages:
          List<String>.from(data["spoken_languages"].map((e) => e["name"])),
      images: List<String>.from(
        data["images"]["backdrops"].map((e) => e["file_path"]),
      ),
      overview: data["overview"],
      status: data["status"],
      casts: List<tmdb_model.TMDBCast>.from(
          data["credits"]["cast"].map((e) => tmdb_model.TMDBCast(
                id: e["id"],
                name: e["name"],
                profilePath: e["profile_path"],
                character: e["character"],
              ))),
      releaseDate: data["release_date"] ?? data["first_air_date"],
      runtime: data["runtime"] ??
          List.from(data["episode_run_time"]).firstOrNull ??
          0,
      originalTitle: data["original_title"] ?? data["original_name"],
    );
  }

  static Future<Map> search(String keyword, {int page = 1}) {
    return tmdb.v3.search.queryMulti(
      keyword,
      page: page,
    );
  }

  static String? getImageUrl(String path, {size = ImageSizes.ORIGINAL}) {
    return tmdb.images.getUrl(path, size: size);
  }
}
