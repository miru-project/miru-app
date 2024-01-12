import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/tracking_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:miru_app/utils/miru_storage.dart';

enum AnilistType { anime, manga }

class AniListProvider {
  static String get anilistToken {
    return MiruStorage.getSetting(SettingKey.aniListToken);
  }

  static String get userid {
    return MiruStorage.getSetting(SettingKey.aniListUserId);
  }

  static const headers = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const String apiUrl = 'https://graphql.anilist.co';

  static String _anilistTypeToQuery(AnilistType type) {
    return (type == AnilistType.anime) ? "ANIME" : "MANGA";
  }

  static void saveAuthToken(String result) {
    RegExp tokenRegex = RegExp(r'(?<=access_token=).+(?=&token_type)');
    Match? re = tokenRegex.firstMatch(result);
    if (re != null) {
      String token = re.group(0)!;
      final c = Get.find<TrackingPageController>();
      c.updateAniListToken(token);
    }
  }

  static postRequest({
    Map<String, dynamic>? varibale,
    required String queryString,
  }) async {
    try {
      final response = await Dio().post(
        apiUrl,
        options: Options(headers: {
          "Authorization": "Bearer $anilistToken",
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
        data: {"query": queryString},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 400 &&
            e.response!.data
                .toString()
                .toLowerCase()
                .contains("invalid token")) {
          Get.find<TrackingPageController>().anilistIsLogin.value = false;
        }
        debugPrint("${e.response}");
      }
    }
  }

  static Future<Map<String, String>> getuserData() async {
    const userDataQuery =
        """{Viewer {name  id avatar{medium} statistics{anime{episodesWatched}manga{chaptersRead}}}}""";

    final response = await postRequest(queryString: userDataQuery);
    final userId = response["data"]["Viewer"]["id"].toString();
    MiruStorage.setSetting(SettingKey.aniListUserId, userId);
    final data = response["data"]["Viewer"];
    return {
      "UserAvatar": data["avatar"]["medium"],
      "User": data["name"],
      "AnimeEpWatched":
          data["statistics"]["anime"]["episodesWatched"].toString(),
      "MangaChapterRead": data["statistics"]["manga"]["chaptersRead"].toString()
    };
  }

  static Future<Map<String, dynamic>> getCollection(
      AnilistType anilistType) async {
    final query =
        """{MediaListCollection(userId: $userid, type: ${_anilistTypeToQuery(anilistType)}) { lists { name entries { status progress score(format:POINT_100) media { id status chapters episodes   meanScore isFavourite coverImage{large} title {userPreferred } } } }  } }""";
    final res = await postRequest(queryString: query);
    final collectionData = <String, List>{};
    int length = res["data"]["MediaListCollection"]["lists"].length;
    for (int i = 0; i < length; i++) {
      String key = res["data"]["MediaListCollection"]["lists"][i]["name"];
      collectionData[key] =
          res["data"]["MediaListCollection"]["lists"][i]["entries"];
    }
    return collectionData;
  }

  //use their name to query anime or manga id
  //save anilist: use mediaQueryPage to get id then go to editlist
  static Future<List<dynamic>> mediaQuerypage({
    required String searchString,
    required AnilistType type,
    int? page,
  }) async {
    final String nameQuery = """{Page(page:${page ?? 1}){
    media(search:"$searchString",type:${_anilistTypeToQuery(type)}){
        id
        type
        seasonYear
        isAdult
        description
        status
        season
        startDate{
            year
            month
            day
        }
        endDate{
            year
            month
            day
        }
        coverImage{
            large
        }
        title{
            romaji
            english
            native
            userPreferred 
        }
    }
  }}
  """;
    final res = await postRequest(queryString: nameQuery);
    return res["data"]["Page"]["media"];
  }

  static Future<String> editList({
    required String status,
    String? mediaId,
    String? id,
    String? progress,
    String? score,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPrivate,
  }) async {
    buildIdQuery() {
      if (id == null) {
        return "mediaId:$mediaId";
      } else {
        return "id:$id";
      }
    }

    buildScoreQuery() {
      if (score == null) {
        return "";
      } else {
        return "score:$score";
      }
    }

    buildProgressQuery() {
      if (progress == null) {
        return "";
      } else {
        return "progress:$progress";
      }
    }

    buildStartDateQuery() {
      if (startDate == null) {
        return "";
      } else {
        return "startedAt:{year:${startDate.year},month:${startDate.month},day:${startDate.day}}";
      }
    }

    buildCompletedAtQuery() {
      if (endDate == null) {
        return "";
      } else {
        return "completedAt:{year:${endDate.year},month:${endDate.month},day:${endDate.day}}";
      }
    }

    final queryStr = [
      buildIdQuery(),
      buildScoreQuery(),
      buildProgressQuery(),
      buildStartDateQuery(),
      buildCompletedAtQuery()
    ]
      ..removeWhere((element) => element == "")
      ..join(",");

    final queryString = """mutation{
    SaveMediaListEntry(status:$status,private:${isPrivate ?? false},$queryStr){
        id
      }
    }""";

    debugPrint(queryString);
    final res = await postRequest(queryString: queryString);
    return res["data"]["SaveMediaListEntry"]["id"].toString();
  }

  static Future<bool> deleteList({required String id}) async {
    final String deleteMutation = """
    mutation{
        DeleteMediaListEntry(id:$id){
              deleted
      }
    }
    """;
    final res = await postRequest(queryString: deleteMutation);
    return res["data"]["DeleteMediaListEntry"]["deleted"];
  }

  static Future<dynamic> getMediaList(String id) async {
    final query = """
{
    MediaList(id:$id ){
        score
        mediaId
        status
        progress
        id
        media{
            title{
                userPreferred
            }
        }
        startedAt{
            year
            month
            day
        }
        completedAt{
            year
            month
            day
        }
    }
}
""";
    // debugPrint(query);
    final res = await postRequest(queryString: query);
    debugPrint(res.toString());
    return res["data"]["MediaList"];
  }
}
