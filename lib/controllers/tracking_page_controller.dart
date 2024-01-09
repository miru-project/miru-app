import 'package:get/get.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
import 'package:miru_app/utils/miru_storage.dart';

class TrackingPageController extends GetxController {
  final anilistIsLogin = false.obs;
  final anilistOauthUrl = "".obs;
  updateAniListToken(String accessToken) {
    MiruStorage.setSetting(SettingKey.aniListToken, accessToken);
    AniListProvider.initToken();
    anilistIsLogin.value = true;
  }

  @override
  void onInit() {
    final token = MiruStorage.getSetting(SettingKey.aniListToken);
    if (token != "") {
      anilistIsLogin.value = true;
      AniListProvider.initToken();
    }

    super.onInit();
  }
}
