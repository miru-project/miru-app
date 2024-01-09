import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:miru_app/controllers/tracking_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:miru_app/utils/miru_storage.dart';

class AniListProvider {
  static late String anilistToken;
  static late String userid;
  static const headers = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const String apiUrl = 'https://graphql.anilist.co';

  static const String userDataQuery =
      """{Viewer {name  id avatar{medium} statistics{anime{episodesWatched}manga{chaptersRead}}}}""";
  static initToken() {
    final token = MiruStorage.getSetting(SettingKey.aniListToken);
    anilistToken = token;
    userid = MiruStorage.getSetting(SettingKey.aniListUserId);
  }

  static Future<void> authenticate() async {
    // Windows needs some callback URL on localhost
    const callbackUrlScheme = 'miruapp';
    final clientId = Platform.isAndroid ? '15748' : '15782';
    try {
      final result = await FlutterWebAuth2.authenticate(
        url:
            "https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&response_type=token",
        callbackUrlScheme: callbackUrlScheme,
      );
      // print("result: $result");
      saveAuthToken(result);
    } on PlatformException catch (e) {
      debugPrint("${e.message}");
    }
  }

  static void saveAuthToken(String result) {
    RegExp tokenRegex = RegExp(r'(?<=access_token=).+(?=&token_type)');
    Match? re = tokenRegex.firstMatch(result);
    if (re != null) {
      String token = re.group(0)!;
      anilistToken = token;
      final c = Get.put(TrackingPageController());
      c.updateAniListToken(token);
    }
  }

  static postRequest(
      {Map<String, dynamic>? varibale, required String queryString}) async {
    try {
      final response = await Dio().post(apiUrl,
          options: Options(headers: {
            "Authorization": "Bearer $anilistToken",
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }),
          data: {"query": queryString});
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("${e.response}");
      }
    }
  }

  static Future<Map<String, String>> getuserData() async {
    final response = await postRequest(queryString: userDataQuery);
    final userId = response["data"]["Viewer"]["id"].toString();
    MiruStorage.setSetting(SettingKey.aniListUserId, userId);
    userid = userId;
    return {
      "UserAvatar": response["data"]["Viewer"]["avatar"]["medium"],
      "User": response["data"]["Viewer"]["name"],
      "AnimeEpWatched": response["data"]["Viewer"]["statistics"]["anime"]
              ["episodesWatched"]
          .toString(),
      "MangaChapterRead": response["data"]["Viewer"]["statistics"]["manga"]
              ["chaptersRead"]
          .toString()
    };
  }

  static Future<Map<String, dynamic>> getCollection(String type) async {
    final query =
        """{MediaListCollection(userId: $userid, type: $type) { lists { name entries { status progress score(format:POINT_100) media { id status chapters episodes   meanScore isFavourite coverImage{large} title {userPreferred } } } }  } }""";
    final res = await postRequest(queryString: query);
    // print(res.toString().length);
    final collectionData = <String, List>{};
    int length = res["data"]["MediaListCollection"]["lists"].length;
    for (int i = 0; i < length; i++) {
      String key = res["data"]["MediaListCollection"]["lists"][i]["name"];
      collectionData[key] =
          res["data"]["MediaListCollection"]["lists"][i]["entries"];
    }
    debugPrint("$collectionData");
    return collectionData;
  }

  //use their name to query anime or manga id
  //save anilist: use mediaQueryPage to get id then go to editlist
  static Future<List<dynamic>> mediaQuerypage(
      {required String searchString, required String type, int? page}) async {
    final String nameQuery = """{Page(page:${page ?? 1}){
    media(search:"$searchString",type:$type){
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
    String? mediaId,
    String? id,
    required String status,
    String? progress,
    String? score,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPrivate,
  }) async {
    late String query;
    query = """mutation{
    SaveMediaListEntry(status:$status,private:${isPrivate ?? false},queryId,startedAt,score,progress,completedAt){
        id
    }
}""";
//     if (id == null) {

//     } else {
//       query = """mutation{
//     SaveMediaListEntry(id:$id,status:$status,private:${isPrivate ?? false},startedAt,score,progress,completedAt){
//         id
//     }
// }""";
//     }
    final queryString = query
        .replaceFirst(
            "startedAt,",
            (startDate == null)
                ? ""
                : "startedAt:{year:${startDate.year},month:${startDate.month},day:${startDate.day}},")
        .replaceFirst("score,", (score == null) ? "" : "score:$score,")
        .replaceFirst(
            "progress,", (progress == null) ? "" : "progress:$progress,")
        .replaceFirst(
            "completedAt",
            (endDate == null)
                ? ""
                : "completedAt:{year:${endDate.year},month:${endDate.month},day:${endDate.day}}")
        .replaceFirst("queryId,", id == "" ? "mediaId:$mediaId," : "id:$id,");
    debugPrint(queryString);
    final res = await postRequest(queryString: queryString);
    // debugPrint("${res["data"]["SaveMediaListEntry"]["id"]}");
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

    debugPrint(deleteMutation);
    final res = await postRequest(queryString: deleteMutation);
    debugPrint("$res");
    return res["data"]["DeleteMediaListEntry"]["deleted"];
  }
}
