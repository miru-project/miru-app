import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/favorite.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/utils/database.dart';

class HomePageController extends GetxController {
  final RxList<History> resents = <History>[].obs;
  final RxMap<ExtensionType, List<Favorite>> favorites =
      <ExtensionType, List<Favorite>>{}.obs;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  refreshHistory() async {
    resents.clear();
    resents.addAll(
      await DatabaseUtils.getHistorysByType(),
    );
  }

  onRefresh() async {
    favorites.clear();
    await refreshHistory();
    favorites.addAll({
      ExtensionType.bangumi: await DatabaseUtils.getFavoritesByType(
        type: ExtensionType.bangumi,
        limit: 20,
      ),
      ExtensionType.manga: await DatabaseUtils.getFavoritesByType(
        type: ExtensionType.manga,
        limit: 20,
      ),
      ExtensionType.fikushon: await DatabaseUtils.getFavoritesByType(
        type: ExtensionType.fikushon,
        limit: 20,
      ),
    });
  }
}
