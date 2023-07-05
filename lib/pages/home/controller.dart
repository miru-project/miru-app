import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/favorite.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/utils/database.dart';

class HomePageController extends GetxController {
  final RxList<History> resents = <History>[].obs;
  final RxList<Favorite> favorites = <Favorite>[].obs;

  @override
  void onInit() {
    onfresh();
    super.onInit();
  }

  onfresh() async {
    resents.clear();
    favorites.clear();
    resents.addAll(
      await DatabaseUtils.getHistorysByType(ExtensionType.bangumi),
    );
    favorites.addAll(
      await DatabaseUtils.getFavoritesByType(ExtensionType.bangumi),
    );
  }
}
