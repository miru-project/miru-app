import 'package:get/get.dart';
import 'package:miru_app/utils/anilist.dart';
import 'package:miru_app/utils/miru_storage.dart';

class SyncPageController extends GetxController {
  final anilistIsLogin = false.obs;
  final anilistOauthUrl = "".obs;
  updateAniListToken(String accessToken) {
    MiruStorage.setSetting(SettingKey.aniListToken, accessToken);
    AniList.initToken();
    anilistIsLogin.value = true;
  }

  @override
  void onInit() {
    final token = MiruStorage.getSetting(SettingKey.aniListToken);
    if (token != "") {
      anilistIsLogin.value = true;
      AniList.initToken();
      print("user regeistered");
    }

    super.onInit();
  }
}
// SyncPageController c = SyncPageController();
