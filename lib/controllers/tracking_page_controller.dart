import 'dart:io';

import 'package:flutter_windows_webview/flutter_windows_webview.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/views/pages/tracking/anilist_webview.dart';

class TrackingPageController extends GetxController {
  final anilistIsLogin = false.obs;
  final anilistOauthUrl = "".obs;
  final anilistUserData = {}.obs;

  Future<Map<String, dynamic>> initAnilistData() async {
    final Map<String, dynamic> result = {};
    result["userData"] = await AniListProvider.getuserData();
    result["animeData"] =
        await AniListProvider.getCollection(AnilistType.anime);
    result["mangaData"] =
        await AniListProvider.getCollection(AnilistType.manga);
    return result;
  }

  _saveAnilistToken(String result) {
    RegExp tokenRegex = RegExp(r'(?<=access_token=).+(?=&token_type)');
    Match? re = tokenRegex.firstMatch(result);
    if (re != null) {
      String token = re.group(0)!;
      updateAniListToken(token);
    }
  }

  updateAniListToken(String accessToken) {
    MiruStorage.setSetting(SettingKey.aniListToken, accessToken);
    anilistIsLogin.value = true;
    initAnilistData();
  }

  logoutAniList() {
    MiruStorage.setSetting(SettingKey.aniListToken, "");
    anilistIsLogin.value = false;
  }

  loginAniList() async {
    const loginUrl =
        "https://anilist.co/api/v2/oauth/authorize?client_id=16214&response_type=token";
    if (Platform.isAndroid || Platform.isIOS) {
      final result = await Get.to(
        () => const AnilistWebViewPage(url: loginUrl),
      );
      _saveAnilistToken(result);
      return;
    }
    final webview = FlutterWindowsWebview();
    webview.launchWebview(loginUrl, WebviewOptions(
      onNavigation: (url) {
        if (url.contains("miru-app")) {
          _saveAnilistToken(url);
          webview.getCookies("https://anilist.co").then((cookies) async {
            for (final cookie in cookies.entries) {
              await webview.setCookie(
                name: cookie.key,
                value: "",
                domain: "anilist.co",
              );
            }
            webview.close();
          });
        }
        return false;
      },
    ));
  }

  @override
  void onInit() {
    final token = MiruStorage.getSetting(SettingKey.aniListToken);
    if (token != "") {
      anilistIsLogin.value = true;
    }
    super.onInit();
  }
}
