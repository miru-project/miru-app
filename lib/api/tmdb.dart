import 'package:miru_app/models/tmdb.dart' as tmdb_model;
import 'package:miru_app/utils/miru_storage.dart';
import 'package:tmdb_api/tmdb_api.dart';

class TmdbApi {
  static TMDB tmdb = TMDB(
    ApiKeys(MiruStorage.getSetting(SettingKey.tmdbKay), ''),
    defaultLanguage: MiruStorage.getSetting(SettingKey.language),
  );

  static Future<tmdb_model.TMDBDetail> getDetail(String keyword,
      {int page = 1}) async {
    final result = await tmdb.v3.search.queryMulti(
      keyword,
      page: page,
    );
    // print(result);
    final results = result["results"] as List;
    if (results.isEmpty) {
      throw Exception("No results");
    }
    late Map data;
    final mediaType = results[0]["media_type"];
    if (mediaType == "movie") {
      data = await tmdb.v3.movies.getDetails(
        results[0]["id"],
        appendToResponse: "credits,images",
      );
    } else {
      data = await tmdb.v3.tv.getDetails(
        results[0]["id"],
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
      runtime: data["runtime"] ?? data["episode_run_time"][0],
      originalTitle: data["original_title"] ?? data["original_name"],
    );
  }

  static Future<Map> search(String keyword, {int page = 1}) {
    return tmdb.v3.search.queryMulti(
      keyword,
      page: page,
    );
  }

  static String? getImageUrl(String path) {
    return tmdb.images.getUrl(path);
  }
}
