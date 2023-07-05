import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/pages/home/controller.dart';
import 'package:miru_app/pages/watch/view.dart';
import 'package:miru_app/utils/database.dart';
import 'package:miru_app/utils/extension.dart';

class DetailPageController extends GetxController {
  DetailPageController({
    required this.package,
    required this.url,
  });

  ScrollController scrollController = ScrollController();

  final isFavorite = false.obs;
  final String package;
  final String url;
  final Rx<ExtensionDetail?> data = Rx(null);
  final Rx<History?> history = Rx(null);
  final RxString error = ''.obs;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() async {
    await refreshFavorite();
    try {
      data.value = await ExtensionUtils.extensions[package]?.detail(url);
      // 获取历史记录
      final history_ = await DatabaseUtils.getHistoryByPackageAndUrl(
        package,
        url,
      );
      if (history_ != null) {
        if (history_.episodeGroupId < data.value!.episodes!.length) {
          history.value = history_;
        }
      }
    } catch (e) {
      error.value = e.toString();
    }
  }

  refreshFavorite() async {
    isFavorite.value =
        await DatabaseUtils.isFavorite(package: package, url: url);
  }

  toggleFavorite() async {
    await DatabaseUtils.toggleFavorite(
      package: package,
      url: url,
      cover: data.value!.cover,
      name: data.value!.title,
    );
    await refreshFavorite();
    Get.find<HomePageController>().onfresh();
  }

  goWatch(
    BuildContext context,
    List<ExtensionEpisode> urls,
    int index,
    int selectEpGroup,
  ) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: ((context, animation, secondaryAnimation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.ease,
              ),
            ),
            child: WatchPage(
              playList: urls,
              package: package,
              playerIndex: index,
              title: data.value!.title,
              episodeGroupId: selectEpGroup,
              detailUrl: url,
            ),
          );
        }),
      ),
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
