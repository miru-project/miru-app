import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
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
    if (Platform.isAndroid) {
      Get.to(
        () => const AnilistWebViewPage(
          url: loginUrl,
        ),
      );
      return;
    }
    final webview = await WebviewWindow.create();
    webview
      ..launch(
        loginUrl,
      )
      ..addOnUrlRequestCallback((url) {
        if (url.contains("miru-app")) {
          AniListProvider.saveAuthToken(url);
          webview.close();
        }
      });
  }

  @override
  void onInit() {
    final token = MiruStorage.getSetting(SettingKey.aniListToken);
    if (token != "") {
      anilistIsLogin.value = true;
      initAnilistData();
    }
    super.onInit();
  }
}
