import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:miru_app/controllers/sync_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:miru_app/utils/miru_storage.dart';

class AniList {
  static late String anilistToken;
  static late String userid;
  // static late final authheaders;
  static const headers = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const String aniListId = "15748";
  static const String apiUrl = 'https://graphql.anilist.co';
  static const String graphiQuery = """
  query (\$id: Int) { # Define which variables will be used in the query (id)
    Media (id: \$id, type: ANIME) {
      title {
        romaji
        english
        native
      }
    }
  }
""";

  static const String userDataQuery =
      """{Viewer {name  id avatar{medium} statistics{anime{episodesWatched}manga{chaptersRead}}}}""";
  static initToken(String token) {
    anilistToken = token;
    userid = MiruStorage.getSetting(SettingKey.aniListUserId);
  }

  static Future<void> authenticate() async {
    // Windows needs some callback URL on localhost
    final callbackUrlScheme = (Platform.isWindows || Platform.isLinux)
        ? 'http://localhost:43824'
        : 'miruapp';
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
      print("${e.message}");
    }
  }

  static void saveAuthToken(String result) {
    RegExp tokenRegex = RegExp(r'(?<=access_token=).+(?=&token_type)');
    Match? re = tokenRegex.firstMatch(result);
    print("$re");
    if (re != null) {
      String token = re.group(0)!;
      print(token);
      anilistToken = token;
      final c = Get.put(SyncPageController());
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
        print(e.response);
      }
    }
  }

  static Future<Map<String, String>> getuserData() async {
    final response = await postRequest(queryString: userDataQuery);
    final userId = response["data"]["Viewer"]["id"].toString();
    print(userId);
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

  static query() async {
    final res =
        await postRequest(varibale: {"id": 15125}, queryString: graphiQuery);
    print("$res");
  }

  //use their name to query anime or manga id
  //save anilist: use mediaQueryPage to get id then go to editlist
  static Future<List<dynamic>> mediaQuerypage(
      {required String searchString, required String type, int? page}) async {
    final String nameQuery = """{Page(page:${page ?? 1}){
    media(search:"$searchString",type:$type){
        id
        type
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
    final data = res["data"]["Page"]["media"];
    print("$data");
    return res["data"]["Page"]["media"];
  }

  static editList(
      {int? mediaId,
      int? id,
      required String status,
      required int score,
      required int progress,
      required int startyear,
      required int startmonth,
      required int startday,
      required int endmonth,
      required int endyear,
      bool? isPrivate,
      required int endday}) async {
    late String query;
    if (id == null) {
      query = """mutation{
    SaveMediaListEntry(mediaId:$mediaId,status:$status,startedAt:{year:$startyear,month:$startmonth,day:$startday},score:$score,progress:$progress,private:${isPrivate ?? false},completedAt:{year:$endyear,month:$endmonth,day:$endday}){
        score
        id
    }
}""";
      debugPrint(query);
    } else {
      query = """mutation{
    SaveMediaListEntry(id:$id,status:$status,startedAt:{year:$startyear,month:$startmonth,day:$startday},score:$score,progress:$progress,private:${isPrivate ?? false},completedAt:{year:$endyear,month:$endmonth,day:$endday}){
        score
        id
    }
}""";
    }
    final res = await postRequest(queryString: query);
    debugPrint("$res");
  }
}
