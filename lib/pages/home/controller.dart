import 'package:get/get.dart';
import 'package:miru_app/models/favorite.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/utils/database.dart';

class HomePageController extends GetxController {
  final RxList<History> resents = <History>[].obs;
  final RxList<Favorite> favorites = <Favorite>[].obs;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() async {
    resents.clear();
    favorites.clear();
    resents.addAll(
      await DatabaseUtils.getHistorysByType(),
    );
    favorites.addAll(
      await DatabaseUtils.getFavoritesByType(),
    );
  }
}
