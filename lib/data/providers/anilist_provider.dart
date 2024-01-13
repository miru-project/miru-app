import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/tracking_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/views/widgets/messenger.dart';

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
          Get.put(TrackingPageController()).anilistIsLogin.value = false;
          // ignore: use_build_context_synchronously
          showPlatformSnackbar(
            context: currentContext,
            content: "Not login",
          );
        }
        debugPrint("${e.response}");
        rethrow;
      }
    }
  }

  static Future<Map<String, dynamic>> getuserData() async {
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
    int? progress,
    double? score,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPrivate,
  }) async {
    final queryList = [];
    if (id == null) {
      queryList.add("mediaId:$mediaId");
    } else {
      queryList.add("id:$id");
    }

    if (score != null) {
      queryList.add("score:$score");
    }

    if (progress != null) {
      queryList.add("progress:$progress");
    }

    if (startDate != null) {
      queryList.add(
        "startedAt:{year:${startDate.year},month:${startDate.month},day:${startDate.day}}",
      );
    }

    if (endDate != null) {
      queryList.add(
        "completedAt:{year:${endDate.year},month:${endDate.month},day:${endDate.day}}",
      );
    }

    final queryStr = queryList.join(",");

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
   Media(id: $id) {
    id
    title {
      userPreferred
    }
    coverImage {
      large
    }
    bannerImage
    type
    status
    episodes
    chapters
    volumes
    isFavourite
    mediaListEntry {
      id
      mediaId
      status
      score
      advancedScores
      progress
      progressVolumes
      repeat
      priority
      private
      hiddenFromStatusLists
      customLists
      notes
      updatedAt
      startedAt {
        year
        month
        day
      }
      completedAt {
        year
        month
        day
      }
      user {
        id
        name
      }
    }
  }
}
""";
    // debugPrint(query);
    final res = await postRequest(queryString: query);
    debugPrint(res.toString());
    return res["data"]["Media"];
  }
}
